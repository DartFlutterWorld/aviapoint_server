#!/bin/bash

# Скрипт для проверки файлов миграций на сервере
# Использование: ./check_migrations_on_server.sh [server_ip]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"

echo "Проверка файлов миграций на сервере..."
echo ""

# Проверяем, запущен ли скрипт на сервере или локально
IS_ON_SERVER=false
if [ -f "/home/aviapoint_server/docker-compose.prod.yaml" ] || [ "$(pwd)" = "/home/aviapoint_server" ]; then
    IS_ON_SERVER=true
    MIGRATIONS_DIR="migrations"
else
    MIGRATIONS_DIR="/home/aviapoint_server/migrations"
fi

# Список обязательных файлов миграций
REQUIRED_FILES=(
    "create_payments_table.sql"
    "create_subscriptions_table.sql"
    "create_on_the_way_tables.sql"
    "create_airports_table.sql"
    "recreate_airports_table_aopa.sql"
)

echo "Проверяем наличие файлов:"
echo ""

MISSING_COUNT=0
EXISTS_COUNT=0

for file in "${REQUIRED_FILES[@]}"; do
    if [ "$IS_ON_SERVER" = false ]; then
        if ssh $SERVER_USER@$SERVER_IP "[ -f \"$MIGRATIONS_DIR/$file\" ]" 2>/dev/null; then
            echo "✅ $file"
            ((EXISTS_COUNT++))
        else
            echo "❌ $file - НЕ НАЙДЕН"
            ((MISSING_COUNT++))
        fi
    else
        if [ -f "$MIGRATIONS_DIR/$file" ]; then
            echo "✅ $file"
            ((EXISTS_COUNT++))
        else
            echo "❌ $file - НЕ НАЙДЕН"
            ((MISSING_COUNT++))
        fi
    fi
done

echo ""
echo "Статистика:"
echo "  Найдено: $EXISTS_COUNT"
echo "  Отсутствует: $MISSING_COUNT"

if [ "$MISSING_COUNT" -gt 0 ]; then
    echo ""
    echo "⚠️  Некоторые файлы отсутствуют!"
    if [ "$IS_ON_SERVER" = false ]; then
        echo "Выполните на сервере: git pull"
    else
        echo "Выполните: git pull"
    fi
fi

