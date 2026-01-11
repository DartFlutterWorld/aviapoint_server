#!/bin/bash

# Скрипт для применения новых миграций на продакшн сервере
# Использование: ./deploy_migrations_to_prod.sh [SERVER_IP]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
SERVER_DB_CONTAINER="aviapoint-postgres"
SERVER_DB_NAME="aviapoint"
SERVER_DB_USER="postgres"
PROJECT_DIR="/home/aviapoint_server"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=========================================="
echo "Применение миграций на продакшн"
echo "==========================================${NC}"
echo "Сервер: $SERVER_IP"
echo "База данных: $SERVER_DB_NAME"
echo ""

# Проверка подключения к серверу
echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
if ! ssh -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Подключение установлено${NC}"

# Проверка, что код обновлен на сервере
echo -e "\n${YELLOW}2. Проверка обновления кода на сервере...${NC}"
echo -e "${YELLOW}   Убедитесь, что вы выполнили 'git pull' на сервере!${NC}"
read -p "Код обновлен на сервере? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}   Выполните на сервере:${NC}"
    echo -e "   ssh $SERVER_USER@$SERVER_IP"
    echo -e "   cd $PROJECT_DIR"
    echo -e "   git pull"
    exit 1
fi

# Применение миграций через MigrationManager (автоматически при запуске сервера)
echo -e "\n${YELLOW}3. Применение миграций...${NC}"
echo -e "${YELLOW}   Миграции будут применены автоматически при следующем запуске сервера${NC}"
echo -e "${YELLOW}   через MigrationManager.${NC}"
echo ""
echo -e "${YELLOW}   Вариант 1: Автоматическое применение (рекомендуется)${NC}"
echo -e "   Миграции применятся автоматически при перезапуске сервера."
echo ""
echo -e "${YELLOW}   Вариант 2: Ручное применение через Adminer${NC}"
echo -e "   1. Откройте http://$SERVER_IP:8082"
echo -e "   2. Войдите в базу данных $SERVER_DB_NAME"
echo -e "   3. Перейдите в 'SQL-запрос'"
echo -e "   4. Выполните миграции вручную из папки migrations/"
echo ""

# Получение списка примененных миграций с продакшн сервера
echo -e "${YELLOW}4. Проверка примененных миграций на продакшн сервере...${NC}"
echo -e "${YELLOW}   Подключение к серверу $SERVER_IP и проверка таблицы schema_migrations...${NC}"

# Получаем список примененных миграций с продакшн БД через SSH
EXECUTED_MIGRATIONS_RAW=$(ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -t -c \"SELECT version FROM schema_migrations ORDER BY version;\" 2>/dev/null" 2>/dev/null || echo "")

# Обрабатываем результат: убираем пустые строки и лишние пробелы, но сохраняем структуру
EXECUTED_MIGRATIONS=$(echo "$EXECUTED_MIGRATIONS_RAW" | grep -v '^$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -E '^[0-9]{3}$' || echo "")

# Список всех миграций из MigrationManager (синхронизирован с lib/core/migrations/migration_manager.dart)
ALL_MIGRATIONS=(
    "001:create_payments_table"
    "002:create_subscriptions_table"
    "003:create_on_the_way_tables"
    "004:create_airports_table"
    "005:add_avatar_url_to_profiles"
    "006:add_reply_to_reviews"
    "007:make_rating_nullable_for_replies"
    "008:add_flight_photos_table"
    "009:recreate_airports_table_aopa"
    "010:create_feedback_table"
    "011:create_airport_ownership_requests_table"
    "012:add_owned_airports_to_profiles"
    "013:add_user_id_to_payments"
    "014:add_subscription_fields_to_profiles"
    "015:add_subscription_fields_to_payments"
    "016:add_description_to_subscription_types"
    "017:make_payment_id_nullable_in_subscriptions"
    "018:add_missing_fields_to_airport_ownership_requests"
    "019:add_owner_id_to_airports"
    "020:add_photos_to_airports"
    "021:create_airport_feedback_table"
    "022:create_airport_visitor_photos_table"
    "023:add_visitor_photos_to_airports"
    "024:create_flight_waypoints_table"
    "025:clear_all_flights_data"
    "026:create_flight_questions_table"
    "027:remove_subscription_fields_from_profiles"
    "028:remove_unique_active_subscription_index"
    "029:add_telegram_and_max_to_profiles"
    "030:insert_airports_data"
    "031:create_airport_reviews_table"
    "032:add_fcm_token_to_profiles"
    "033:create_aircraft_types_table"
    "034:insert_aircraft_types_from_planecheck_full"
    "035:drop_aircraft_types_table"
    "036:create_aircraft_catalog_tables"
    "037:insert_aircraft_catalog_data_full"
    "038:create_blog_tables"
    "039:remove_blog_article_meta_fields"
    "040:update_blog_categories"
    "041:force_update_blog_categories"
    "042:force_update_blog_categories_v2"
    "043:update_blog_categories_final"
    "044:insert_new_blog_categories"
    "045:drop_and_recreate_blog_categories"
    "046:insert_blog_categories"
    "047:add_slug_to_blog_articles"
    "048:create_app_settings_table"
    "049:remove_blog_article_slug"
    "050:drop_aircraft_catalog_view"
    "051:simplify_aircraft_tables"
    "052:add_index_to_blog_comments"
)

echo -e "${YELLOW}   Примененные миграции на продакшн сервере:${NC}"
if [ -z "$EXECUTED_MIGRATIONS" ]; then
    echo -e "${RED}   ⚠️  Не удалось получить список миграций с продакшн сервера${NC}"
    echo -e "${YELLOW}   Возможно, таблица schema_migrations еще не создана или нет подключения к БД${NC}"
    EXECUTED_MIGRATIONS_LIST=""
else
    EXECUTED_MIGRATIONS_LIST=$(echo "$EXECUTED_MIGRATIONS" | tr '\n' ' ')
    echo "$EXECUTED_MIGRATIONS" | while read -r version; do
        if [ ! -z "$version" ] && [[ "$version" =~ ^[0-9]{3}$ ]]; then
            echo -e "${GREEN}   ✅ $version${NC}"
        fi
    done
    echo -e "${YELLOW}   Всего применено: $(echo "$EXECUTED_MIGRATIONS" | wc -l | tr -d ' ') миграций${NC}"
fi

echo ""
echo -e "${YELLOW}   Новые миграции для применения на продакшн:${NC}"
NEW_MIGRATIONS_FOUND=false
for migration in "${ALL_MIGRATIONS[@]}"; do
    VERSION=$(echo "$migration" | cut -d':' -f1)
    NAME=$(echo "$migration" | cut -d':' -f2)
    # Проверяем, есть ли эта версия в списке примененных миграций с продакшн
    if [ -z "$EXECUTED_MIGRATIONS" ] || ! echo "$EXECUTED_MIGRATIONS" | grep -q "^$VERSION$"; then
        NEW_MIGRATIONS_FOUND=true
        if [[ "$NAME" == *"clear_all_flights_data"* ]]; then
            echo -e "${RED}   - $VERSION: $NAME (⚠️  удаляет данные!)${NC}"
        else
            echo -e "${YELLOW}   - $VERSION: $NAME${NC}"
        fi
    fi
done

if [ "$NEW_MIGRATIONS_FOUND" = false ]; then
    echo -e "${GREEN}   ✅ Все миграции уже применены на продакшн${NC}"
fi
echo ""

# Перезапуск сервера для применения миграций
echo -e "${YELLOW}5. Перезапуск сервера для применения миграций...${NC}"
read -p "Перезапустить сервер сейчас? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}   Пересборка и перезапуск сервера...${NC}"
    ssh $SERVER_USER@$SERVER_IP "cd $PROJECT_DIR && \
        docker-compose -f docker-compose.prod.yaml build app && \
        docker-compose -f docker-compose.prod.yaml up -d app"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Сервер перезапущен${NC}"
        echo -e "${YELLOW}   Проверьте логи:${NC}"
        echo -e "   ssh $SERVER_USER@$SERVER_IP 'docker logs -f aviapoint-server'"
    else
        echo -e "${RED}❌ Ошибка при перезапуске сервера!${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}   Перезапуск пропущен. Выполните вручную:${NC}"
    echo -e "   ssh $SERVER_USER@$SERVER_IP"
    echo -e "   cd $PROJECT_DIR"
    echo -e "   docker-compose -f docker-compose.prod.yaml build app"
    echo -e "   docker-compose -f docker-compose.prod.yaml up -d app"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "✅ Готово!"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}Проверка статуса миграций:${NC}"
echo -e "   ssh $SERVER_USER@$SERVER_IP 'docker exec $SERVER_DB_CONTAINER psql -U $SERVER_DB_USER -d $SERVER_DB_NAME -c \"SELECT version, name, executed_at FROM schema_migrations ORDER BY executed_at DESC LIMIT 10;\"'"


