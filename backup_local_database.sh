#!/bin/bash

# Скрипт для создания бэкапа локальной базы данных
# Использование: ./backup_local_database.sh

DB_HOST=${POSTGRESQL_HOST:-"127.0.0.1"}
DB_PORT=${POSTGRESQL_PORT:-"5432"}
DB_NAME="aviapoint"
DB_USER="postgres"
DB_PASSWORD=${POSTGRESQL_PASSWORD:-"password"}

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/aviapoint_local_backup_${TIMESTAMP}.sql"
COMPRESSED_FILE="${BACKUP_FILE}.gz"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Создание бэкапа локальной базы данных${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Создаем директорию для бэкапов, если её нет
mkdir -p "$BACKUP_DIR"

# Проверяем подключение к БД
echo -e "${YELLOW}1. Проверка подключения к локальной БД...${NC}"
if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${RED}❌ Не удалось подключиться к локальной БД!${NC}"
    echo -e "${YELLOW}Проверьте параметры подключения:${NC}"
    echo -e "   Host: $DB_HOST"
    echo -e "   Port: $DB_PORT"
    echo -e "   Database: $DB_NAME"
    echo -e "   User: $DB_USER"
    exit 1
fi
echo -e "${GREEN}✅ Подключение к локальной БД успешно${NC}\n"

# Создаем бэкап
echo -e "${YELLOW}2. Создание бэкапа...${NC}"
echo -e "${BLUE}   Файл: $BACKUP_FILE${NC}"

# Пробуем использовать Docker контейнер, если доступен
if command -v docker >/dev/null 2>&1; then
    # Ищем PostgreSQL контейнер
    POSTGRES_CONTAINER=$(docker ps --filter "name=postgres" --format "{{.Names}}" 2>/dev/null | head -1)
    if [ ! -z "$POSTGRES_CONTAINER" ]; then
        echo -e "${BLUE}   Используется Docker контейнер: $POSTGRES_CONTAINER${NC}"
        if docker exec -e PGPASSWORD="$DB_PASSWORD" "$POSTGRES_CONTAINER" pg_dump -U "$DB_USER" -d "$DB_NAME" \
            --no-owner \
            --no-privileges \
            > "$BACKUP_FILE" 2>&1; then
            echo -e "${GREEN}✅ Бэкап создан успешно${NC}"
        else
            echo -e "${RED}❌ Ошибка при создании бэкапа через Docker!${NC}"
            echo -e "${YELLOW}Пробуем прямое подключение...${NC}"
            # Пробуем прямое подключение с игнорированием версии
            PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
                --no-owner \
                --no-privileges \
                --version=15.0 \
                > "$BACKUP_FILE" 2>&1 || true
        fi
    else
        # Прямое подключение
        PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
            --no-owner \
            --no-privileges \
            > "$BACKUP_FILE" 2>&1
    fi
else
    # Прямое подключение
    PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        --no-owner \
        --no-privileges \
        > "$BACKUP_FILE" 2>&1
fi

# Проверяем результат
if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ] && ! grep -q "error\|ERROR\|aborting" "$BACKUP_FILE"; then
    echo -e "${GREEN}✅ Бэкап создан успешно${NC}"
else
    echo -e "${RED}❌ Ошибка при создании бэкапа!${NC}"
    if [ -f "$BACKUP_FILE" ]; then
        echo -e "${YELLOW}Последние строки вывода:${NC}"
        tail -20 "$BACKUP_FILE"
    fi
    exit 1
fi

# Проверяем размер файла
FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo -e "${BLUE}   Размер: $FILE_SIZE${NC}\n"

# Сжимаем бэкап
echo -e "${YELLOW}3. Сжатие бэкапа...${NC}"
if gzip -f "$BACKUP_FILE"; then
    echo -e "${GREEN}✅ Бэкап сжат успешно${NC}"
else
    echo -e "${RED}❌ Ошибка при сжатии бэкапа!${NC}"
    exit 1
fi

# Проверяем размер сжатого файла
COMPRESSED_SIZE=$(du -h "$COMPRESSED_FILE" | cut -f1)
echo -e "${BLUE}   Размер после сжатия: $COMPRESSED_SIZE${NC}\n"

# Итоговая информация
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Бэкап локальной БД создан успешно!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${YELLOW}📄 Файл бэкапа:${NC}"
echo -e "   $COMPRESSED_FILE"
echo -e "\n${YELLOW}💾 Размер:${NC}"
echo -e "   $COMPRESSED_SIZE"
echo -e "\n${YELLOW}📅 Дата создания:${NC}"
echo -e "   $(date)"
echo ""
