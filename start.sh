#!/bin/bash

# AviaPoint Server Startup Script
# Использование: ./start.sh [production|development]

set -e

ENVIRONMENT=${1:-production}
COMPOSE_FILE="docker-compose.${ENVIRONMENT}.yaml"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  AviaPoint Server Startup${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"

# Проверьте наличие docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker не установлен${NC}"
    exit 1
fi

# Проверьте наличие docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose не установлен${NC}"
    exit 1
fi

# Проверьте наличие файла compose
if [ ! -f "$COMPOSE_FILE" ]; then
    echo -e "${RED}❌ Файл $COMPOSE_FILE не найден${NC}"
    exit 1
fi

# Проверьте наличие файла env
if [ ! -f ".env" ] && [ "$ENVIRONMENT" = "production" ]; then
    echo -e "${YELLOW}⚠️  Файл .env не найден, копирую из env.example${NC}"
    cp env.example .env
    echo -e "${YELLOW}⚠️  Отредактируйте .env перед запуском!${NC}"
    exit 1
fi

# Остановите старые контейнеры
echo -e "${YELLOW}Остановка старых контейнеров...${NC}"
docker-compose -f "$COMPOSE_FILE" down || true

# Запустите контейнеры
echo -e "${YELLOW}Запуск контейнеров...${NC}"
docker-compose -f "$COMPOSE_FILE" up -d

# Подождите инициализации
echo -e "${YELLOW}Ожидание инициализации БД...${NC}"
sleep 10

# Проверьте статус
echo -e "\n${GREEN}📊 Статус контейнеров:${NC}"
docker-compose -f "$COMPOSE_FILE" ps

# Выведите информацию о доступе
echo -e "\n${GREEN}✅ Сервис запущен успешно!${NC}"

if [ "$ENVIRONMENT" = "development" ]; then
    echo -e "${GREEN}🔗 Доступные URL:${NC}"
    echo -e "  - API: ${YELLOW}http://localhost:8080${NC}"
    echo -e "  - OpenAPI: ${YELLOW}http://localhost:8080/openapi${NC}"
    echo -e "  - Adminer: ${YELLOW}http://localhost:8082${NC}"
else
    echo -e "${GREEN}🔗 Доступные URL:${NC}"
    echo -e "  - API: ${YELLOW}https://yourdomain.com${NC}"
    echo -e "  - OpenAPI: ${YELLOW}https://yourdomain.com/openapi${NC}"
fi

echo -e "\n${GREEN}📋 Полезные команды:${NC}"
echo -e "  - Логи приложения: ${YELLOW}docker-compose -f $COMPOSE_FILE logs -f app${NC}"
echo -e "  - Логи БД: ${YELLOW}docker-compose -f $COMPOSE_FILE logs -f db${NC}"
echo -e "  - Статистика: ${YELLOW}docker stats${NC}"
echo -e "  - Остановка: ${YELLOW}docker-compose -f $COMPOSE_FILE down${NC}"

echo -e "\n${GREEN}================================${NC}"
