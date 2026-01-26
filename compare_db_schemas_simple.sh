#!/bin/bash

# Упрощенный скрипт для сравнения структуры БД
# Использует pg_dump для получения структуры

set -e

SERVER_IP=${SERVER_IP:-"83.166.246.205"}
SERVER_USER="root"
SERVER_PASSWORD=${SERVER_PASSWORD:-"uOTC0OWjMVIoaRxI"}
DB_NAME="aviapoint"
DB_USER="postgres"
LOCAL_DB_PASSWORD=${POSTGRESQL_PASSWORD:-"password"}
LOCAL_DB_HOST=${POSTGRESQL_HOST:-"127.0.0.1"}
LOCAL_DB_PORT=${POSTGRESQL_PORT:-"5432"}

REPORT_FILE="db_schema_comparison_report_$(date +%Y%m%d_%H%M%S).txt"

echo "═══════════════════════════════════════════════════════════"
echo "  Сравнение структуры БД: локальная vs удаленная"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Функция для выполнения SSH команд
ssh_with_password() {
    if command -v sshpass >/dev/null 2>&1; then
        sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$@"
    elif command -v expect >/dev/null 2>&1; then
        expect <<EOF 2>/dev/null | grep -v "^spawn\|^root@\|password:" | tail -n +2 | head -n -1
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$@"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
    else
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$@"
    fi
}

echo "1. Получение структуры локальной БД..."
LOCAL_SCHEMA=$(PGPASSWORD=$LOCAL_DB_PASSWORD pg_dump -h $LOCAL_DB_HOST -p $LOCAL_DB_PORT -U $DB_USER -d $DB_NAME --schema-only --no-owner --no-privileges 2>/dev/null)

echo "2. Получение структуры удаленной БД..."
REMOTE_SCHEMA=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker exec -e PGPASSWORD=$SERVER_PASSWORD aviapoint-postgres pg_dump -U $DB_USER -d $DB_NAME --schema-only --no-owner --no-privileges" 2>/dev/null)

# Получаем списки таблиц
echo "3. Извлечение списков таблиц..."
LOCAL_TABLES=$(echo "$LOCAL_SCHEMA" | grep -E "^CREATE TABLE" | sed 's/CREATE TABLE //' | sed 's/ (.*$//' | sort)
REMOTE_TABLES=$(echo "$REMOTE_SCHEMA" | grep -E "^CREATE TABLE" | sed 's/CREATE TABLE //' | sed 's/ (.*$//' | sort)

# Создаем отчет
{
    echo "═══════════════════════════════════════════════════════════"
    echo "  ОТЧЕТ О СРАВНЕНИИ СТРУКТУРЫ БД"
    echo "  Дата: $(date)"
    echo "  Локальная БД: $LOCAL_DB_HOST:$LOCAL_DB_PORT"
    echo "  Удаленная БД: $SERVER_IP (aviapoint-postgres)"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "СТАТИСТИКА:"
    echo "  Таблиц в локальной БД: $(echo "$LOCAL_TABLES" | wc -l | tr -d ' ')"
    echo "  Таблиц в удаленной БД: $(echo "$REMOTE_TABLES" | wc -l | tr -d ' ')"
    echo ""
} > "$REPORT_FILE"

# Находим таблицы только в локальной БД
echo "4. Поиск таблиц только в локальной БД..."
ONLY_LOCAL=""
for table in $LOCAL_TABLES; do
    if ! echo "$REMOTE_TABLES" | grep -q "^$table$"; then
        ONLY_LOCAL="$ONLY_LOCAL $table"
        echo "  ❌ Только в локальной: $table"
        {
            echo "═══════════════════════════════════════════════════════════"
            echo "ТАБЛИЦА: $table (только в локальной БД)"
            echo "═══════════════════════════════════════════════════════════"
            echo ""
            echo "$LOCAL_SCHEMA" | sed -n "/^CREATE TABLE $table/,/^);$/p"
            echo ""
        } >> "$REPORT_FILE"
    fi
done

# Находим таблицы только в удаленной БД
echo "5. Поиск таблиц только в удаленной БД..."
ONLY_REMOTE=""
for table in $REMOTE_TABLES; do
    if ! echo "$LOCAL_TABLES" | grep -q "^$table$"; then
        ONLY_REMOTE="$ONLY_REMOTE $table"
        echo "  ⚠️  Только в удаленной: $table"
        {
            echo "═══════════════════════════════════════════════════════════"
            echo "ТАБЛИЦА: $table (только в удаленной БД)"
            echo "═══════════════════════════════════════════════════════════"
            echo ""
            echo "$REMOTE_SCHEMA" | sed -n "/^CREATE TABLE $table/,/^);$/p"
            echo ""
        } >> "$REPORT_FILE"
    fi
done

# Сравниваем общие таблицы
echo "6. Сравнение общих таблиц..."
COMMON_TABLES=""
DIFF_COUNT=0
for table in $LOCAL_TABLES; do
    if echo "$REMOTE_TABLES" | grep -q "^$table$"; then
        COMMON_TABLES="$COMMON_TABLES $table"
        LOCAL_TABLE_DEF=$(echo "$LOCAL_SCHEMA" | sed -n "/^CREATE TABLE $table/,/^);$/p")
        REMOTE_TABLE_DEF=$(echo "$REMOTE_SCHEMA" | sed -n "/^CREATE TABLE $table/,/^);$/p")
        
        if [ "$LOCAL_TABLE_DEF" != "$REMOTE_TABLE_DEF" ]; then
            DIFF_COUNT=$((DIFF_COUNT + 1))
            echo "  ❌ Различия в таблице: $table"
            {
                echo "═══════════════════════════════════════════════════════════"
                echo "ТАБЛИЦА: $table (различия в структуре)"
                echo "═══════════════════════════════════════════════════════════"
                echo ""
                echo "--- ЛОКАЛЬНАЯ БД ---"
                echo "$LOCAL_TABLE_DEF"
                echo ""
                echo "--- УДАЛЕННАЯ БД ---"
                echo "$REMOTE_TABLE_DEF"
                echo ""
            } >> "$REPORT_FILE"
        else
            echo "  ✅ Таблица $table идентична"
        fi
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

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ Сравнение завершено!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📄 Отчет сохранен в файл: $REPORT_FILE"
echo "📊 Итоги:"
echo "   Таблиц в локальной БД: $(echo "$LOCAL_TABLES" | wc -l | tr -d ' ')"
echo "   Таблиц в удаленной БД: $(echo "$REMOTE_TABLES" | wc -l | tr -d ' ')"
echo "   Общих таблиц: $(echo "$COMMON_TABLES" | wc -w)"
echo "   Таблиц только в локальной: $(echo "$ONLY_LOCAL" | wc -w)"
echo "   Таблиц только в удаленной: $(echo "$ONLY_REMOTE" | wc -w)"
echo "   Таблиц с различиями: $DIFF_COUNT"
echo ""
