#!/bin/bash

# Скрипт для синхронизации только структуры БД (таблицы и поля) на продакшн
# БЕЗ синхронизации данных
# Использование: ./sync_schema_only_to_prod.sh [server_ip]

# Проверка флага автоматического подтверждения
AUTO_CONFIRM=false
if [[ "$1" == "--yes" ]] || [[ "$1" == "-y" ]]; then
    AUTO_CONFIRM=true
    SERVER_IP=${2:-"83.166.246.205"}
else
    SERVER_IP=${1:-"83.166.246.205"}
fi

SERVER_USER="root"
SERVER_DB_CONTAINER="aviapoint-postgres"
SERVER_DB_NAME="aviapoint"
SERVER_DB_USER="postgres"
PROJECT_DIR="/home/aviapoint_server"
LOCAL_MIGRATIONS_DIR="migrations"
REMOTE_MIGRATIONS_DIR="/home/aviapoint_server/migrations"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Синхронизация структуры БД на продакшн (без данных)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Функция для SSH с паролем
ssh_with_password() {
    local cmd="$1"
    if command -v sshpass >/dev/null 2>&1; then
        sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd" 2>/dev/null
    elif command -v expect >/dev/null 2>&1; then
        expect <<EOF > /dev/null 2>&1
set timeout 300
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
catch wait result
EOF
        expect <<EOF
set timeout 300
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
    else
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd"
    fi
}

# Получаем пароль из переменной окружения или из README
if [ -z "$SERVER_PASSWORD" ]; then
    SERVER_PASSWORD="uOTC0OWjMVIoaRxI"
fi

# Проверка подключения к серверу
echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
if ! ssh_with_password "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Подключение установлено${NC}"

# Шаг 1: Синхронизация файлов миграций
echo -e "\n${YELLOW}2. Синхронизация файлов миграций на продакшн...${NC}"
if [ ! -d "$LOCAL_MIGRATIONS_DIR" ]; then
    echo -e "${RED}❌ Локальная папка migrations не найдена: $LOCAL_MIGRATIONS_DIR${NC}"
    exit 1
fi

# Получаем список всех .sql файлов
REQUIRED_MIGRATIONS=($(find "$LOCAL_MIGRATIONS_DIR" -maxdepth 1 -type f -name "*.sql" -exec basename {} \; | sort))

COPIED_COUNT=0
EXISTING_COUNT=0

for migration_file in "${REQUIRED_MIGRATIONS[@]}"; do
    local_file="$LOCAL_MIGRATIONS_DIR/$migration_file"
    remote_file="$REMOTE_MIGRATIONS_DIR/$migration_file"
    
    if [ ! -f "$local_file" ]; then
        continue
    fi
    
    # Проверяем, существует ли файл на сервере
    if ssh_with_password "[ -f \"$remote_file\" ]" 2>/dev/null | grep -q "true\|OK"; then
        ((EXISTING_COUNT++))
    else
        # Копируем файл
        if command -v sshpass >/dev/null 2>&1; then
            sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no "$local_file" $SERVER_USER@$SERVER_IP:"$remote_file" > /dev/null 2>&1
        elif command -v expect >/dev/null 2>&1; then
            expect <<EOF > /dev/null 2>&1
set timeout 300
spawn scp -o StrictHostKeyChecking=no "$local_file" $SERVER_USER@$SERVER_IP:"$remote_file"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
        else
            scp -o StrictHostKeyChecking=no "$local_file" $SERVER_USER@$SERVER_IP:"$remote_file" > /dev/null 2>&1
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "   ${GREEN}✓${NC} $migration_file"
            ((COPIED_COUNT++))
        else
            echo -e "   ${RED}✗${NC} $migration_file (ошибка копирования)"
        fi
    fi
done

echo -e "${GREEN}✅ Синхронизация файлов завершена (скопировано: $COPIED_COUNT, уже было: $EXISTING_COUNT)${NC}"

# Шаг 2: Получаем список примененных миграций с продакшн
echo -e "\n${YELLOW}3. Проверка примененных миграций на продакшн...${NC}"
EXECUTED_MIGRATIONS_RAW=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT version FROM schema_migrations ORDER BY version;\" 2>/dev/null" 2>/dev/null | grep -v "^spawn\|^root@\|password:" | grep -E '^[0-9]{3}$' || echo "")

EXECUTED_MIGRATIONS=$(echo "$EXECUTED_MIGRATIONS_RAW" | grep -v '^$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u)

if [ -z "$EXECUTED_MIGRATIONS" ]; then
    echo -e "${YELLOW}   ⚠️  Не удалось получить список миграций или таблица schema_migrations пуста${NC}"
    EXECUTED_MIGRATIONS_LIST=""
else
    EXECUTED_COUNT=$(echo "$EXECUTED_MIGRATIONS" | wc -l | tr -d ' ')
    echo -e "${GREEN}   ✅ Найдено примененных миграций: $EXECUTED_COUNT${NC}"
fi

# Шаг 3: Определяем миграции для применения (только структура, без данных)
echo -e "\n${YELLOW}4. Определение миграций для применения (только структура)...${NC}"

# Миграции, которые содержат данные (пропускаем)
DATA_MIGRATIONS=(
    "030:insert_airports_data"
    "034:insert_aircraft_types_from_planecheck_full"
    "037:insert_aircraft_catalog_data_full"
    "044:insert_new_blog_categories"
    "046:insert_blog_categories"
    "054:insert_test_market_products"
)

# Получаем список всех миграций из файлов
ALL_MIGRATION_FILES=($(find "$LOCAL_MIGRATIONS_DIR" -maxdepth 1 -type f -name "*.sql" | sort | xargs -n1 basename))

MIGRATIONS_TO_APPLY=()
SKIPPED_COUNT=0

for migration_file in "${ALL_MIGRATION_FILES[@]}"; do
    # Извлекаем номер версии из имени файла (первые 3 цифры)
    VERSION=$(echo "$migration_file" | grep -oE '^[0-9]{3}' | head -1)
    
    if [ -z "$VERSION" ]; then
        # Если нет номера версии в начале, пропускаем
        continue
    fi
    
    # Проверяем, применена ли миграция
    if echo "$EXECUTED_MIGRATIONS" | grep -q "^$VERSION$"; then
        continue
    fi
    
    # Проверяем, является ли это миграцией данных
    IS_DATA_MIGRATION=false
    for data_migration in "${DATA_MIGRATIONS[@]}"; do
        DATA_VERSION=$(echo "$data_migration" | cut -d':' -f1)
        if [ "$VERSION" = "$DATA_VERSION" ]; then
            IS_DATA_MIGRATION=true
            break
        fi
    done
    
    # Также проверяем по имени файла
    if echo "$migration_file" | grep -qiE "insert|data|test_data|seed"; then
        IS_DATA_MIGRATION=true
    fi
    
    if [ "$IS_DATA_MIGRATION" = true ]; then
        echo -e "   ${YELLOW}⏭️  Пропущена (миграция данных): $migration_file${NC}"
        ((SKIPPED_COUNT++))
    else
        MIGRATIONS_TO_APPLY+=("$migration_file")
    fi
done

if [ ${#MIGRATIONS_TO_APPLY[@]} -eq 0 ]; then
    echo -e "${GREEN}   ✅ Все миграции структуры уже применены${NC}"
    if [ $SKIPPED_COUNT -gt 0 ]; then
        echo -e "${YELLOW}   ⚠️  Пропущено миграций с данными: $SKIPPED_COUNT${NC}"
    fi
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Синхронизация завершена!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    exit 0
fi

echo -e "${YELLOW}   Найдено миграций структуры для применения: ${#MIGRATIONS_TO_APPLY[@]}${NC}"
if [ $SKIPPED_COUNT -gt 0 ]; then
    echo -e "${YELLOW}   Пропущено миграций с данными: $SKIPPED_COUNT${NC}"
fi

# Показываем список миграций для применения
echo -e "\n${YELLOW}   Миграции для применения:${NC}"
for migration_file in "${MIGRATIONS_TO_APPLY[@]}"; do
    echo -e "   - $migration_file"
done

# Подтверждение
echo -e "\n${YELLOW}5. Внимание!${NC}"
echo -e "${YELLOW}   Будут применены миграции структуры (CREATE TABLE, ALTER TABLE, CREATE INDEX и т.д.)${NC}"
echo -e "${YELLOW}   Миграции с данными (INSERT) будут пропущены${NC}"
echo -e "${RED}   Это изменит структуру БД на продакшн!${NC}"
echo ""

if [ "$AUTO_CONFIRM" = true ]; then
    echo -e "${GREEN}✅ Автоматическое подтверждение включено${NC}"
else
    read -p "Продолжить? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Операция отменена${NC}"
        exit 0
    fi
fi

# Шаг 4: Применяем миграции
echo -e "\n${YELLOW}6. Применение миграций структуры на продакшн...${NC}"
APPLIED_COUNT=0
FAILED_COUNT=0

for migration_file in "${MIGRATIONS_TO_APPLY[@]}"; do
    remote_file="$REMOTE_MIGRATIONS_DIR/$migration_file"
    
    echo -e "${YELLOW}   Применение: $migration_file${NC}"
    
    # Извлекаем версию и имя миграции
    VERSION=$(echo "$migration_file" | grep -oE '^[0-9]{3}' | head -1)
    MIGRATION_NAME=$(echo "$migration_file" | sed 's/^[0-9]*_//;s/\.sql$//')
    
    # Применяем миграцию через SSH и сохраняем результат во временный файл на сервере
    TEMP_OUTPUT="/tmp/migration_output_$$.txt"
    
    # Выполняем миграцию и сохраняем вывод
    ssh_with_password "cat $remote_file | docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME > $TEMP_OUTPUT 2>&1; cat $TEMP_OUTPUT; rm -f $TEMP_OUTPUT" 2>/dev/null | grep -v "^spawn\|^root@\|password:" > /tmp/migration_result.txt
    
    RESULT=$(cat /tmp/migration_result.txt 2>/dev/null || echo "")
    rm -f /tmp/migration_result.txt
    
    # Проверяем наличие ошибок
    if echo "$RESULT" | grep -qiE "ERROR|FATAL"; then
        echo -e "   ${RED}✗ Ошибка при применении${NC}"
        echo "$RESULT" | grep -iE "ERROR|FATAL" | head -5
        ((FAILED_COUNT++))
    else
        # Проверяем, что миграция действительно применилась (для CREATE TABLE проверяем существование таблицы)
        if echo "$migration_file" | grep -qiE "create.*table"; then
            # Извлекаем имя таблицы из миграции
            TABLE_NAME=$(grep -iE "CREATE TABLE.*IF NOT EXISTS|CREATE TABLE" "$LOCAL_MIGRATIONS_DIR/$migration_file" 2>/dev/null | head -1 | sed -E 's/.*CREATE TABLE.*IF NOT EXISTS[[:space:]]+([a-z_]+).*/\1/i' | sed -E 's/.*CREATE TABLE[[:space:]]+([a-z_]+).*/\1/i' | tr '[:upper:]' '[:lower:]' | awk '{print $1}')
            if [ -n "$TABLE_NAME" ]; then
                sleep 1
                TABLE_EXISTS=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$TABLE_NAME');\" 2>&1" 2>/dev/null | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r')
                if [ "$TABLE_EXISTS" != "t" ]; then
                    echo -e "   ${RED}✗ Таблица $TABLE_NAME не создана${NC}"
                    ((FAILED_COUNT++))
                    continue
                fi
            fi
        fi
        
        # Регистрируем миграцию в schema_migrations
        if [ -n "$VERSION" ] && [ -n "$MIGRATION_NAME" ]; then
            REGISTER_RESULT=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -c \"INSERT INTO schema_migrations (version, name) VALUES ('$VERSION', '$MIGRATION_NAME') ON CONFLICT (version) DO NOTHING;\" 2>&1" 2>/dev/null | grep -v "^spawn\|^root@\|password:")
            if echo "$REGISTER_RESULT" | grep -qiE "ERROR|FATAL"; then
                echo -e "   ${YELLOW}⚠ Применена, но не зарегистрирована в schema_migrations${NC}"
            fi
        fi
        echo -e "   ${GREEN}✓ Применена${NC}"
        ((APPLIED_COUNT++))
    fi
done

# Результат
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Синхронизация структуры завершена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${YELLOW}Статистика:${NC}"
echo -e "   Применено миграций: ${GREEN}$APPLIED_COUNT${NC}"
if [ $FAILED_COUNT -gt 0 ]; then
    echo -e "   Ошибок: ${RED}$FAILED_COUNT${NC}"
fi
if [ $SKIPPED_COUNT -gt 0 ]; then
    echo -e "   Пропущено (данные): ${YELLOW}$SKIPPED_COUNT${NC}"
fi

echo -e "\n${YELLOW}📌 Следующие шаги:${NC}"
echo -e "   Структура БД обновлена. Данные не были изменены."
echo -e "   Если нужно применить миграции с данными, используйте другой скрипт."
