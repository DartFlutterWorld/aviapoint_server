#!/bin/bash

# Скрипт для применения только миграций (структуры) на продакшн без изменения данных
# Использование: ./apply_migrations_only_to_prod.sh [SERVER_IP]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
SERVER_DB_CONTAINER="aviapoint-postgres"
DB_NAME="aviapoint"
DB_USER="postgres"
PROJECT_DIR="/home/aviapoint_server"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Применение миграций (только структура) на продакшн${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Проверка подключения к серверу
echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
if ! ssh -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Подключение установлено${NC}"

# Проверка обновления кода
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

# Список миграций для применения (только структура, без данных)
MIGRATIONS=(
    "022:create_airport_visitor_photos_table.sql"
    "023:add_visitor_photos_to_airports.sql"
    "024:create_flight_waypoints_table.sql"
    "026:create_flight_questions_table.sql"
    "027:remove_subscription_fields_from_profiles.sql"
    "028:remove_unique_active_subscription_index.sql"
    "029:add_telegram_and_max_to_profiles.sql"
)

# Пропускаем миграцию 025 (clear_all_flights_data) - она удаляет данные!

echo -e "\n${YELLOW}3. Миграции для применения (только структура):${NC}"
for migration in "${MIGRATIONS[@]}"; do
    version=$(echo $migration | cut -d: -f1)
    file=$(echo $migration | cut -d: -f2)
    echo -e "   - $version: $file"
done

echo -e "\n${YELLOW}   ⚠️  Миграция 025 (clear_all_flights_data) пропущена - она удаляет данные!${NC}"

read -p "Применить миграции? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Операция отменена${NC}"
    exit 0
fi

# Применение миграций
echo -e "\n${YELLOW}4. Применение миграций...${NC}"

for migration in "${MIGRATIONS[@]}"; do
    version=$(echo $migration | cut -d: -f1)
    file=$(echo $migration | cut -d: -f2)
    
    echo -e "${YELLOW}   Применение миграции $version: $file...${NC}"
    
    # Проверяем, не применена ли уже миграция
    ALREADY_APPLIED=$(ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c \"SELECT COUNT(*) FROM schema_migrations WHERE version = '$version';\"" 2>/dev/null | tr -d ' ' || echo "0")
    
    if [ "$ALREADY_APPLIED" != "0" ]; then
        echo -e "${YELLOW}   ⏭️  Миграция $version уже применена, пропускаем${NC}"
        continue
    fi
    
    # Применяем миграцию
    ssh $SERVER_USER@$SERVER_IP "cd $PROJECT_DIR && \
        cat migrations/$file | docker exec -i $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        # Регистрируем миграцию в schema_migrations
        ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c \
            \"INSERT INTO schema_migrations (version, name) VALUES ('$version', '$(basename $file .sql)') ON CONFLICT (version) DO NOTHING;\"" > /dev/null 2>&1
        
        echo -e "${GREEN}   ✅ Миграция $version применена${NC}"
    else
        echo -e "${RED}   ❌ Ошибка при применении миграции $version${NC}"
    fi
done

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Миграции применены!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"

# Проверка статуса
echo -e "\n${YELLOW}5. Проверка статуса миграций:${NC}"
ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c \"SELECT version, name, executed_at FROM schema_migrations ORDER BY executed_at DESC LIMIT 10;\""


