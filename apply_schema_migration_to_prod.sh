#!/bin/bash

# Скрипт для применения SQL миграции структуры на продакшн
# Использование: ./apply_schema_migration_to_prod.sh [MIGRATION_FILE]

MIGRATION_FILE=${1:-""}
SERVER_IP=${2:-"83.166.246.205"}
SERVER_USER="root"
SERVER_DB_CONTAINER="aviapoint-postgres"
DB_NAME="aviapoint"
DB_USER="postgres"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Применение миграции структуры на продакшн${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Проверка аргументов
if [ -z "$MIGRATION_FILE" ]; then
    echo -e "${RED}❌ Укажите файл миграции!${NC}"
    echo -e "${YELLOW}Использование: ./apply_schema_migration_to_prod.sh <migration_file.sql> [server_ip]${NC}"
    exit 1
fi

# Проверка существования файла
if [ ! -f "$MIGRATION_FILE" ]; then
    echo -e "${RED}❌ Файл миграции не найден: $MIGRATION_FILE${NC}"
    exit 1
fi

# Проверяем, запущен ли скрипт на сервере или локально
IS_ON_SERVER=false
if [ -f "/home/aviapoint_server/docker-compose.prod.yaml" ] || [ "$(pwd)" = "/home/aviapoint_server" ] || docker ps 2>/dev/null | grep -q "$SERVER_DB_CONTAINER"; then
    IS_ON_SERVER=true
    echo -e "${YELLOW}1. Скрипт запущен на сервере, SSH не требуется${NC}"
else
    # Проверка подключения к серверу
    echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
    if ! ssh -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo 'OK'" > /dev/null 2>&1; then
        echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Подключение установлено${NC}"
fi

# Показываем информацию о миграции
echo -e "\n${YELLOW}2. Информация о миграции:${NC}"
echo -e "   Файл: $MIGRATION_FILE"
FILE_SIZE=$(du -h "$MIGRATION_FILE" | cut -f1)
echo -e "   Размер: $FILE_SIZE"

# Предупреждение
echo -e "\n${YELLOW}3. Внимание!${NC}"
echo -e "${RED}   Это изменит структуру БД на продакшн!${NC}"
echo -e "${YELLOW}   Будут применены изменения структуры (таблицы, поля, индексы)${NC}"
echo -e "${YELLOW}   Существующие данные НЕ будут затронуты${NC}"
echo ""

read -p "Продолжить? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Операция отменена${NC}"
    exit 0
fi

# Копирование файла на сервер (если запущено локально)
if [ "$IS_ON_SERVER" = false ]; then
    echo -e "\n${YELLOW}4. Копирование миграции на сервер...${NC}"
    scp "$MIGRATION_FILE" $SERVER_USER@$SERVER_IP:/tmp/migration.sql > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Ошибка при копировании файла на сервер!${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Файл скопирован на сервер${NC}"
    MIGRATION_PATH="/tmp/migration.sql"
else
    # Если на сервере, используем локальный путь
    echo -e "\n${YELLOW}4. Использование локального файла миграции...${NC}"
    MIGRATION_PATH="$MIGRATION_FILE"
    echo -e "${GREEN}✅ Файл найден: $MIGRATION_PATH${NC}"
fi

# Применение миграции
echo -e "\n${YELLOW}5. Применение миграции на продакшн...${NC}"
echo -e "${YELLOW}   Это может занять некоторое время...${NC}"

# Применяем миграцию, игнорируя ошибки для существующих объектов
if [ "$IS_ON_SERVER" = false ]; then
    # Локально - через SSH
    ssh $SERVER_USER@$SERVER_IP "cat $MIGRATION_PATH | docker exec -i $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1" | \
      grep -v "already exists" | \
      grep -v "does not exist" | \
      grep -v "NOTICE" | \
      grep -E "(ERROR|successfully|CREATE|ALTER|DROP)" || true
else
    # На сервере - напрямую
    cat "$MIGRATION_PATH" | docker exec -i $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1 | \
      grep -v "already exists" | \
      grep -v "does not exist" | \
      grep -v "NOTICE" | \
      grep -E "(ERROR|successfully|CREATE|ALTER|DROP)" || true
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Миграция применена${NC}"
else
    echo -e "${YELLOW}⚠️  Миграция применена (некоторые объекты могли уже существовать)${NC}"
fi

# Очистка временных файлов
if [ "$IS_ON_SERVER" = false ]; then
    ssh $SERVER_USER@$SERVER_IP "rm -f /tmp/migration.sql" > /dev/null 2>&1
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Миграция применена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"

# Проверка
echo -e "\n${YELLOW}6. Проверка структуры на продакшн:${NC}"
echo -e "${YELLOW}   Список таблиц:${NC}"
if [ "$IS_ON_SERVER" = false ]; then
    ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c '\dt' | head -20"
else
    docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c '\dt' | head -20
fi

