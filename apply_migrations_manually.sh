#!/bin/bash

# Скрипт для ручного применения миграций на сервере с детальным выводом ошибок
SERVER_IP=${1:-"83.166.246.205"}
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

ssh_with_password() {
    local cmd="$1"
    if command -v sshpass >/dev/null 2>&1; then
        sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd" 2>&1
    elif command -v expect >/dev/null 2>&1; then
        expect <<EOF 2>/dev/null | grep -v "^spawn\|^root@\|password:"
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    eof
}
EOF
    fi
}

echo -e "${YELLOW}Применение миграций на сервере...${NC}"
echo ""

# Список миграций для применения в правильном порядке
MIGRATIONS=(
    "055_rename_market_products_to_aircraft_market.sql"
    "061_add_price_history_table.sql"
    "062_add_aircraft_market_publish_until.sql"
    "063_create_publication_settings_table.sql"
    "064_create_user_fcm_tokens_table.sql"
    "065_add_is_admin_to_profiles.sql"
)

for migration in "${MIGRATIONS[@]}"; do
    echo -e "${YELLOW}Применение: $migration${NC}"
    remote_file="$REMOTE_MIGRATIONS_DIR/$migration"
    
    # Применяем миграцию и получаем полный вывод
    RESULT=$(ssh_with_password "cat $remote_file | docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME 2>&1")
    
    # Проверяем результат
    if echo "$RESULT" | grep -qiE "ERROR|FATAL"; then
        echo -e "${RED}✗ Ошибка:${NC}"
        echo "$RESULT" | grep -iE "ERROR|FATAL" | head -5
    else
        echo -e "${GREEN}✓ Успешно${NC}"
        # Показываем предупреждения, если есть
        if echo "$RESULT" | grep -qiE "WARNING|NOTICE"; then
            echo "$RESULT" | grep -iE "WARNING|NOTICE" | head -3
        fi
    fi
    echo ""
done

# Проверяем результат
echo -e "${YELLOW}Проверка созданных таблиц:${NC}"
TABLES=("aircraft_market" "aircraft_market_price_history" "publication_settings" "user_fcm_tokens")
for table in "${TABLES[@]}"; do
    EXISTS=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table');\" 2>&1" | tr -d ' \n\r')
    if [ "$EXISTS" = "t" ]; then
        echo -e "  ${GREEN}✅ $table${NC}"
    else
        echo -e "  ${RED}❌ $table${NC}"
    fi
done
