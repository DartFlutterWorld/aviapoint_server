#!/bin/bash

# Скрипт для копирования таблицы subscription_types с удаленного сервера на локальный хост
# Использование: ./copy_subscription_types_from_server.sh

SERVER_IP="83.166.246.205"
SERVER_USER="root"
LOCAL_DB_NAME="aviapoint"
LOCAL_DB_USER="postgres"
LOCAL_DB_CONTAINER="aviapoint-postgres" # Имя вашего локального Docker контейнера с БД
SERVER_DB_CONTAINER="aviapoint-postgres" # Имя Docker контейнера с БД на сервере

echo "=========================================="
echo "Копирование subscription_types с сервера на локальный хост"
echo "=========================================="
echo "Сервер: $SERVER_IP"
echo "Локальная БД: $LOCAL_DB_NAME"
echo ""

# Шаг 1: Экспорт таблицы с сервера
echo "Шаг 1: Экспорт таблицы subscription_types с сервера..."
EXPORT_FILE="/tmp/subscription_types_export.sql"

ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER pg_dump -U postgres -d aviapoint -t subscription_types --data-only --column-inserts" > $EXPORT_FILE

if [ $? -ne 0 ]; then
    echo "Ошибка при экспорте с сервера!"
    exit 1
fi
echo "Таблица экспортирована в $EXPORT_FILE"
echo ""

# Шаг 2: Проверка и добавление поля description (если его нет)
echo "Шаг 2: Проверка структуры таблицы subscription_types..."
if docker ps | grep -q $LOCAL_DB_CONTAINER; then
    docker exec -i $LOCAL_DB_CONTAINER psql -U $LOCAL_DB_USER -d $LOCAL_DB_NAME < migrations/add_description_to_subscription_types.sql 2>/dev/null || echo "Поле description уже существует или миграция не найдена"
else
    PGPASSWORD=password psql -h localhost -p 5432 -U $LOCAL_DB_USER -d $LOCAL_DB_NAME -f migrations/add_description_to_subscription_types.sql 2>/dev/null || echo "Поле description уже существует или миграция не найдена"
fi
echo "Структура таблицы проверена."
echo ""

# Шаг 3: Очистка локальной таблицы (опционально)
echo "Шаг 3: Очистка локальной таблицы subscription_types..."
read -p "Очистить локальную таблицу subscription_types перед импортом? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if docker ps | grep -q $LOCAL_DB_CONTAINER; then
        docker exec $LOCAL_DB_CONTAINER psql -U $LOCAL_DB_USER -d $LOCAL_DB_NAME -c "TRUNCATE TABLE subscription_types CASCADE;"
    else
        PGPASSWORD=password psql -h localhost -p 5432 -U $LOCAL_DB_USER -d $LOCAL_DB_NAME -c "TRUNCATE TABLE subscription_types CASCADE;"
    fi
    if [ $? -ne 0 ]; then
        echo "Ошибка при очистке локальной таблицы!"
        rm -f $EXPORT_FILE
        exit 1
    fi
    echo "Локальная таблица очищена."
else
    echo "Очистка локальной таблицы пропущена."
fi
echo ""

# Шаг 4: Импорт в локальную БД
echo "Шаг 4: Импорт в локальную БД..."
if docker ps | grep -q $LOCAL_DB_CONTAINER; then
    docker exec -i $LOCAL_DB_CONTAINER psql -U $LOCAL_DB_USER -d $LOCAL_DB_NAME < $EXPORT_FILE
else
    PGPASSWORD=password psql -h localhost -p 5432 -U $LOCAL_DB_USER -d $LOCAL_DB_NAME < $EXPORT_FILE
fi

if [ $? -ne 0 ]; then
    echo "Ошибка при импорте в локальную БД!"
    rm -f $EXPORT_FILE
    exit 1
fi
echo "Данные успешно импортированы в локальную БД."
echo ""

# Шаг 5: Очистка временных файлов
echo "Шаг 5: Очистка временных файлов..."
rm -f $EXPORT_FILE
echo "Временные файлы удалены."
echo ""

# Шаг 6: Проверка количества записей
echo "Шаг 6: Проверка количества записей в локальной БД:"
if docker ps | grep -q $LOCAL_DB_CONTAINER; then
    docker exec $LOCAL_DB_CONTAINER psql -U $LOCAL_DB_USER -d $LOCAL_DB_NAME -c "SELECT COUNT(*) as count FROM subscription_types;"
else
    PGPASSWORD=password psql -h localhost -p 5432 -U $LOCAL_DB_USER -d $LOCAL_DB_NAME -c "SELECT COUNT(*) as count FROM subscription_types;"
fi
echo ""

echo "=========================================="
echo "Готово! Таблица subscription_types скопирована с сервера."
echo "=========================================="

