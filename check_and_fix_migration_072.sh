#!/bin/bash

# Скрипт для проверки и исправления статуса миграции 072 на сервере

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
SERVER_PASSWORD=${SERVER_PASSWORD:-"uOTC0OWjMVIoaRxI"}
DB_CONTAINER="aviapoint-postgres"
DB_NAME="aviapoint"
DB_USER="postgres"

echo "🔍 Проверка статуса миграции 072 на сервере..."

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

# Проверяем, записана ли миграция 072
echo "1. Проверка записи миграции 072 в schema_migrations..."
MIGRATION_EXISTS=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker exec -e PGPASSWORD=$SERVER_PASSWORD $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c \"SELECT EXISTS (SELECT 1 FROM schema_migrations WHERE version = '072');\"" 2>/dev/null | tr -d ' \n\r')

if [ "$MIGRATION_EXISTS" = "t" ]; then
    echo "✅ Миграция 072 уже записана в schema_migrations"
    echo "   Миграция не должна запускаться повторно"
else
    echo "❌ Миграция 072 НЕ записана в schema_migrations"
    echo ""
    echo "2. Записываем миграцию 072 в schema_migrations..."
    
    RESULT=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker exec -e PGPASSWORD=$SERVER_PASSWORD $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c \"INSERT INTO schema_migrations (version, name) VALUES ('072', 'sync_all_tables_and_fields') ON CONFLICT (version) DO NOTHING; SELECT 'OK';\"" 2>/dev/null | grep -v "^spawn\|^root@\|password:" | grep -i "ok\|INSERT\|insert" | head -1)
    
    if [ $? -eq 0 ]; then
        echo "✅ Миграция 072 записана в schema_migrations"
        echo "   Теперь она не будет запускаться повторно"
    else
        echo "❌ Ошибка при записи миграции"
    fi
fi

echo ""
echo "3. Проверка существования индексов на airports..."
INDEXES=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker exec -e PGPASSWORD=$SERVER_PASSWORD $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c \"SELECT indexname FROM pg_indexes WHERE schemaname = 'public' AND tablename = 'airports' AND indexname LIKE 'idx_airports%' ORDER BY indexname;\"" 2>/dev/null | grep -v "^spawn\|^root@\|password:" | sed 's/^[[:space:]]*//' | sed '/^$/d')

if [ ! -z "$INDEXES" ]; then
    echo "✅ Найдены индексы на airports:"
    echo "$INDEXES" | while read idx; do
        if [ ! -z "$idx" ]; then
            echo "   - $idx"
        fi
    done
else
    echo "⚠️  Индексы на airports не найдены (возможно, они создаются с другими именами)"
fi

echo ""
echo "✅ Проверка завершена"
