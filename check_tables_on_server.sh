#!/bin/bash

# Скрипт для проверки таблиц на сервере
SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
SERVER_PASSWORD="uOTC0OWjMVIoaRxI"
SERVER_DB_CONTAINER="aviapoint-postgres"
SERVER_DB_NAME="aviapoint"
SERVER_DB_USER="postgres"

# Функция для SSH с паролем
ssh_with_password() {
    local cmd="$1"
    if command -v sshpass >/dev/null 2>&1; then
        sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd" 2>/dev/null
    elif command -v expect >/dev/null 2>&1; then
        expect <<EOF 2>/dev/null | grep -v "^spawn\|^root@\|password:"
set timeout 10
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    eof
}
EOF
    else
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd"
    fi
}

echo "🔍 Проверка таблиц на сервере..."
echo ""

# Проверяем новые таблицы
echo "1. Проверка новых таблиц:"
NEW_TABLES=("aircraft_market" "price_history" "publication_settings" "user_fcm_tokens")
for table in "${NEW_TABLES[@]}"; do
    RESULT=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table');\" 2>&1" | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r')
    if [ "$RESULT" = "t" ]; then
        echo "   ✅ $table - существует"
    else
        echo "   ❌ $table - НЕ существует"
    fi
done

echo ""
echo "2. Проверка переименования market_products → aircraft_market:"
OLD_TABLE=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'market_products');\" 2>&1" | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r')
if [ "$OLD_TABLE" = "t" ]; then
    echo "   ⚠️  market_products - все еще существует (не переименована)"
else
    echo "   ✅ market_products - не существует (переименована)"
fi

echo ""
echo "3. Проверка миграций в schema_migrations:"
MIGRATIONS=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT version, name FROM schema_migrations WHERE version IN ('055', '061', '062', '063', '064', '065') ORDER BY version;\" 2>&1" | grep -v "^spawn\|^root@\|password:" | grep -E "^[0-9]{3}")
if [ -z "$MIGRATIONS" ]; then
    echo "   ❌ Миграции не найдены в schema_migrations"
else
    echo "   ✅ Найденные миграции:"
    echo "$MIGRATIONS" | while read -r line; do
        if [ ! -z "$line" ]; then
            echo "      - $line"
        fi
    done
fi

echo ""
echo "4. Проверка поля published_until в aircraft_market:"
if [ "$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'aircraft_market' AND column_name = 'published_until');\" 2>&1" | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r')" = "t" ]; then
    echo "   ✅ Поле published_until существует"
else
    echo "   ❌ Поле published_until НЕ существует"
fi

echo ""
echo "5. Проверка поля is_admin в profiles:"
if [ "$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'is_admin');\" 2>&1" | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r')" = "t" ]; then
    echo "   ✅ Поле is_admin существует"
else
    echo "   ❌ Поле is_admin НЕ существует"
fi
