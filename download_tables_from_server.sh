#!/bin/bash

# Скрипт для копирования таблиц payments и subscriptions с удаленного сервера в локальную БД
# Использование: ./download_tables_from_server.sh [SERVER_IP]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
LOCAL_DB_NAME="aviapoint"
LOCAL_DB_USER="postgres"
LOCAL_DB_PASSWORD="password"
LOCAL_DB_HOST="localhost"
LOCAL_DB_PORT="5432"
LOCAL_DB_CONTAINER="aviapoint-postgres"

echo "=========================================="
echo "Копирование таблиц с сервера на локальную БД"
echo "=========================================="
echo "Сервер: $SERVER_IP"
echo "Локальная БД: $LOCAL_DB_NAME"
echo ""

# Создаем временную директорию
TEMP_DIR=$(mktemp -d)
echo "Временная директория: $TEMP_DIR"
echo ""

# Шаг 1: Экспорт таблиц с сервера
echo "Шаг 1: Экспорт таблиц с сервера..."
ssh $SERVER_USER@$SERVER_IP << EOF
cd /home/aviapoint_server
docker exec aviapoint-postgres pg_dump -U postgres -d aviapoint \
  -t payments \
  -t subscriptions \
  --data-only \
  --column-inserts > /tmp/payments_subscriptions_export.sql
EOF

if [ $? -ne 0 ]; then
    echo "Ошибка при экспорте с сервера!"
    exit 1
fi

# Шаг 2: Копирование файла с сервера
echo ""
echo "Шаг 2: Копирование файла с сервера..."
scp $SERVER_USER@$SERVER_IP:/tmp/payments_subscriptions_export.sql $TEMP_DIR/

if [ $? -ne 0 ]; then
    echo "Ошибка при копировании файла!"
    exit 1
fi

# Шаг 3: Очистка локальных таблиц (опционально)
echo ""
read -p "Очистить локальные таблицы payments и subscriptions перед импортом? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Очистка локальных таблиц..."
    # Проверяем, используется ли Docker контейнер
    if docker ps | grep -q $LOCAL_DB_CONTAINER; then
        docker exec $LOCAL_DB_CONTAINER psql -U $LOCAL_DB_USER -d $LOCAL_DB_NAME << SQL
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE subscriptions CASCADE;
SQL
    else
        PGPASSWORD=$LOCAL_DB_PASSWORD psql -h $LOCAL_DB_HOST -p $LOCAL_DB_PORT -U $LOCAL_DB_USER -d $LOCAL_DB_NAME << SQL
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE subscriptions CASCADE;
SQL
    fi
    if [ $? -ne 0 ]; then
        echo "Ошибка при очистке таблиц!"
        exit 1
    fi
    echo "Таблицы очищены."
fi

# Шаг 4: Импорт в локальную БД
echo ""
echo "Шаг 3: Импорт в локальную БД..."
# Проверяем, используется ли Docker контейнер
if docker ps | grep -q $LOCAL_DB_CONTAINER; then
    docker exec -i $LOCAL_DB_CONTAINER psql -U $LOCAL_DB_USER -d $LOCAL_DB_NAME < $TEMP_DIR/payments_subscriptions_export.sql
else
    PGPASSWORD=$LOCAL_DB_PASSWORD psql -h $LOCAL_DB_HOST -p $LOCAL_DB_PORT -U $LOCAL_DB_USER -d $LOCAL_DB_NAME < $TEMP_DIR/payments_subscriptions_export.sql
fi

if [ $? -ne 0 ]; then
    echo "Ошибка при импорте!"
    exit 1
fi

# Шаг 5: Очистка временных файлов
echo ""
echo "Очистка временных файлов..."
rm -rf $TEMP_DIR
ssh $SERVER_USER@$SERVER_IP "rm -f /tmp/payments_subscriptions_export.sql"

echo ""
echo "=========================================="
echo "Готово! Таблицы скопированы."
echo "=========================================="

