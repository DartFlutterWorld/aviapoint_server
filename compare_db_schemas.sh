#!/bin/bash

# Скрипт для сравнения структуры базы данных между локальной и удаленной БД
# Использование: ./compare_db_schemas.sh

set -e

SERVER_IP=${SERVER_IP:-"83.166.246.205"}
SERVER_USER="root"
SERVER_PASSWORD=${SERVER_PASSWORD:-"uOTC0OWjMVIoaRxI"}
DB_NAME="aviapoint"
DB_USER="postgres"
LOCAL_DB_PASSWORD=${POSTGRESQL_PASSWORD:-"password"}
LOCAL_DB_HOST=${POSTGRESQL_HOST:-"127.0.0.1"}
LOCAL_DB_PORT=${POSTGRESQL_PORT:-"5432"}

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPORT_FILE="db_schema_comparison_report_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Сравнение структуры БД: локальная vs удаленная${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Функция для выполнения SSH команд с паролем
ssh_with_password() {
    if command -v sshpass >/dev/null 2>&1; then
        sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$@"
    elif command -v expect >/dev/null 2>&1; then
        local expect_file=$(mktemp)
        {
            echo "set timeout 30"
            echo "set ssh_args {}"
            for arg in "$@"; do
                arg_escaped=$(printf '%s' "$arg" | sed 's/\\/\\\\/g; s/\[/\\\[/g; s/\]/\\\]/g; s/\$/\\\$/g; s/"/\\"/g; s/`/\\`/g')
                echo "lappend ssh_args \"$arg_escaped\""
            done
            echo 'eval spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $ssh_args'
            echo "expect {"
            echo '    "password:" {'
            echo "        send \"$SERVER_PASSWORD\\r\""
            echo "        exp_continue"
            echo "    }"
            echo '    "yes/no" {'
            echo '        send "yes\r"'
            echo "        exp_continue"
            echo "    }"
            echo "    eof"
            echo "}"
            echo "catch wait result"
            echo "exit [lindex \$result 3]"
        } > "$expect_file"
        expect -f "$expect_file" 2>&1 | grep -v "^spawn\|^root@\|password:"
        local exit_code=$?
        rm -f "$expect_file"
        return $exit_code
    else
        echo -e "${YELLOW}⚠️  sshpass и expect не установлены. Используется обычный SSH${NC}" >&2
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$@"
    fi
}

# Функция для получения структуры таблицы
get_table_structure() {
    local db_host=$1
    local db_port=$2
    local db_user=$3
    local db_password=$4
    local db_name=$5
    local table_name=$6
    local is_remote=$7
    
    if [ "$is_remote" = "true" ]; then
        # Удаленная БД через SSH
        ssh_with_password $SERVER_USER@$SERVER_IP "docker exec -e PGPASSWORD=$db_password aviapoint-postgres psql -U $db_user -d $db_name -t -c \"
            SELECT 
                column_name,
                data_type,
                character_maximum_length,
                is_nullable,
                column_default
            FROM information_schema.columns
            WHERE table_schema = 'public' AND table_name = '$table_name'
            ORDER BY ordinal_position;
        \"" 2>/dev/null | grep -v "^spawn\|^root@\|password:" | sed 's/^[[:space:]]*//' | sed '/^$/d'
    else
        # Локальная БД
        PGPASSWORD=$db_password psql -h $db_host -p $db_port -U $db_user -d $db_name -t -c "
            SELECT 
                column_name,
                data_type,
                character_maximum_length,
                is_nullable,
                column_default
            FROM information_schema.columns
            WHERE table_schema = 'public' AND table_name = '$table_name'
            ORDER BY ordinal_position;
        " 2>/dev/null | sed 's/^[[:space:]]*//' | sed '/^$/d'
    fi
}

# Функция для получения списка таблиц
get_tables() {
    local db_host=$1
    local db_port=$2
    local db_user=$3
    local db_password=$4
    local db_name=$5
    local is_remote=$6
    
    if [ "$is_remote" = "true" ]; then
        # Используем более простой подход - создаем временный SQL файл
        local temp_sql=$(mktemp)
        echo "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name;" > "$temp_sql"
        
        # Копируем SQL файл на сервер
        expect <<EOF 2>/dev/null | grep -v "^spawn\|^root@\|password:" | tail -n +2 | head -n -1 | sed 's/^[[:space:]]*//' | sed '/^$/d' | grep -v "^$"
set timeout 30
spawn scp -o StrictHostKeyChecking=no "$temp_sql" $SERVER_USER@$SERVER_IP:/tmp/get_tables.sql
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
        
        # Выполняем SQL на сервере
        expect <<EOF 2>/dev/null | grep -v "^spawn\|^root@\|password:" | tail -n +2 | head -n -1 | sed 's/^[[:space:]]*//' | sed '/^$/d' | grep -v "^$"
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "docker exec -e PGPASSWORD=$db_password aviapoint-postgres psql -U $db_user -d $db_name -t -f /tmp/get_tables.sql"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
        
        rm -f "$temp_sql"
    else
        PGPASSWORD=$db_password psql -h $db_host -p $db_port -U $db_user -d $db_name -t -c "
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            ORDER BY table_name;
        " 2>/dev/null | sed 's/^[[:space:]]*//' | sed '/^$/d'
    fi
}

# Функция для получения ограничений (constraints)
get_constraints() {
    local db_host=$1
    local db_port=$2
    local db_user=$3
    local db_password=$4
    local db_name=$5
    local table_name=$6
    local is_remote=$7
    
    if [ "$is_remote" = "true" ]; then
        ssh_with_password $SERVER_USER@$SERVER_IP "docker exec -e PGPASSWORD=$db_password aviapoint-postgres psql -U $db_user -d $db_name -t -c \"
            SELECT 
                constraint_name,
                constraint_type
            FROM information_schema.table_constraints
            WHERE table_schema = 'public' AND table_name = '$table_name'
            ORDER BY constraint_type, constraint_name;
        \"" 2>/dev/null | grep -v "^spawn\|^root@\|password:" | sed 's/^[[:space:]]*//' | sed '/^$/d'
    else
        PGPASSWORD=$db_password psql -h $db_host -p $db_port -U $db_user -d $db_name -t -c "
            SELECT 
                constraint_name,
                constraint_type
            FROM information_schema.table_constraints
            WHERE table_schema = 'public' AND table_name = '$table_name'
            ORDER BY constraint_type, constraint_name;
        " 2>/dev/null | sed 's/^[[:space:]]*//' | sed '/^$/d'
    fi
}

# Функция для получения индексов
get_indexes() {
    local db_host=$1
    local db_port=$2
    local db_user=$3
    local db_password=$4
    local db_name=$5
    local table_name=$6
    local is_remote=$7
    
    if [ "$is_remote" = "true" ]; then
        ssh_with_password $SERVER_USER@$SERVER_IP "docker exec -e PGPASSWORD=$db_password aviapoint-postgres psql -U $db_user -d $db_name -t -c \"
            SELECT 
                indexname
            FROM pg_indexes
            WHERE schemaname = 'public' AND tablename = '$table_name'
            ORDER BY indexname;
        \"" 2>/dev/null | grep -v "^spawn\|^root@\|password:" | sed 's/^[[:space:]]*//' | sed '/^$/d'
    else
        PGPASSWORD=$db_password psql -h $db_host -p $db_port -U $db_user -d $db_name -t -c "
            SELECT 
                indexname
            FROM pg_indexes
            WHERE schemaname = 'public' AND tablename = '$table_name'
            ORDER BY indexname;
        " 2>/dev/null | sed 's/^[[:space:]]*//' | sed '/^$/d'
    fi
}

echo -e "${YELLOW}1. Получение списка таблиц из локальной БД...${NC}"
LOCAL_TABLES=$(get_tables "$LOCAL_DB_HOST" "$LOCAL_DB_PORT" "$DB_USER" "$LOCAL_DB_PASSWORD" "$DB_NAME" "false")
echo -e "${GREEN}✅ Найдено таблиц в локальной БД: $(echo "$LOCAL_TABLES" | wc -l | tr -d ' ')${NC}"

echo -e "\n${YELLOW}2. Получение списка таблиц из удаленной БД...${NC}"
REMOTE_TABLES=$(get_tables "$SERVER_IP" "5432" "$DB_USER" "$SERVER_PASSWORD" "$DB_NAME" "true")
echo -e "${GREEN}✅ Найдено таблиц в удаленной БД: $(echo "$REMOTE_TABLES" | wc -l | tr -d ' ')${NC}"

# Создаем отчет
{
    echo "═══════════════════════════════════════════════════════════"
    echo "  ОТЧЕТ О СРАВНЕНИИ СТРУКТУРЫ БД"
    echo "  Дата: $(date)"
    echo "  Локальная БД: $LOCAL_DB_HOST:$LOCAL_DB_PORT"
    echo "  Удаленная БД: $SERVER_IP (aviapoint-postgres)"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
} > "$REPORT_FILE"

# Находим таблицы, которые есть только в локальной БД
echo -e "\n${YELLOW}3. Поиск таблиц, которые есть только в локальной БД...${NC}"
ONLY_LOCAL=""
for table in $LOCAL_TABLES; do
    if ! echo "$REMOTE_TABLES" | grep -q "^$table$"; then
        ONLY_LOCAL="$ONLY_LOCAL $table"
        echo -e "${RED}  ❌ Только в локальной: $table${NC}"
        {
            echo "═══════════════════════════════════════════════════════════"
            echo "ТАБЛИЦА: $table (только в локальной БД)"
            echo "═══════════════════════════════════════════════════════════"
            echo ""
            echo "Эта таблица отсутствует в удаленной БД."
            echo "Необходимо создать миграцию для добавления этой таблицы."
            echo ""
        } >> "$REPORT_FILE"
    fi
done

# Находим таблицы, которые есть только в удаленной БД
echo -e "\n${YELLOW}4. Поиск таблиц, которые есть только в удаленной БД...${NC}"
ONLY_REMOTE=""
for table in $REMOTE_TABLES; do
    if ! echo "$LOCAL_TABLES" | grep -q "^$table$"; then
        ONLY_REMOTE="$ONLY_REMOTE $table"
        echo -e "${YELLOW}  ⚠️  Только в удаленной: $table${NC}"
        {
            echo "═══════════════════════════════════════════════════════════"
            echo "ТАБЛИЦА: $table (только в удаленной БД)"
            echo "═══════════════════════════════════════════════════════════"
            echo ""
            echo "Эта таблица отсутствует в локальной БД."
            echo "Возможно, она была создана напрямую на сервере."
            echo ""
        } >> "$REPORT_FILE"
    fi
done

# Сравниваем общие таблицы
echo -e "\n${YELLOW}5. Сравнение общих таблиц...${NC}"
COMMON_TABLES=""
for table in $LOCAL_TABLES; do
    if echo "$REMOTE_TABLES" | grep -q "^$table$"; then
        COMMON_TABLES="$COMMON_TABLES $table"
    fi
done

DIFF_COUNT=0
for table in $COMMON_TABLES; do
    echo -e "${BLUE}  Проверка таблицы: $table${NC}"
    
    LOCAL_STRUCTURE=$(get_table_structure "$LOCAL_DB_HOST" "$LOCAL_DB_PORT" "$DB_USER" "$LOCAL_DB_PASSWORD" "$DB_NAME" "$table" "false")
    REMOTE_STRUCTURE=$(get_table_structure "$SERVER_IP" "5432" "$DB_USER" "$SERVER_PASSWORD" "$DB_NAME" "$table" "true")
    
    if [ "$LOCAL_STRUCTURE" != "$REMOTE_STRUCTURE" ]; then
        DIFF_COUNT=$((DIFF_COUNT + 1))
        echo -e "${RED}  ❌ Различия найдены в таблице: $table${NC}"
        {
            echo "═══════════════════════════════════════════════════════════"
            echo "ТАБЛИЦА: $table (различия в структуре)"
            echo "═══════════════════════════════════════════════════════════"
            echo ""
            echo "--- ЛОКАЛЬНАЯ БД ---"
            echo "$LOCAL_STRUCTURE"
            echo ""
            echo "--- УДАЛЕННАЯ БД ---"
            echo "$REMOTE_STRUCTURE"
            echo ""
        } >> "$REPORT_FILE"
    else
        echo -e "${GREEN}  ✅ Таблица $table идентична${NC}"
    fi
    
    # Сравниваем ограничения
    LOCAL_CONSTRAINTS=$(get_constraints "$LOCAL_DB_HOST" "$LOCAL_DB_PORT" "$DB_USER" "$LOCAL_DB_PASSWORD" "$DB_NAME" "$table" "false")
    REMOTE_CONSTRAINTS=$(get_constraints "$SERVER_IP" "5432" "$DB_USER" "$SERVER_PASSWORD" "$DB_NAME" "$table" "true")
    
    if [ "$LOCAL_CONSTRAINTS" != "$REMOTE_CONSTRAINTS" ]; then
        echo -e "${RED}  ❌ Различия в ограничениях таблицы: $table${NC}"
        {
            echo "--- ОГРАНИЧЕНИЯ (CONSTRAINTS) ---"
            echo "Локальная БД:"
            echo "$LOCAL_CONSTRAINTS"
            echo ""
            echo "Удаленная БД:"
            echo "$REMOTE_CONSTRAINTS"
            echo ""
        } >> "$REPORT_FILE"
    fi
    
    # Сравниваем индексы
    LOCAL_INDEXES=$(get_indexes "$LOCAL_DB_HOST" "$LOCAL_DB_PORT" "$DB_USER" "$LOCAL_DB_PASSWORD" "$DB_NAME" "$table" "false")
    REMOTE_INDEXES=$(get_indexes "$SERVER_IP" "5432" "$DB_USER" "$SERVER_PASSWORD" "$DB_NAME" "$table" "true")
    
    if [ "$LOCAL_INDEXES" != "$REMOTE_INDEXES" ]; then
        echo -e "${RED}  ❌ Различия в индексах таблицы: $table${NC}"
        {
            echo "--- ИНДЕКСЫ ---"
            echo "Локальная БД:"
            echo "$LOCAL_INDEXES"
            echo ""
            echo "Удаленная БД:"
            echo "$REMOTE_INDEXES"
            echo ""
        } >> "$REPORT_FILE"
    fi
done

# Итоговый отчет
{
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  ИТОГОВАЯ СТАТИСТИКА"
    echo "═══════════════════════════════════════════════════════════"
    echo "Таблиц в локальной БД: $(echo "$LOCAL_TABLES" | wc -l | tr -d ' ')"
    echo "Таблиц в удаленной БД: $(echo "$REMOTE_TABLES" | wc -l | tr -d ' ')"
    echo "Общих таблиц: $(echo "$COMMON_TABLES" | wc -w)"
    echo "Таблиц только в локальной: $(echo "$ONLY_LOCAL" | wc -w)"
    echo "Таблиц только в удаленной: $(echo "$ONLY_REMOTE" | wc -w)"
    echo "Таблиц с различиями: $DIFF_COUNT"
    echo ""
} >> "$REPORT_FILE"

echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Сравнение завершено!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${YELLOW}📄 Отчет сохранен в файл: $REPORT_FILE${NC}"
echo -e "${YELLOW}📊 Итоги:${NC}"
echo -e "   Таблиц в локальной БД: $(echo "$LOCAL_TABLES" | wc -l | tr -d ' ')"
echo -e "   Таблиц в удаленной БД: $(echo "$REMOTE_TABLES" | wc -l | tr -d ' ')"
echo -e "   Общих таблиц: $(echo "$COMMON_TABLES" | wc -w)"
echo -e "   Таблиц только в локальной: $(echo "$ONLY_LOCAL" | wc -w)"
echo -e "   Таблиц только в удаленной: $(echo "$ONLY_REMOTE" | wc -w)"
echo -e "   Таблиц с различиями: $DIFF_COUNT"
echo ""
