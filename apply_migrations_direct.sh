#!/bin/bash

# Применение миграций напрямую - копируем файл на сервер и выполняем там
SERVER_IP="83.166.246.205"
SERVER_USER="root"
SERVER_PASSWORD="uOTC0OWjMVIoaRxI"
SERVER_DB_CONTAINER="aviapoint-postgres"
SERVER_DB_NAME="aviapoint"
SERVER_DB_USER="postgres"
LOCAL_MIGRATIONS_DIR="migrations"
REMOTE_TEMP_DIR="/tmp/migrations_apply"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Применение миграций напрямую на сервере...${NC}"
echo ""

# Функция для копирования файла
copy_file() {
    local local_file=$1
    local remote_file=$2
    
    if command -v sshpass >/dev/null 2>&1; then
        sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no "$local_file" $SERVER_USER@$SERVER_IP:"$remote_file" > /dev/null 2>&1
    else
        expect <<EOF > /dev/null 2>&1
set timeout 30
spawn scp -o StrictHostKeyChecking=no "$local_file" $SERVER_USER@$SERVER_IP:"$remote_file"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
    fi
}

# Функция для выполнения команды на сервере
run_on_server() {
    local cmd=$1
    if command -v sshpass >/dev/null 2>&1; then
        sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd" 2>&1
    else
        expect <<EOF 2>/dev/null | grep -v "^spawn\|^root@\|password:"
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
    fi
}

# Создаем временную директорию на сервере
run_on_server "mkdir -p $REMOTE_TEMP_DIR" > /dev/null 2>&1

# Список миграций для применения
MIGRATIONS=(
    "055_rename_market_products_to_aircraft_market.sql"
    "061_add_price_history_table.sql"
    "062_add_aircraft_market_publish_until.sql"
    "063_create_publication_settings_table.sql"
    "064_create_user_fcm_tokens_table.sql"
    "065_add_is_admin_to_profiles.sql"
)

for migration in "${MIGRATIONS[@]}"; do
    local_file="$LOCAL_MIGRATIONS_DIR/$migration"
    remote_file="$REMOTE_TEMP_DIR/$migration"
    
    if [ ! -f "$local_file" ]; then
        echo -e "${RED}✗ Файл не найден: $local_file${NC}"
        continue
    fi
    
    echo -e "${YELLOW}Применение: $migration${NC}"
    
    # Копируем файл на сервер
    copy_file "$local_file" "$remote_file"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Ошибка копирования файла${NC}"
        continue
    fi
    
    # Выполняем миграцию на сервере
    OUTPUT=$(run_on_server "cat $remote_file | docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME 2>&1")
    
    # Проверяем результат
    if echo "$OUTPUT" | grep -qiE "ERROR|FATAL"; then
        echo -e "${RED}✗ Ошибка:${NC}"
        echo "$OUTPUT" | grep -iE "ERROR|FATAL" | head -3
    else
        echo -e "${GREEN}✓ Выполнено${NC}"
    fi
    
    # Удаляем временный файл
    run_on_server "rm -f $remote_file" > /dev/null 2>&1
    echo ""
done

# Очищаем временную директорию
run_on_server "rm -rf $REMOTE_TEMP_DIR" > /dev/null 2>&1

# Проверяем результат
echo -e "${YELLOW}Проверка созданных таблиц:${NC}"
TABLES=("aircraft_market" "aircraft_market_price_history" "publication_settings" "user_fcm_tokens")
for table in "${TABLES[@]}"; do
    EXISTS=$(run_on_server "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table');\" 2>&1" | tr -d ' \n\r')
    if [ "$EXISTS" = "t" ]; then
        echo -e "  ${GREEN}✅ $table${NC}"
    else
        echo -e "  ${RED}❌ $table${NC}"
    fi
done
