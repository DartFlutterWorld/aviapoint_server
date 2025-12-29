#!/bin/bash

# Скрипт для проверки логов сервера на продакшн
# Использование: ./check_server_logs.sh [server_ip] [lines_count]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
LINES=${2:-50}

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Логи сервера на продакшн (последние $LINES строк)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Проверяем, запущен ли скрипт на сервере или локально
IS_ON_SERVER=false
if [ -f "/home/aviapoint_server/docker-compose.prod.yaml" ] || [ "$(pwd)" = "/home/aviapoint_server" ]; then
    IS_ON_SERVER=true
    echo -e "${YELLOW}Скрипт запущен на сервере${NC}\n"
fi

# Проверка статуса контейнера
echo -e "${YELLOW}1. Статус контейнера:${NC}"
if [ "$IS_ON_SERVER" = false ]; then
    ssh $SERVER_USER@$SERVER_IP "docker ps --filter 'name=aviapoint-server' --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" 2>/dev/null
else
    docker ps --filter 'name=aviapoint-server' --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null
fi

# Логи сервера
echo -e "\n${YELLOW}2. Последние логи сервера:${NC}"
if [ "$IS_ON_SERVER" = false ]; then
    ssh $SERVER_USER@$SERVER_IP "docker logs --tail $LINES aviapoint-server 2>&1" | tail -$LINES
else
    docker logs --tail $LINES aviapoint-server 2>&1 | tail -$LINES
fi

# Проверка ошибок в логах
echo -e "\n${YELLOW}3. Поиск ошибок в логах:${NC}"
if [ "$IS_ON_SERVER" = false ]; then
    ERROR_COUNT=$(ssh $SERVER_USER@$SERVER_IP "docker logs aviapoint-server 2>&1 | grep -i 'error\|exception\|failed\|fatal' | wc -l" 2>/dev/null)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${RED}Найдено ошибок: $ERROR_COUNT${NC}"
        echo -e "${YELLOW}Последние ошибки:${NC}"
        ssh $SERVER_USER@$SERVER_IP "docker logs aviapoint-server 2>&1 | grep -i 'error\|exception\|failed\|fatal' | tail -10" 2>/dev/null
    else
        echo -e "${GREEN}Ошибок не найдено${NC}"
    fi
else
    ERROR_COUNT=$(docker logs aviapoint-server 2>&1 | grep -i 'error\|exception\|failed\|fatal' | wc -l 2>/dev/null)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${RED}Найдено ошибок: $ERROR_COUNT${NC}"
        echo -e "${YELLOW}Последние ошибки:${NC}"
        docker logs aviapoint-server 2>&1 | grep -i 'error\|exception\|failed\|fatal' | tail -10
    else
        echo -e "${GREEN}Ошибок не найдено${NC}"
    fi
fi

# Проверка доступности API
echo -e "\n${YELLOW}4. Проверка доступности API:${NC}"
sleep 2

if [ "$IS_ON_SERVER" = false ]; then
    API_RESPONSE=$(ssh $SERVER_USER@$SERVER_IP "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/api/category_news" 2>/dev/null)
    NGINX_RESPONSE=$(ssh $SERVER_USER@$SERVER_IP "curl -s -o /dev/null -w '%{http_code}' http://localhost/api/category_news" 2>/dev/null)
else
    API_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/api/category_news 2>/dev/null)
    NGINX_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost/api/category_news 2>/dev/null)
fi

echo -e "   Прямой доступ (порт 8080): ${GREEN}HTTP $API_RESPONSE${NC}"
echo -e "   Через nginx (порт 80): ${GREEN}HTTP $NGINX_RESPONSE${NC}"

# Проверка nginx логов
echo -e "\n${YELLOW}5. Последние логи nginx:${NC}"
if [ "$IS_ON_SERVER" = false ]; then
    ssh $SERVER_USER@$SERVER_IP "docker logs --tail 20 aviapoint-nginx 2>&1" | tail -20
else
    docker logs --tail 20 aviapoint-nginx 2>&1 | tail -20
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"

