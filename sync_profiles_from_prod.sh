#!/bin/bash

# Скрипт для копирования таблицы profiles с продакшн на локальную машину
# Использование: ./sync_profiles_from_prod.sh [SERVER_IP]

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
echo -e "${BLUE}  Синхронизация таблицы profiles с продакшн${NC}"
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
EXPORT_FILE="$TEMP_DIR/profiles_export.sql"
echo -e "\n${YELLOW}3. Экспорт таблицы profiles с продакшн...${NC}"

# Экспорт таблицы profiles с сервера (только данные)
ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME \
  -t profiles \
  --data-only \
  --column-inserts" > $EXPORT_FILE

if [ $? -ne 0 ] || [ ! -s "$EXPORT_FILE" ]; then
    echo -e "${RED}❌ Ошибка при экспорте таблицы profiles!${NC}"
    rm -rf $TEMP_DIR
    exit 1
fi

FILE_SIZE=$(du -h "$EXPORT_FILE" | cut -f1)
echo -e "${GREEN}✅ Экспорт завершен: $EXPORT_FILE (размер: $FILE_SIZE)${NC}"

# Подтверждение перед заменой локальных данных
echo -e "\n${YELLOW}4. Внимание!${NC}"
echo -e "${RED}   Это заменит все данные в локальной таблице profiles!${NC}"
echo -e "${YELLOW}   Текущее количество записей в локальной БД:${NC}"
LOCAL_COUNT=$(docker exec $LOCAL_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM profiles;" 2>/dev/null | tr -d ' ' || echo "0")
echo -e "   Локально: ${LOCAL_COUNT} записей"

# Подсчет записей на сервере
SERVER_COUNT=$(ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c 'SELECT COUNT(*) FROM profiles;'" 2>/dev/null | tr -d ' ' || echo "0")
echo -e "   На сервере: ${SERVER_COUNT} записей"

read -p "Продолжить? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Операция отменена${NC}"
    rm -rf $TEMP_DIR
    exit 0
fi

# Очистка локальной таблицы
echo -e "\n${YELLOW}5. Очистка локальной таблицы profiles...${NC}"
docker exec $LOCAL_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "TRUNCATE TABLE profiles CASCADE;" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Локальная таблица очищена${NC}"
else
    echo -e "${RED}❌ Ошибка при очистке таблицы!${NC}"
    rm -rf $TEMP_DIR
    exit 1
fi

# Импорт данных
echo -e "\n${YELLOW}6. Импорт данных в локальную БД...${NC}"
cat $EXPORT_FILE | docker exec -i $LOCAL_DB_CONTAINER psql -U $DB_USER -d $DB_NAME > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Данные импортированы${NC}"
    
    # Проверка количества записей после импорта
    NEW_COUNT=$(docker exec $LOCAL_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM profiles;" 2>/dev/null | tr -d ' ' || echo "0")
    echo -e "${GREEN}   Импортировано записей: ${NEW_COUNT}${NC}"
else
    echo -e "${RED}❌ Ошибка при импорте данных!${NC}"
    rm -rf $TEMP_DIR
    exit 1
fi

# Очистка временных файлов
rm -rf $TEMP_DIR

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Синхронизация завершена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"

