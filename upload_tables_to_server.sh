#!/bin/bash

# Скрипт для копирования таблиц payments и subscriptions с локальной БД на серверную БД
# Использование: ./upload_tables_to_server.sh [SERVER_IP]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
LOCAL_DB_NAME="aviapoint"
LOCAL_DB_USER="postgres"
LOCAL_DB_PASSWORD="password"
LOCAL_DB_HOST="localhost"
LOCAL_DB_PORT="5432"
LOCAL_DB_CONTAINER="server-side-postgres-database"
SERVER_DB_NAME="aviapoint"
SERVER_DB_USER="postgres"
SERVER_DB_CONTAINER="aviapoint-postgres"

echo "=========================================="
echo "Копирование таблиц с локальной БД на сервер"
echo "=========================================="
echo "Локальная БД: $LOCAL_DB_NAME"
echo "Сервер: $SERVER_IP"
echo "Серверная БД: $SERVER_DB_NAME"
echo ""

# Создаем временную директорию
TEMP_DIR=$(mktemp -d)
EXPORT_FILE="$TEMP_DIR/payments_subscriptions_export.sql"
echo "Временная директория: $TEMP_DIR"
echo ""

# Шаг 1: Экспорт таблиц с локальной БД
echo "Шаг 1: Экспорт таблиц с локальной БД..."
# Проверяем, используется ли Docker контейнер
if docker ps | grep -q $LOCAL_DB_CONTAINER; then
    echo "Используется Docker контейнер: $LOCAL_DB_CONTAINER"
    docker exec $LOCAL_DB_CONTAINER pg_dump -U $LOCAL_DB_USER -d $LOCAL_DB_NAME \
      -t payments \
      -t subscriptions \
      --data-only \
      --column-inserts > $EXPORT_FILE
else
    echo "Используется прямое подключение к PostgreSQL"
    PGPASSWORD=$LOCAL_DB_PASSWORD pg_dump -h $LOCAL_DB_HOST -p $LOCAL_DB_PORT -U $LOCAL_DB_USER -d $LOCAL_DB_NAME \
      -t payments \
      -t subscriptions \
      --data-only \
      --column-inserts > $EXPORT_FILE
fi

if [ $? -ne 0 ]; then
    echo "Ошибка при экспорте с локальной БД!"
    rm -rf $TEMP_DIR
    exit 1
fi

if [ ! -s "$EXPORT_FILE" ]; then
    echo "Предупреждение: Экспортированный файл пуст или таблицы не содержат данных"
fi

echo "Экспорт завершен. Размер файла: $(du -h $EXPORT_FILE | cut -f1)"
echo ""

# Шаг 2: Копирование файла на сервер
echo "Шаг 2: Копирование файла на сервер..."
scp $EXPORT_FILE $SERVER_USER@$SERVER_IP:/tmp/payments_subscriptions_import.sql

if [ $? -ne 0 ]; then
    echo "Ошибка при копировании файла на сервер!"
    rm -rf $TEMP_DIR
    exit 1
fi

echo "Файл скопирован на сервер"
echo ""

# Шаг 3: Очистка серверных таблиц (опционально)
echo "Шаг 3: Подготовка серверной БД..."
read -p "Очистить серверные таблицы payments и subscriptions перед импортом? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Очистка серверных таблиц..."
    ssh $SERVER_USER@$SERVER_IP << EOF
docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME << SQL
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE subscriptions CASCADE;
SQL
EOF
    if [ $? -ne 0 ]; then
        echo "Ошибка при очистке таблиц на сервере!"
        rm -rf $TEMP_DIR
        exit 1
    fi
    echo "Серверные таблицы очищены."
fi

# Шаг 4: Импорт в серверную БД
echo ""
echo "Шаг 4: Импорт в серверную БД..."
ssh $SERVER_USER@$SERVER_IP << EOF
docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME < /tmp/payments_subscriptions_import.sql
EOF

if [ $? -ne 0 ]; then
    echo "Ошибка при импорте на сервер!"
    echo "Проверьте логи выше для деталей"
    rm -rf $TEMP_DIR
    ssh $SERVER_USER@$SERVER_IP "rm -f /tmp/payments_subscriptions_import.sql"
    exit 1
fi

# Шаг 5: Очистка временных файлов
echo ""
echo "Очистка временных файлов..."
rm -rf $TEMP_DIR
ssh $SERVER_USER@$SERVER_IP "rm -f /tmp/payments_subscriptions_import.sql"

echo ""
echo "=========================================="
echo "Готово! Таблицы скопированы на сервер."
echo "=========================================="
echo ""
echo "Проверка количества записей на сервере:"
ssh $SERVER_USER@$SERVER_IP << EOF
docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME << SQL
SELECT 
    'payments' as table_name, COUNT(*) as count FROM payments
UNION ALL
SELECT 
    'subscriptions' as table_name, COUNT(*) as count FROM subscriptions;
SQL
EOF

