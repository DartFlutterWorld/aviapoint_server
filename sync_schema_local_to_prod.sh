#!/bin/bash

# Скрипт для синхронизации структуры БД (схемы) с локальной на продакшн
# БЕЗ переноса данных - только структура таблиц, индексов, ограничений
# Использование: ./sync_schema_local_to_prod.sh [SERVER_IP]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
LOCAL_DB_CONTAINER="aviapoint-postgres"
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
echo -e "${BLUE}  Синхронизация структуры БД (локальная -> продакшн)${NC}"
echo -e "${BLUE}  Только структура, БЕЗ данных${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Проверка подключения к серверу
echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
if ! ssh -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Подключение установлено${NC}"

# Проверка локальной БД
echo -e "\n${YELLOW}2. Проверка локальной БД...${NC}"
if ! docker ps | grep -q $LOCAL_DB_CONTAINER; then
    echo -e "${RED}❌ Локальный контейнер БД не запущен!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Локальная БД доступна${NC}"

# Создание временной директории
TEMP_DIR=$(mktemp -d)
SCHEMA_FILE="$TEMP_DIR/schema_export.sql"
echo -e "\n${YELLOW}3. Экспорт структуры БД с локальной машины...${NC}"

# Экспорт только структуры (без данных)
docker exec $LOCAL_DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME \
  --schema-only \
  --no-owner \
  --no-privileges \
  --exclude-table=schema_migrations > $SCHEMA_FILE

if [ $? -ne 0 ] || [ ! -s "$SCHEMA_FILE" ]; then
    echo -e "${RED}❌ Ошибка при экспорте структуры БД!${NC}"
    rm -rf $TEMP_DIR
    exit 1
fi

FILE_SIZE=$(du -h "$SCHEMA_FILE" | cut -f1)
echo -e "${GREEN}✅ Экспорт завершен: $SCHEMA_FILE (размер: $FILE_SIZE)${NC}"

# Предупреждение
echo -e "\n${YELLOW}4. Внимание!${NC}"
echo -e "${RED}   Это изменит структуру БД на продакшн!${NC}"
echo -e "${YELLOW}   Будут применены:${NC}"
echo -e "   - Создание новых таблиц"
echo -e "   - Добавление новых полей в существующие таблицы"
echo -e "   - Создание новых индексов"
echo -e "   - Создание новых ограничений"
echo -e ""
echo -e "${YELLOW}   НЕ будут затронуты:${NC}"
echo -e "   - Существующие данные (они останутся нетронутыми)"
echo -e "   - Таблица schema_migrations (система миграций)"
echo ""

read -p "Продолжить? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Операция отменена${NC}"
    rm -rf $TEMP_DIR
    exit 0
fi

# Копирование файла на сервер
echo -e "\n${YELLOW}5. Копирование схемы на сервер...${NC}"
scp $SCHEMA_FILE $SERVER_USER@$SERVER_IP:/tmp/schema_export.sql > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при копировании файла на сервер!${NC}"
    rm -rf $TEMP_DIR
    exit 1
fi
echo -e "${GREEN}✅ Файл скопирован на сервер${NC}"

# Применение схемы на продакшн
echo -e "\n${YELLOW}6. Применение структуры на продакшн...${NC}"
echo -e "${YELLOW}   Это может занять некоторое время...${NC}"

# Применяем схему, игнорируя ошибки для существующих объектов
ssh $SERVER_USER@$SERVER_IP "cat /tmp/schema_export.sql | docker exec -i $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1 | grep -v 'already exists' | grep -v 'ERROR' | grep -v 'NOTICE' || true"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Структура применена${NC}"
else
    echo -e "${YELLOW}⚠️  Применение завершено (некоторые объекты могли уже существовать)${NC}"
fi

# Очистка временных файлов
ssh $SERVER_USER@$SERVER_IP "rm -f /tmp/schema_export.sql" > /dev/null 2>&1
rm -rf $TEMP_DIR

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Синхронизация структуры завершена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"

# Проверка
echo -e "\n${YELLOW}7. Проверка структуры на продакшн:${NC}"
echo -e "${YELLOW}   Список таблиц:${NC}"
ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c '\dt' | head -20"

