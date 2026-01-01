#!/bin/bash

# Скрипт для проверки и перезапуска сервера на продакшн
# Использование: ./check_and_restart_server.sh [server_ip]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Проверка и перезапуск сервера на продакшн${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Проверяем, запущен ли скрипт на сервере или локально
IS_ON_SERVER=false
if [ -f "/home/aviapoint_server/docker-compose.prod.yaml" ] || [ "$(pwd)" = "/home/aviapoint_server" ]; then
    IS_ON_SERVER=true
    echo -e "${YELLOW}1. Скрипт запущен на сервере${NC}"
else
    # Проверка подключения к серверу
    echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
    if ! ssh -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo 'OK'" > /dev/null 2>&1; then
        echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Подключение установлено${NC}"
fi

# Проверка статуса контейнера
echo -e "\n${YELLOW}2. Проверка статуса контейнера сервера...${NC}"

if [ "$IS_ON_SERVER" = false ]; then
    CONTAINER_STATUS=$(ssh $SERVER_USER@$SERVER_IP "docker ps -a --filter 'name=aviapoint-server' --format '{{.Status}}'" 2>/dev/null)
    CONTAINER_RUNNING=$(ssh $SERVER_USER@$SERVER_IP "docker ps --filter 'name=aviapoint-server' --format '{{.Names}}'" 2>/dev/null)
else
    CONTAINER_STATUS=$(docker ps -a --filter 'name=aviapoint-server' --format '{{.Status}}' 2>/dev/null)
    CONTAINER_RUNNING=$(docker ps --filter 'name=aviapoint-server' --format '{{.Names}}' 2>/dev/null)
fi

if [ -z "$CONTAINER_RUNNING" ]; then
    echo -e "${RED}❌ Контейнер сервера НЕ запущен!${NC}"
    echo -e "${YELLOW}   Статус: $CONTAINER_STATUS${NC}"
    
    echo -e "\n${YELLOW}3. Перезапуск сервера...${NC}"
    if [ "$IS_ON_SERVER" = false ]; then
        ssh $SERVER_USER@$SERVER_IP "cd /home/aviapoint_server && docker-compose -f docker-compose.prod.yaml up -d app" 2>&1
    else
        cd /home/aviapoint_server && docker-compose -f docker-compose.prod.yaml up -d app 2>&1
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Сервер перезапущен${NC}"
    else
        echo -e "${RED}❌ Ошибка при перезапуске сервера!${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Контейнер сервера запущен${NC}"
    echo -e "${YELLOW}   Статус: $CONTAINER_STATUS${NC}"
fi

# Проверка логов (последние 20 строк)
echo -e "\n${YELLOW}4. Последние логи сервера:${NC}"
if [ "$IS_ON_SERVER" = false ]; then
    ssh $SERVER_USER@$SERVER_IP "docker logs --tail 20 aviapoint-server 2>&1" | tail -20
else
    docker logs --tail 20 aviapoint-server 2>&1 | tail -20
fi

# Проверка доступности API
echo -e "\n${YELLOW}5. Проверка доступности API...${NC}"
sleep 3

if [ "$IS_ON_SERVER" = false ]; then
    API_RESPONSE=$(ssh $SERVER_USER@$SERVER_IP "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/api/category_news" 2>/dev/null)
else
    API_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/api/category_news 2>/dev/null)
fi

if [ "$API_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ API доступен (HTTP $API_RESPONSE)${NC}"
else
    echo -e "${YELLOW}⚠️  API вернул код: $API_RESPONSE${NC}"
    echo -e "${YELLOW}   Возможно, сервер еще запускается...${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Проверка завершена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"


