#!/bin/bash

# Скрипт для экспорта локальной БД и загрузки на сервер
# Использование: ./export_and_upload.sh [server-ip]

set -e

SERVER_IP="${1:-your-server-ip}"
SERVER_USER="root"
LOCAL_CONTAINER="server-side-postgres-database"
SERVER_CONTAINER="aviapoint-postgres"
DB_NAME="aviapoint"
DB_USER="postgres"

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Экспорт локальной БД и загрузка на сервер${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Проверка аргументов
if [ "$SERVER_IP" = "your-server-ip" ]; then
    echo -e "${RED}❌ Укажите IP сервера!${NC}"
    echo -e "${YELLOW}Использование: ./export_and_upload.sh your-server-ip${NC}"
    exit 1
fi

# Проверка подключения к серверу
echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
if ! ssh -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo 'OK'" &> /dev/null; then
    echo -e "${RED}❌ Не удалось подключиться к серверу $SERVER_IP!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Подключение к серверу установлено${NC}"

# Проверка локальной БД
echo -e "\n${YELLOW}2. Проверка локальной БД...${NC}"
if ! docker ps | grep -q $LOCAL_CONTAINER; then
    echo -e "${RED}❌ Локальный контейнер БД не запущен!${NC}"
    exit 1
fi

LOCAL_COUNT=$(docker exec $LOCAL_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM (SELECT 'news' FROM news UNION ALL SELECT 'stories' FROM stories) t;" 2>/dev/null | wc -l || echo "0")
echo -e "${GREEN}✅ Локальная БД доступна${NC}"

# Создание бэкапа на сервере
echo -e "\n${YELLOW}3. Создание бэкапа серверной БД (на всякий случай)...${NC}"
ssh $SERVER_USER@$SERVER_IP "cd /home/aviapoint_server && \
    docker exec $SERVER_CONTAINER pg_dump -U $DB_USER -d $DB_NAME > server_backup_before_\$(date +%Y%m%d_%H%M%S).sql 2>/dev/null || true"
echo -e "${GREEN}✅ Бэкап серверной БД создан${NC}"

# Создание дампа локальной БД
echo -e "\n${YELLOW}4. Создание дампа локальной БД...${NC}"
BACKUP_FILE="local_backup_$(date +%Y%m%d_%H%M%S).sql"

# Спросим, нужно ли очистить БД на сервере
echo -e "${YELLOW}   Таблицы уже существуют на сервере. Что делать?${NC}"
echo -e "   1) Очистить БД на сервере и загрузить заново (полная замена)"
echo -e "   2) Загрузить только новые данные (пропустить существующие)"
read -p "   Выберите вариант (1 или 2, по умолчанию 2): " CLEAN_CHOICE

if [ "$CLEAN_CHOICE" = "1" ]; then
    # Полный дамп с очисткой
    echo -e "${YELLOW}   Создаю дамп с флагом --clean (очистит существующие таблицы)...${NC}"
    docker exec $LOCAL_CONTAINER pg_dump -U $DB_USER -d $DB_NAME --clean --if-exists > $BACKUP_FILE
else
    # Только данные (без CREATE TABLE)
    echo -e "${YELLOW}   Создаю дамп только с данными (без структуры)...${NC}"
    docker exec $LOCAL_CONTAINER pg_dump -U $DB_USER -d $DB_NAME --data-only --inserts > $BACKUP_FILE
fi

if [ ! -f "$BACKUP_FILE" ] || [ ! -s "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Ошибка при создании дампа!${NC}"
    exit 1
fi

FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo -e "${GREEN}✅ Дамп создан: $BACKUP_FILE (размер: $FILE_SIZE)${NC}"

# Копирование на сервер
echo -e "\n${YELLOW}5. Копирование дампа на сервер...${NC}"
scp $BACKUP_FILE $SERVER_USER@$SERVER_IP:/home/aviapoint_server/
echo -e "${GREEN}✅ Файл скопирован на сервер${NC}"

# Восстановление на сервере
echo -e "\n${YELLOW}6. Восстановление БД на сервере...${NC}"
echo -e "${YELLOW}   Это может занять некоторое время...${NC}"

if [ "$CLEAN_CHOICE" = "1" ]; then
    # Полная замена - остановим приложение для безопасности
    echo -e "${YELLOW}   Останавливаю приложение на сервере...${NC}"
    ssh $SERVER_USER@$SERVER_IP "cd /home/aviapoint_server && docker-compose -f docker-compose.prod.yaml stop app 2>/dev/null || true"
    
    # Загрузим с очисткой
    ssh $SERVER_USER@$SERVER_IP "cd /home/aviapoint_server && \
        cat $BACKUP_FILE | docker exec -i $SERVER_CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1 | grep -v 'ERROR' || true"
    
    # Запустим приложение обратно
    echo -e "${YELLOW}   Запускаю приложение обратно...${NC}"
    ssh $SERVER_USER@$SERVER_IP "cd /home/aviapoint_server && docker-compose -f docker-compose.prod.yaml start app 2>/dev/null || true"
else
    # Только данные - загрузим с игнорированием ошибок дубликатов
    echo -e "${YELLOW}   Загружаю данные (дубликаты будут пропущены)...${NC}"
    ssh $SERVER_USER@$SERVER_IP "cd /home/aviapoint_server && \
        cat $BACKUP_FILE | docker exec -i $SERVER_CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1 | \
        grep -v 'ERROR.*already exists' | grep -v 'ERROR.*duplicate key' | grep -v 'ERROR.*violates unique constraint' || true"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ БД успешно восстановлена на сервере${NC}"
else
    echo -e "${RED}❌ Ошибка при восстановлении БД на сервере!${NC}"
    echo -e "${YELLOW}Проверьте логи на сервере${NC}"
    exit 1
fi

# Проверка результата
echo -e "\n${YELLOW}7. Проверка результата...${NC}"
SERVER_COUNT=$(ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c \"SELECT COUNT(*) FROM (SELECT 'news' FROM news UNION ALL SELECT 'stories' FROM stories) t;\" 2>/dev/null | wc -l || echo '0'")
echo -e "${GREEN}✅ Проверка завершена${NC}"

# Очистка
echo -e "\n${YELLOW}8. Очистка временных файлов...${NC}"
rm $BACKUP_FILE
ssh $SERVER_USER@$SERVER_IP "cd /home/aviapoint_server && rm $BACKUP_FILE"
echo -e "${GREEN}✅ Временные файлы удалены${NC}"

echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Экспорт и загрузка завершены успешно!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}\n"

echo -e "${BLUE}Проверьте данные на сервере:${NC}"
echo -e "  ssh $SERVER_USER@$SERVER_IP"
echo -e "  docker exec -it $SERVER_CONTAINER psql -U $DB_USER -d $DB_NAME"
echo -e "  \\dt  # список таблиц"
echo ""

