#!/bin/bash

# Скрипт для создания бэкапа базы данных на продакшн сервере
# Использование: ./backup_prod_database.sh [server_ip]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
SERVER_PASSWORD=${SERVER_PASSWORD:-"uOTC0OWjMVIoaRxI"}
SERVER_DB_CONTAINER="aviapoint-postgres"
DB_NAME="aviapoint"
DB_USER="postgres"
PROJECT_DIR="/home/aviapoint_server"
BACKUP_DIR="${PROJECT_DIR}/backups"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Создание бэкапа базы данных на продакшн${NC}"
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
        expect -f "$expect_file"
        local exit_code=$?
        rm -f "$expect_file"
        return $exit_code
    else
        echo -e "${YELLOW}⚠️  sshpass и expect не установлены. Используется обычный SSH${NC}" >&2
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$@"
    fi
}

# Проверка подключения к серверу
echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
if ! ssh_with_password $SERVER_USER@$SERVER_IP "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Подключение установлено${NC}"

# Поиск контейнера PostgreSQL
echo -e "\n${YELLOW}2. Поиск Docker контейнера PostgreSQL...${NC}"
POSSIBLE_NAMES=("aviapoint-postgres" "server-side-postgres-database" "postgres" "aviapoint_db")
SERVER_DB_CONTAINER=""

for name in "${POSSIBLE_NAMES[@]}"; do
    CONTAINER_EXISTS=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker ps -a --format '{{.Names}}' | grep -q '^${name}$' && echo 'yes' || echo 'no'" 2>/dev/null)
    if [ "$CONTAINER_EXISTS" = "yes" ]; then
        SERVER_DB_CONTAINER="$name"
        break
    fi
done

# Если не нашли по имени, ищем любой контейнер с postgres
if [ -z "$SERVER_DB_CONTAINER" ]; then
    POSTGRES_CONTAINER=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker ps -a --format '{{.Names}}' | grep -i postgres | head -1" 2>/dev/null | grep -v "^spawn\|^root@\|password:" | head -1)
    if [ -n "$POSTGRES_CONTAINER" ] && [ "$POSTGRES_CONTAINER" != "yes" ] && [ "$POSTGRES_CONTAINER" != "no" ]; then
        SERVER_DB_CONTAINER="$POSTGRES_CONTAINER"
    fi
fi

if [ -z "$SERVER_DB_CONTAINER" ]; then
    echo -e "${RED}❌ Контейнер PostgreSQL не найден на сервере!${NC}"
    echo -e "${YELLOW}   Доступные контейнеры:${NC}"
    ssh_with_password $SERVER_USER@$SERVER_IP "docker ps -a --format '{{.Names}}'" 2>/dev/null | head -10
    exit 1
fi
echo -e "${GREEN}✅ Найден контейнер: $SERVER_DB_CONTAINER${NC}"

# Создание директории для бэкапов на сервере
echo -e "\n${YELLOW}3. Создание директории для бэкапов...${NC}"
ssh_with_password $SERVER_USER@$SERVER_IP "mkdir -p $BACKUP_DIR"
echo -e "${GREEN}✅ Директория создана${NC}"

# Создание бэкапа
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOCAL_BACKUP_DIR="./backups"
mkdir -p "$LOCAL_BACKUP_DIR"
LOCAL_BACKUP_FILE_SQL="${LOCAL_BACKUP_DIR}/aviapoint_backup_${TIMESTAMP}.sql"
LOCAL_BACKUP_FILE="${LOCAL_BACKUP_DIR}/aviapoint_backup_${TIMESTAMP}.sql.gz"
REMOTE_BACKUP_FILE="${BACKUP_DIR}/aviapoint_backup_${TIMESTAMP}.sql.gz"

echo -e "\n${YELLOW}4. Создание бэкапа базы данных...${NC}"
echo -e "${BLUE}   Контейнер: $SERVER_DB_CONTAINER${NC}"
echo -e "${BLUE}   Локальный файл: $LOCAL_BACKUP_FILE_SQL${NC}"

# Выполняем pg_dump на сервере и сохраняем локально
echo -e "${YELLOW}   Выполняется pg_dump (это может занять некоторое время)...${NC}"
if command -v sshpass >/dev/null 2>&1; then
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "docker exec -i -e PGPASSWORD=postgres $SERVER_DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME --clean --if-exists --create --format=plain --no-owner --no-privileges" > "$LOCAL_BACKUP_FILE_SQL" 2>&1
else
    # Используем expect для передачи команды
    expect <<EOF > /dev/null 2>&1
set timeout 600
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "docker exec -i -e PGPASSWORD=postgres $SERVER_DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME --clean --if-exists --create --format=plain --no-owner --no-privileges"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
    # Сохраняем вывод в файл
    expect <<EOF > "$LOCAL_BACKUP_FILE_SQL" 2>&1
set timeout 600
log_file -noappend "$LOCAL_BACKUP_FILE_SQL"
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "docker exec -i -e PGPASSWORD=postgres $SERVER_DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME --clean --if-exists --create --format=plain --no-owner --no-privileges"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
log_file
EOF
    # Удаляем служебные строки из файла
    sed -i '' '/^spawn/d; /^root@/d; /^password:/d; /^docker:/d; /^Usage:/d; /^See/d' "$LOCAL_BACKUP_FILE_SQL" 2>/dev/null || sed -i '/^spawn/d; /^root@/d; /^password:/d; /^docker:/d; /^Usage:/d; /^See/d' "$LOCAL_BACKUP_FILE_SQL" 2>/dev/null
fi

# Проверяем, что файл создан и не пустой
sleep 1
FILE_SIZE=$(stat -f%z "$LOCAL_BACKUP_FILE_SQL" 2>/dev/null || stat -c%s "$LOCAL_BACKUP_FILE_SQL" 2>/dev/null || echo '0')
FILE_SIZE=$(echo "$FILE_SIZE" | tr -d '[:space:]')

# Проверяем, что это не ошибка (первые строки должны содержать SQL)
FIRST_LINES=$(head -5 "$LOCAL_BACKUP_FILE_SQL" 2>/dev/null | grep -iE "CREATE|--|pg_dump|PostgreSQL" | wc -l | tr -d '[:space:]')

if [ -z "$FILE_SIZE" ] || [ "$FILE_SIZE" = "0" ] || [ "$FILE_SIZE" -lt 100 ] || [ "$FIRST_LINES" = "0" ]; then
    echo -e "${RED}❌ Ошибка: бэкап не создан или содержит ошибки (размер: $FILE_SIZE байт)${NC}"
    echo -e "${YELLOW}   Содержимое файла:${NC}"
    head -20 "$LOCAL_BACKUP_FILE_SQL"
    rm -f "$LOCAL_BACKUP_FILE_SQL"
    exit 1
fi

echo -e "${GREEN}✅ Бэкап создан (размер: $FILE_SIZE байт)${NC}"

# Сжимаем бэкап
echo -e "${YELLOW}📦 Сжатие бэкапа...${NC}"
gzip -f "$LOCAL_BACKUP_FILE_SQL"

# Копируем бэкап на сервер для хранения
echo -e "${YELLOW}📤 Копирование бэкапа на сервер...${NC}"
SCP_SUCCESS=false
if command -v sshpass >/dev/null 2>&1; then
    if sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no "$LOCAL_BACKUP_FILE" $SERVER_USER@$SERVER_IP:"$REMOTE_BACKUP_FILE" 2>/dev/null; then
        SCP_SUCCESS=true
    fi
else
    expect <<EOF > /dev/null 2>&1
set timeout 300
spawn scp -o StrictHostKeyChecking=no "$LOCAL_BACKUP_FILE" $SERVER_USER@$SERVER_IP:"$REMOTE_BACKUP_FILE"
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
    if [ $? -eq 0 ]; then
        SCP_SUCCESS=true
    fi
fi

if [ "$SCP_SUCCESS" = false ]; then
    echo -e "${YELLOW}⚠️  Не удалось скопировать бэкап на сервер, но локальный файл сохранен${NC}"
else
    echo -e "${GREEN}✅ Бэкап скопирован на сервер${NC}"
fi

BACKUP_FILE="$LOCAL_BACKUP_FILE"

BACKUP_FILE="$LOCAL_BACKUP_FILE"

if [ -f "$BACKUP_FILE" ]; then
    echo -e "${GREEN}✅ Бэкап успешно создан и скопирован локально${NC}"
    
    # Размер файла
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}📊 Размер файла: $FILE_SIZE${NC}"
    
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Бэкап успешно создан!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "\n${YELLOW}📌 Локальный файл:${NC} $BACKUP_FILE"
    echo -e "${YELLOW}📌 Файл на сервере:${NC} $REMOTE_BACKUP_FILE_GZ"
    echo ""
    echo -e "${YELLOW}📌 Для восстановления используйте:${NC}"
    echo "  gunzip -c $BACKUP_FILE | docker exec -i $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME"
    echo ""
else
    echo -e "${RED}❌ Ошибка при создании бэкапа${NC}"
    exit 1
fi
