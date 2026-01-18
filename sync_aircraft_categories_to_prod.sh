#!/bin/bash

# Скрипт для синхронизации таблиц aircraft_main_categories и aircraft_subcategories
# Создает структуру и синхронизирует данные
SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
SERVER_PASSWORD="uOTC0OWjMVIoaRxI"
SERVER_DB_CONTAINER="aviapoint-postgres"
SERVER_DB_NAME="aviapoint"
SERVER_DB_USER="postgres"
LOCAL_DB_CONTAINER="aviapoint-postgres"
LOCAL_DB_NAME="aviapoint"
LOCAL_DB_USER="postgres"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Синхронизация aircraft_main_categories и aircraft_subcategories${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Функция для SSH с паролем
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
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
    else
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "$cmd"
    fi
}

# Шаг 1: Создание структуры таблиц на сервере
echo -e "${YELLOW}1. Создание структуры таблиц на сервере...${NC}"

CREATE_TABLES_SQL="
BEGIN;

-- Создание таблицы aircraft_main_categories
CREATE TABLE IF NOT EXISTS aircraft_main_categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT NOT NULL
);

-- Создание последовательности для aircraft_main_categories
CREATE SEQUENCE IF NOT EXISTS aircraft_main_category_id_seq OWNED BY aircraft_main_categories.id;
ALTER TABLE aircraft_main_categories ALTER COLUMN id SET DEFAULT nextval('aircraft_main_category_id_seq'::regclass);

-- Создание таблицы aircraft_subcategories
CREATE TABLE IF NOT EXISTS aircraft_subcategories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT NOT NULL,
    main_categories_id INTEGER NOT NULL,
    icon TEXT NOT NULL,
    CONSTRAINT aircraft_subcategories_categories_id_fkey 
        FOREIGN KEY (main_categories_id) 
        REFERENCES aircraft_main_categories(id)
);

-- Создание последовательности для aircraft_subcategories
CREATE SEQUENCE IF NOT EXISTS aircraft_subcategories_id_seq OWNED BY aircraft_subcategories.id;
ALTER TABLE aircraft_subcategories ALTER COLUMN id SET DEFAULT nextval('aircraft_subcategories_id_seq'::regclass);

COMMIT;
"

# Применяем структуру на сервере
RESULT=$(echo "$CREATE_TABLES_SQL" | ssh_with_password "docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME 2>&1" | grep -v "^spawn\|^root@\|password:")

if echo "$RESULT" | grep -qiE "ERROR|FATAL"; then
    echo -e "${YELLOW}⚠️  Ошибки при создании структуры:${NC}"
    echo "$RESULT" | grep -iE "ERROR|FATAL" | head -3
else
    echo -e "${GREEN}✅ Структура таблиц создана${NC}"
fi

# Проверяем, что таблицы созданы
MAIN_EXISTS=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'aircraft_main_categories');\" 2>&1" | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r')
SUB_EXISTS=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'aircraft_subcategories');\" 2>&1" | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r')

if [ "$MAIN_EXISTS" != "t" ] || [ "$SUB_EXISTS" != "t" ]; then
    echo -e "${RED}❌ Таблицы не созданы!${NC}"
    echo -e "${YELLOW}   aircraft_main_categories: $MAIN_EXISTS${NC}"
    echo -e "${YELLOW}   aircraft_subcategories: $SUB_EXISTS${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Шаг 2: Экспорт данных из локальной БД
echo -e "\n${YELLOW}2. Экспорт данных из локальной БД...${NC}"

TEMP_DIR="/tmp/aircraft_categories_sync_$$"
mkdir -p "$TEMP_DIR"

# Экспортируем aircraft_main_categories (без последовательностей)
docker exec $LOCAL_DB_CONTAINER pg_dump -U $LOCAL_DB_USER -d $LOCAL_DB_NAME \
  -t aircraft_main_categories \
  --data-only \
  --column-inserts \
  --no-owner \
  --no-privileges > "$TEMP_DIR/aircraft_main_categories_data.sql" 2>/dev/null

# Удаляем строки с последовательностями из экспорта
sed -i '' '/^-- Name:.*_seq/d' "$TEMP_DIR/aircraft_main_categories_data.sql" 2>/dev/null || sed -i '/^-- Name:.*_seq/d' "$TEMP_DIR/aircraft_main_categories_data.sql" 2>/dev/null
sed -i '' '/^SELECT pg_catalog.setval/d' "$TEMP_DIR/aircraft_main_categories_data.sql" 2>/dev/null || sed -i '/^SELECT pg_catalog.setval/d' "$TEMP_DIR/aircraft_main_categories_data.sql" 2>/dev/null

if [ $? -eq 0 ] && [ -s "$TEMP_DIR/aircraft_main_categories_data.sql" ]; then
    MAIN_COUNT=$(docker exec $LOCAL_DB_CONTAINER psql -U $LOCAL_DB_USER -d $LOCAL_DB_NAME -t -c "SELECT COUNT(*) FROM aircraft_main_categories;" 2>/dev/null | tr -d ' ')
    echo -e "${GREEN}✅ Экспортировано aircraft_main_categories: $MAIN_COUNT записей${NC}"
else
    echo -e "${RED}❌ Ошибка экспорта aircraft_main_categories${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Экспортируем aircraft_subcategories (без последовательностей)
docker exec $LOCAL_DB_CONTAINER pg_dump -U $LOCAL_DB_USER -d $LOCAL_DB_NAME \
  -t aircraft_subcategories \
  --data-only \
  --column-inserts \
  --no-owner \
  --no-privileges > "$TEMP_DIR/aircraft_subcategories_data.sql" 2>/dev/null

# Удаляем строки с последовательностями из экспорта
sed -i '' '/^-- Name:.*_seq/d' "$TEMP_DIR/aircraft_subcategories_data.sql" 2>/dev/null || sed -i '/^-- Name:.*_seq/d' "$TEMP_DIR/aircraft_subcategories_data.sql" 2>/dev/null
sed -i '' '/^SELECT pg_catalog.setval/d' "$TEMP_DIR/aircraft_subcategories_data.sql" 2>/dev/null || sed -i '/^SELECT pg_catalog.setval/d' "$TEMP_DIR/aircraft_subcategories_data.sql" 2>/dev/null

if [ $? -eq 0 ] && [ -s "$TEMP_DIR/aircraft_subcategories_data.sql" ]; then
    SUB_COUNT=$(docker exec $LOCAL_DB_CONTAINER psql -U $LOCAL_DB_USER -d $LOCAL_DB_NAME -t -c "SELECT COUNT(*) FROM aircraft_subcategories;" 2>/dev/null | tr -d ' ')
    echo -e "${GREEN}✅ Экспортировано aircraft_subcategories: $SUB_COUNT записей${NC}"
else
    echo -e "${RED}❌ Ошибка экспорта aircraft_subcategories${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Шаг 3: Копирование данных на сервер
echo -e "\n${YELLOW}3. Копирование данных на сервер...${NC}"

if command -v sshpass >/dev/null 2>&1; then
    sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no "$TEMP_DIR/aircraft_main_categories_data.sql" $SERVER_USER@$SERVER_IP:/tmp/ > /dev/null 2>&1
    sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no "$TEMP_DIR/aircraft_subcategories_data.sql" $SERVER_USER@$SERVER_IP:/tmp/ > /dev/null 2>&1
elif command -v expect >/dev/null 2>&1; then
    expect <<EOF > /dev/null 2>&1
set timeout 30
spawn scp -o StrictHostKeyChecking=no "$TEMP_DIR/aircraft_main_categories_data.sql" $SERVER_USER@$SERVER_IP:/tmp/
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
    expect <<EOF > /dev/null 2>&1
set timeout 30
spawn scp -o StrictHostKeyChecking=no "$TEMP_DIR/aircraft_subcategories_data.sql" $SERVER_USER@$SERVER_IP:/tmp/
expect {
    "password:" { send "$SERVER_PASSWORD\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF
else
    scp -o StrictHostKeyChecking=no "$TEMP_DIR/aircraft_main_categories_data.sql" $SERVER_USER@$SERVER_IP:/tmp/
    scp -o StrictHostKeyChecking=no "$TEMP_DIR/aircraft_subcategories_data.sql" $SERVER_USER@$SERVER_IP:/tmp/
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Файлы скопированы на сервер${NC}"
else
    echo -e "${RED}❌ Ошибка копирования файлов${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Шаг 4: Импорт данных на сервер
echo -e "\n${YELLOW}4. Импорт данных на сервер...${NC}"

# Очищаем таблицы на сервере перед импортом
ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -c 'TRUNCATE TABLE aircraft_subcategories CASCADE; TRUNCATE TABLE aircraft_main_categories CASCADE RESTART IDENTITY;' 2>&1" > /dev/null 2>&1

# Импортируем aircraft_main_categories
echo -e "${YELLOW}   Импорт aircraft_main_categories...${NC}"
# Используем ON CONFLICT для избежания дубликатов
IMPORT_MAIN_SQL="
BEGIN;
$(cat "$TEMP_DIR/aircraft_main_categories_data.sql" | grep "^INSERT")
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, name_en = EXCLUDED.name_en;
COMMIT;
"
RESULT=$(echo "$IMPORT_MAIN_SQL" | ssh_with_password "docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME 2>&1" | grep -v "^spawn\|^root@\|password:" | tail -5)

if echo "$RESULT" | grep -qiE "ERROR|FATAL"; then
    echo -e "${RED}✗ Ошибка импорта aircraft_main_categories${NC}"
    echo "$RESULT" | grep -iE "ERROR|FATAL" | head -3
else
    echo -e "${GREEN}✓ aircraft_main_categories импортированы${NC}"
fi

# Импортируем aircraft_subcategories
echo -e "${YELLOW}   Импорт aircraft_subcategories...${NC}"
# Используем ON CONFLICT для избежания дубликатов
IMPORT_SUB_SQL="
BEGIN;
$(cat "$TEMP_DIR/aircraft_subcategories_data.sql" | grep "^INSERT")
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, name_en = EXCLUDED.name_en, main_categories_id = EXCLUDED.main_categories_id, icon = EXCLUDED.icon;
COMMIT;
"
RESULT=$(echo "$IMPORT_SUB_SQL" | ssh_with_password "docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME 2>&1" | grep -v "^spawn\|^root@\|password:" | tail -5)

if echo "$RESULT" | grep -qiE "ERROR|FATAL"; then
    echo -e "${RED}✗ Ошибка импорта aircraft_subcategories${NC}"
    echo "$RESULT" | grep -iE "ERROR|FATAL" | head -3
else
    echo -e "${GREEN}✓ aircraft_subcategories импортированы${NC}"
fi

# Шаг 5: Проверка результата
echo -e "\n${YELLOW}5. Проверка результата...${NC}"

SERVER_MAIN_COUNT=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c 'SELECT COUNT(*) FROM aircraft_main_categories;' 2>&1" | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r')
SERVER_SUB_COUNT=$(ssh_with_password "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c 'SELECT COUNT(*) FROM aircraft_subcategories;' 2>&1" | grep -v "^spawn\|^root@\|password:" | tr -d ' \n\r')

echo -e "${YELLOW}   Локально:${NC}"
echo -e "     aircraft_main_categories: $MAIN_COUNT записей"
echo -e "     aircraft_subcategories: $SUB_COUNT записей"
echo -e "${YELLOW}   На сервере:${NC}"
echo -e "     aircraft_main_categories: $SERVER_MAIN_COUNT записей"
echo -e "     aircraft_subcategories: $SERVER_SUB_COUNT записей"

if [ "$MAIN_COUNT" = "$SERVER_MAIN_COUNT" ] && [ "$SUB_COUNT" = "$SERVER_SUB_COUNT" ]; then
    echo -e "${GREEN}✅ Синхронизация успешна!${NC}"
else
    echo -e "${YELLOW}⚠️  Количество записей не совпадает${NC}"
fi

# Очистка
rm -rf "$TEMP_DIR"
ssh_with_password "rm -f /tmp/aircraft_main_categories_data.sql /tmp/aircraft_subcategories_data.sql" > /dev/null 2>&1

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Синхронизация завершена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
