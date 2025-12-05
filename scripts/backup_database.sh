#!/bin/bash
# Скрипт для создания бэкапа базы данных PostgreSQL
# Использование: ./scripts/backup_database.sh [имя_файла]

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔵 Создание бэкапа базы данных${NC}\n"

# Параметры подключения
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-aviapoint}"
DB_USER="${DB_USER:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-password}"

# Имя файла бэкапа
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${BACKUP_DIR:-./backups}"
BACKUP_FILE="${1:-${BACKUP_DIR}/aviapoint_backup_${TIMESTAMP}.sql}"

# Создаем директорию для бэкапов, если её нет
mkdir -p "$BACKUP_DIR"

echo -e "${YELLOW}📊 Параметры подключения:${NC}"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Backup file: $BACKUP_FILE"
echo ""

# Определяем Docker контейнер PostgreSQL
# Пробуем несколько вариантов имен
DOCKER_CONTAINER=""
USE_DOCKER=false

# Варианты имен контейнеров
POSSIBLE_NAMES=("aviapoint-postgres" "server-side-postgres-database" "postgres" "aviapoint_db")

# Ищем запущенный контейнер PostgreSQL
for name in "${POSSIBLE_NAMES[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${name}$"; then
        DOCKER_CONTAINER="$name"
        USE_DOCKER=true
        break
    fi
done

# Если не нашли запущенный, ищем остановленный
if [ -z "$DOCKER_CONTAINER" ]; then
    for name in "${POSSIBLE_NAMES[@]}"; do
        if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
            DOCKER_CONTAINER="$name"
            echo -e "${YELLOW}⚠️ Docker контейнер найден, но не запущен: $DOCKER_CONTAINER${NC}"
            echo -e "${YELLOW}   Запускаем контейнер...${NC}"
            docker start "$DOCKER_CONTAINER" > /dev/null 2>&1
            sleep 3
            if docker ps --format '{{.Names}}' | grep -q "^${DOCKER_CONTAINER}$"; then
                echo -e "${GREEN}✅ Контейнер запущен${NC}"
                USE_DOCKER=true
                break
            fi
        fi
    done
fi

# Если все еще не нашли, пробуем найти любой контейнер с postgres в имени
if [ -z "$DOCKER_CONTAINER" ]; then
    POSTGRES_CONTAINER=$(docker ps --format '{{.Names}}' | grep -i postgres | head -1)
    if [ -n "$POSTGRES_CONTAINER" ]; then
        DOCKER_CONTAINER="$POSTGRES_CONTAINER"
        USE_DOCKER=true
    fi
fi

if [ "$USE_DOCKER" = true ] && [ -n "$DOCKER_CONTAINER" ]; then
    echo -e "${GREEN}✅ Найден Docker контейнер: $DOCKER_CONTAINER${NC}"
fi

if [ "$USE_DOCKER" = true ] && [ -n "$DOCKER_CONTAINER" ]; then
    echo -e "${YELLOW}📥 Создание бэкапа через Docker (используется pg_dump из контейнера)...${NC}\n"
    
    # Бэкап через Docker (используем pg_dump из контейнера - версия совпадает с сервером)
    docker exec -e PGPASSWORD="$DB_PASSWORD" "$DOCKER_CONTAINER" \
        pg_dump -h localhost -U "$DB_USER" -d "$DB_NAME" \
        --clean --if-exists --create \
        --format=plain \
        --no-owner --no-privileges \
        > "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✅ Бэкап успешно создан: $BACKUP_FILE${NC}"
        
        # Сжимаем бэкап
        if command -v gzip &> /dev/null; then
            echo -e "${YELLOW}📦 Сжатие бэкапа...${NC}"
            gzip "$BACKUP_FILE"
            BACKUP_FILE="${BACKUP_FILE}.gz"
            echo -e "${GREEN}✅ Сжатый бэкап: $BACKUP_FILE${NC}"
        fi
        
        # Размер файла
        FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo -e "${GREEN}📊 Размер файла: $FILE_SIZE${NC}\n"
    else
        echo -e "${RED}❌ Ошибка при создании бэкапа${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️ Docker контейнер не найден, пробуем прямое подключение...${NC}\n"
    
    # Проверяем наличие pg_dump
    if ! command -v pg_dump &> /dev/null; then
        echo -e "${RED}❌ pg_dump не найден. Установите PostgreSQL client tools.${NC}"
        echo -e "${YELLOW}   Или запустите Docker контейнер: docker-compose up -d db${NC}"
        exit 1
    fi
    
    # Проверяем версию pg_dump
    PG_DUMP_VERSION=$(pg_dump --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    echo -e "${YELLOW}📊 Версия локального pg_dump: $PG_DUMP_VERSION${NC}"
    echo -e "${YELLOW}⚠️ Если версия не совпадает с сервером, используйте Docker контейнер${NC}\n"
    
    # Бэкап напрямую
    export PGPASSWORD="$DB_PASSWORD"
    pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        --clean --if-exists --create \
        --format=plain \
        --no-owner --no-privileges \
        > "$BACKUP_FILE" 2>&1
    
    DUMP_EXIT_CODE=$?
    if [ $DUMP_EXIT_CODE -eq 0 ]; then
        echo -e "\n${GREEN}✅ Бэкап успешно создан: $BACKUP_FILE${NC}"
        
        # Сжимаем бэкап
        if command -v gzip &> /dev/null; then
            echo -e "${YELLOW}📦 Сжатие бэкапа...${NC}"
            gzip "$BACKUP_FILE"
            BACKUP_FILE="${BACKUP_FILE}.gz"
            echo -e "${GREEN}✅ Сжатый бэкап: $BACKUP_FILE${NC}"
        fi
        
        # Размер файла
        FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo -e "${GREEN}📊 Размер файла: $FILE_SIZE${NC}\n"
    else
        echo -e "${RED}❌ Ошибка при создании бэкапа${NC}"
        echo -e "${YELLOW}💡 Решение: Используйте Docker контейнер для бэкапа${NC}"
        echo -e "${YELLOW}   Запустите: docker-compose -f docker-compose.prod.yaml up -d db${NC}"
        echo -e "${YELLOW}   Затем снова запустите скрипт бэкапа${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Готово!${NC}"
echo -e "\n${YELLOW}📌 Для восстановления используйте:${NC}"
echo "  psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $BACKUP_FILE"
echo ""
echo "  Или через Docker:"
echo "  docker exec -i $DOCKER_CONTAINER psql -U $DB_USER -d $DB_NAME < $BACKUP_FILE"
echo ""

