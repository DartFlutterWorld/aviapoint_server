#!/bin/bash

# Скрипт для удаления таблиц на сервере и копирования из локальной БД
# Использование: ./copy_tables_local_to_server.sh

SERVER_IP="83.166.246.205"
SERVER_USER="root"
LOCAL_DB_CONTAINER="aviapoint-postgres"
SERVER_DB_CONTAINER="aviapoint-postgres"
SERVER_DB_NAME="aviapoint"
SERVER_DB_USER="postgres"

echo "=========================================="
echo "Копирование таблиц с локальной БД на сервер"
echo "=========================================="
echo ""

# Шаг 1: Экспорт таблиц с локальной БД
echo "Шаг 1: Экспорт таблиц payments и subscriptions с локальной БД..."
docker exec $LOCAL_DB_CONTAINER pg_dump -U postgres -d aviapoint \
  -t payments \
  -t subscriptions \
  --data-only \
  --column-inserts > /tmp/payments_subscriptions_local.sql

if [ $? -ne 0 ]; then
    echo "Ошибка при экспорте с локальной БД!"
    exit 1
fi

if [ ! -s "/tmp/payments_subscriptions_local.sql" ]; then
    echo "Предупреждение: Экспортированный файл пуст или таблицы не содержат данных"
fi

echo "Экспорт завершен. Размер файла: $(du -h /tmp/payments_subscriptions_local.sql | cut -f1)"
echo ""

# Шаг 2: Удаление таблиц на сервере
echo "Шаг 2: Удаление данных из таблиц на сервере..."
ssh $SERVER_USER@$SERVER_IP << EOF
docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME << SQL
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE subscriptions CASCADE;
SQL
EOF

if [ $? -ne 0 ]; then
    echo "Ошибка при удалении таблиц на сервере!"
    rm -f /tmp/payments_subscriptions_local.sql
    exit 1
fi

echo "Таблицы на сервере очищены."
echo ""

# Шаг 3: Копирование файла на сервер
echo "Шаг 3: Копирование файла на сервер..."
scp /tmp/payments_subscriptions_local.sql $SERVER_USER@$SERVER_IP:/tmp/

if [ $? -ne 0 ]; then
    echo "Ошибка при копировании файла на сервер!"
    rm -f /tmp/payments_subscriptions_local.sql
    exit 1
fi

echo "Файл скопирован на сервер"
echo ""

# Шаг 4: Импорт в серверную БД
echo "Шаг 4: Импорт данных в серверную БД..."
ssh $SERVER_USER@$SERVER_IP << EOF
docker exec -i $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME < /tmp/payments_subscriptions_local.sql
EOF

if [ $? -ne 0 ]; then
    echo "Ошибка при импорте на сервер!"
    echo "Проверьте логи выше для деталей"
    rm -f /tmp/payments_subscriptions_local.sql
    ssh $SERVER_USER@$SERVER_IP "rm -f /tmp/payments_subscriptions_local.sql" 2>/dev/null
    exit 1
fi

# Шаг 5: Проверка результата
echo ""
echo "Шаг 5: Проверка количества записей на сервере..."
ssh $SERVER_USER@$SERVER_IP << EOF
docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME << SQL
SELECT 
    'payments' as table_name, COUNT(*) as count FROM payments
UNION ALL
SELECT 
    'subscriptions' as table_name, COUNT(*) as count FROM subscriptions;
SQL
EOF

# Шаг 6: Очистка временных файлов
echo ""
echo "Очистка временных файлов..."
rm -f /tmp/payments_subscriptions_local.sql
ssh $SERVER_USER@$SERVER_IP "rm -f /tmp/payments_subscriptions_local.sql" 2>/dev/null

echo ""
echo "=========================================="
echo "Готово! Таблицы скопированы на сервер."
echo "=========================================="

