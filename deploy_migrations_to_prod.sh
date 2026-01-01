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

# Список новых миграций (после последней примененной)
echo -e "${YELLOW}4. Новые миграции для применения:${NC}"
echo -e "   - 022: create_airport_visitor_photos_table"
echo -e "   - 023: add_visitor_photos_to_airports"
echo -e "   - 024: create_flight_waypoints_table"
echo -e "   - 025: clear_all_flights_data (⚠️  удаляет данные!)"
echo -e "   - 026: create_flight_questions_table"
echo -e "   - 027: remove_subscription_fields_from_profiles"
echo -e "   - 028: remove_unique_active_subscription_index"
echo -e "   - 029: add_telegram_and_max_to_profiles"
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


