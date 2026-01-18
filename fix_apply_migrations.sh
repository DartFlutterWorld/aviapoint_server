#!/bin/bash

# Простой скрипт для применения миграций с проверкой результата
SERVER_IP="83.166.246.205"
SERVER_USER="root"
SERVER_PASSWORD="uOTC0OWjMVIoaRxI"
SERVER_DB_CONTAINER="aviapoint-postgres"
SERVER_DB_NAME="aviapoint"
SERVER_DB_USER="postgres"
REMOTE_MIGRATIONS_DIR="/home/aviapoint_server/migrations"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Применение миграций на сервере...${NC}"
echo ""

# Применяем миграции по одной с проверкой
apply_migration() {
    local migration_file=$1
    local remote_file="$REMOTE_MIGRATIONS_DIR/$migration_file"
    
    echo -e "${YELLOW}Применение: $migration_file${NC}"
    
    # Используем sshpass для прямого выполнения
    if command -v sshpass >/dev/null 2>&1; then
        OUTPUT=$(sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "cat $remote_file | docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME 2>&1" 2>/dev/null)
    else
        # Используем expect
        OUTPUT=$(expect <<EOF 2>/dev/null | grep -v "^spawn\|^root@\|password:"
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "cat $remote_file | docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME 2>&1"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    eof
}
EOF
)
    fi
    
    # Проверяем результат
    if echo "$OUTPUT" | grep -qiE "ERROR|FATAL"; then
        echo -e "${RED}✗ Ошибка:${NC}"
        echo "$OUTPUT" | grep -iE "ERROR|FATAL" | head -3
        return 1
    else
        echo -e "${GREEN}✓ Команда выполнена${NC}"
        return 0
    fi
}

# Проверяем существование таблицы
check_table() {
    local table_name=$1
    local result
    if command -v sshpass >/dev/null 2>&1; then
        result=$(sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table_name');\" 2>&1" 2>/dev/null | tr -d ' \n\r')
    else
        result=$(expect <<EOF 2>/dev/null | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r'
set timeout 10
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table_name');\" 2>&1"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    eof
}
EOF
)
    fi
    
    if [ "$result" = "t" ]; then
        return 0
    else
        return 1
    fi
}

# Применяем миграции
MIGRATIONS=(
    "055_rename_market_products_to_aircraft_market.sql"
    "061_add_price_history_table.sql"
    "062_add_aircraft_market_publish_until.sql"
    "063_create_publication_settings_table.sql"
    "064_create_user_fcm_tokens_table.sql"
    "065_add_is_admin_to_profiles.sql"
)

for migration in "${MIGRATIONS[@]}"; do
    apply_migration "$migration"
    echo ""
done

# Проверяем результат
echo -e "${YELLOW}Проверка созданных таблиц:${NC}"
if check_table "aircraft_market"; then
    echo -e "  ${GREEN}✅ aircraft_market${NC}"
else
    echo -e "  ${RED}❌ aircraft_market${NC}"
fi

if check_table "aircraft_market_price_history"; then
    echo -e "  ${GREEN}✅ aircraft_market_price_history${NC}"
else
    echo -e "  ${RED}❌ aircraft_market_price_history${NC}"
fi

if check_table "publication_settings"; then
    echo -e "  ${GREEN}✅ publication_settings${NC}"
else
    echo -e "  ${RED}❌ publication_settings${NC}"
fi

if check_table "user_fcm_tokens"; then
    echo -e "  ${GREEN}✅ user_fcm_tokens${NC}"
else
    echo -e "  ${RED}❌ user_fcm_tokens${NC}"
fi
