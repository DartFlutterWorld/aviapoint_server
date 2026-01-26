#!/bin/bash

# Скрипт для исправления конфликтов git на сервере
# Откатывает локальные изменения в миграциях и делает git pull

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
SERVER_PASSWORD=${SERVER_PASSWORD:-"uOTC0OWjMVIoaRxI"}
PROJECT_DIR="/home/aviapoint_server"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Исправление конфликтов git на сервере${NC}"
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

echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
if ! ssh_with_password $SERVER_USER@$SERVER_IP "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Подключение установлено${NC}\n"

echo -e "${YELLOW}2. Проверка статуса git на сервере...${NC}"
GIT_STATUS=$(ssh_with_password $SERVER_USER@$SERVER_IP "cd $PROJECT_DIR && git status --short" 2>/dev/null)
echo "$GIT_STATUS"

echo -e "\n${YELLOW}3. Откат локальных изменений в миграциях...${NC}"
RESET_OUTPUT=$(ssh_with_password $SERVER_USER@$SERVER_IP "cd $PROJECT_DIR && git reset --hard HEAD" 2>/dev/null)

if echo "$RESET_OUTPUT" | grep -q "HEAD is now\|Already up to date"; then
    echo -e "${GREEN}✅ Локальные изменения откачены${NC}"
else
    echo -e "${YELLOW}⚠️  Пробуем альтернативный способ...${NC}"
    # Пробуем откатить конкретные файлы
    ssh_with_password $SERVER_USER@$SERVER_IP "cd $PROJECT_DIR && git checkout HEAD -- migrations/055_rename_market_products_to_aircraft_market.sql migrations/056_rename_flight_hours_and_add_engine_power.sql migrations/064_create_user_fcm_tokens_table.sql" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Локальные изменения откачены${NC}"
    else
        echo -e "${RED}❌ Ошибка при откате изменений${NC}"
        exit 1
    fi
fi

echo -e "\n${YELLOW}4. Выполнение git pull...${NC}"
PULL_OUTPUT=$(ssh_with_password $SERVER_USER@$SERVER_IP "cd $PROJECT_DIR && git pull" 2>/dev/null)

if echo "$PULL_OUTPUT" | grep -q "Already up to date\|Updating\|Fast-forward"; then
    echo -e "${GREEN}✅ Git pull выполнен успешно${NC}"
    echo "$PULL_OUTPUT" | tail -5
else
    echo -e "${RED}❌ Ошибка при git pull${NC}"
    echo "$PULL_OUTPUT"
    exit 1
fi

echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Конфликты git исправлены!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
