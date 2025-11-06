#!/bin/bash

# Скрипт развертывания на production для avia-point.com

set -e

echo "🚀 Начинается развертывание avia-point.com..."

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Функция для вывода
print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Проверка переменных окружения
print_step "Проверка конфигурации..."

if [ ! -f .env ]; then
    print_error ".env файл не найден!"
    echo "Создайте .env файл из env.example:"
    echo "  cp env.example .env"
    echo "  nano .env"
    exit 1
fi

print_success ".env файл найден"

# Проверка Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker не установлен!"
    exit 1
fi

print_success "Docker установлен"

# Проверка DNS
print_step "Проверка DNS для avia-point.com..."
if ! nslookup avia-point.com &> /dev/null; then
    print_error "DNS для avia-point.com не разрешается!"
    echo "Убедитесь что DNS записи правильно настроены"
    exit 1
fi

print_success "DNS правильно настроены"

# Создание необходимых директорий
print_step "Создание директорий..."
mkdir -p ssl
mkdir -p public
mkdir -p pgdata

print_success "Директории созданы"

# Остановка старых контейнеров
print_step "Остановка старых контейнеров..."
docker-compose -f docker-compose.prod.yaml down || true

print_success "Старые контейнеры остановлены"

# Сборка и запуск приложения
print_step "Сборка Docker образов..."
docker-compose -f docker-compose.prod.yaml build

print_success "Образы собраны"

print_step "Запуск контейнеров..."
docker-compose -f docker-compose.prod.yaml up -d

print_success "Контейнеры запущены"

# Ожидание инициализации БД
print_step "Ожидание инициализации базы данных (30 секунд)..."
sleep 30

# Проверка здоровья сервисов
print_step "Проверка здоровья сервисов..."

# Проверим каждый сервис
for service in db app certbot nginx; do
    if docker-compose -f docker-compose.prod.yaml ps $service | grep -q "Up"; then
        print_success "$service запущен"
    else
        print_error "$service не запущен!"
        docker-compose -f docker-compose.prod.yaml logs $service | tail -20
        exit 1
    fi
done

# Ожидание получения сертификата
print_step "Ожидание получения SSL сертификата (может занять до 2 минут)..."
max_attempts=24
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if [ -f "ssl/live/avia-point.com/fullchain.pem" ]; then
        print_success "SSL сертификат получен!"
        break
    fi
    
    attempt=$((attempt + 1))
    if [ $attempt -eq $max_attempts ]; then
        print_error "SSL сертификат не получен!"
        echo "Проверьте логи certbot:"
        docker logs aviapoint-certbot
        exit 1
    fi
    
    echo "  Попытка $attempt/$max_attempts... ожидание"
    sleep 5
done

# Перезагрузка nginx для применения сертификата
print_step "Перезагрузка nginx..."
docker exec aviapoint-nginx nginx -s reload

print_success "Nginx перезагружен"

# Проверка HTTPS
print_step "Проверка HTTPS доступности..."
if curl -sf https://avia-point.com/openapi > /dev/null 2>&1; then
    print_success "HTTPS доступен"
else
    print_error "HTTPS недоступен!"
    echo "Проверьте логи:"
    docker-compose -f docker-compose.prod.yaml logs
    exit 1
fi

# Финальный отчет
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Развертывание завершено успешно!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "📍 Адреса сервисов:"
echo "  🌐 Основное приложение: https://avia-point.com"
echo "  📚 API документация: https://avia-point.com/openapi"
echo "  🗄️  Adminer (БД): http://YOUR_VPS_IP:8082"
echo ""
echo "📋 Полезные команды:"
echo "  Просмотр логов: docker-compose -f docker-compose.prod.yaml logs -f"
echo "  Статус сервисов: docker-compose -f docker-compose.prod.yaml ps"
echo "  Остановка: docker-compose -f docker-compose.prod.yaml down"
echo ""
echo "🔒 SSL сертификат действителен до:"
openssl x509 -in ssl/live/avia-point.com/fullchain.pem -noout -enddate
echo ""

