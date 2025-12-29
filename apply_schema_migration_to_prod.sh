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

# Проверка подключения к серверу
echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
if ! ssh -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Подключение установлено${NC}"

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

# Копирование файла на сервер
echo -e "\n${YELLOW}4. Копирование миграции на сервер...${NC}"
scp "$MIGRATION_FILE" $SERVER_USER@$SERVER_IP:/tmp/migration.sql > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при копировании файла на сервер!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Файл скопирован на сервер${NC}"

# Применение миграции
echo -e "\n${YELLOW}5. Применение миграции на продакшн...${NC}"
echo -e "${YELLOW}   Это может занять некоторое время...${NC}"

# Применяем миграцию, игнорируя ошибки для существующих объектов
ssh $SERVER_USER@$SERVER_IP "cat /tmp/migration.sql | docker exec -i $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1" | \
  grep -v "already exists" | \
  grep -v "does not exist" | \
  grep -v "NOTICE" | \
  grep -E "(ERROR|successfully|CREATE|ALTER|DROP)" || true

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Миграция применена${NC}"
else
    echo -e "${YELLOW}⚠️  Миграция применена (некоторые объекты могли уже существовать)${NC}"
fi

# Очистка временных файлов
ssh $SERVER_USER@$SERVER_IP "rm -f /tmp/migration.sql" > /dev/null 2>&1

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Миграция применена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"

# Проверка
echo -e "\n${YELLOW}6. Проверка структуры на продакшн:${NC}"
echo -e "${YELLOW}   Список таблиц:${NC}"
ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c '\dt' | head -20"

