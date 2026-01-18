#!/bin/bash

# Скрипт для синхронизации файлов миграций на продакшн
# Использование: ./sync_migrations_to_prod.sh [server_ip]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
LOCAL_MIGRATIONS_DIR="migrations"
REMOTE_MIGRATIONS_DIR="/home/aviapoint_server/migrations"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Синхронизация миграций на продакшн${NC}"
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

# Проверка существования локальной папки migrations
if [ ! -d "$LOCAL_MIGRATIONS_DIR" ]; then
    echo -e "${RED}❌ Локальная папка migrations не найдена: $LOCAL_MIGRATIONS_DIR${NC}"
    exit 1
fi

echo -e "\n${YELLOW}2. Синхронизация файлов миграций...${NC}"

# Автоматически получаем список всех .sql файлов из папки migrations
REQUIRED_MIGRATIONS=($(find "$LOCAL_MIGRATIONS_DIR" -name "*.sql" -type f -exec basename {} \; | sort))

if [ ${#REQUIRED_MIGRATIONS[@]} -eq 0 ]; then
    echo -e "${RED}❌ Не найдено файлов миграций в папке $LOCAL_MIGRATIONS_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}Найдено файлов миграций: ${#REQUIRED_MIGRATIONS[@]}${NC}\n"

COPIED_COUNT=0
MISSING_COUNT=0
EXISTING_COUNT=0
SKIPPED_COUNT=0

for migration_file in "${REQUIRED_MIGRATIONS[@]}"; do
    local_file="$LOCAL_MIGRATIONS_DIR/$migration_file"
    remote_file="$REMOTE_MIGRATIONS_DIR/$migration_file"
    
    # Проверяем, существует ли файл локально
    if [ ! -f "$local_file" ]; then
        echo -e "   ${RED}✗${NC} $migration_file (не найден локально)"
        ((MISSING_COUNT++))
        continue
    fi
    
    if [ "$IS_ON_SERVER" = false ]; then
        # Локально - через SSH
        if ssh $SERVER_USER@$SERVER_IP "[ -f \"$remote_file\" ]" 2>/dev/null; then
            # Проверяем, отличается ли файл (опционально - можно пропустить для ускорения)
            # Для простоты просто пропускаем существующие файлы
            ((EXISTING_COUNT++))
            echo -e "   ${YELLOW}⊘${NC} $migration_file (уже существует)"
        else
            # Копируем файл
            scp "$local_file" $SERVER_USER@$SERVER_IP:"$remote_file" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo -e "   ${GREEN}✓${NC} $migration_file"
                ((COPIED_COUNT++))
            else
                echo -e "   ${RED}✗${NC} $migration_file (ошибка копирования)"
                ((MISSING_COUNT++))
            fi
        fi
    else
        # На сервере - напрямую
        if [ -f "$remote_file" ]; then
            ((EXISTING_COUNT++))
            echo -e "   ${YELLOW}⊘${NC} $migration_file (уже существует)"
        else
            # Копируем из локальной папки (если запущено на сервере, но файл в другом месте)
            if [ -f "$local_file" ]; then
                cp "$local_file" "$remote_file" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "   ${GREEN}✓${NC} $migration_file"
                    ((COPIED_COUNT++))
                else
                    echo -e "   ${RED}✗${NC} $migration_file (ошибка копирования)"
                    ((MISSING_COUNT++))
                fi
            else
                echo -e "   ${RED}✗${NC} $migration_file (не найден)"
                ((MISSING_COUNT++))
            fi
        fi
    fi
done

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Синхронизация завершена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${YELLOW}Статистика:${NC}"
echo -e "   Скопировано файлов: ${GREEN}$COPIED_COUNT${NC}"
echo -e "   Уже существовало: ${YELLOW}$EXISTING_COUNT${NC}"
echo -e "   Не найдено/ошибок: ${RED}$MISSING_COUNT${NC}"
echo -e "   Всего обработано: ${BLUE}${#REQUIRED_MIGRATIONS[@]}${NC}"

if [ $MISSING_COUNT -gt 0 ]; then
    echo -e "\n${RED}⚠️  Внимание: некоторые файлы не были скопированы!${NC}"
    echo -e "${YELLOW}   Убедитесь, что все файлы миграций присутствуют локально${NC}"
fi


