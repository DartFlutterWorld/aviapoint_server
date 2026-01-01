#!/bin/bash

# Скрипт для синхронизации структуры папки public на продакшн
# Создает только директории, файлы НЕ копируются
# Использование: ./sync_public_structure_to_prod.sh [server_ip]

SERVER_IP=${1:-"83.166.246.205"}
SERVER_USER="root"
LOCAL_PUBLIC_DIR="public"
REMOTE_PUBLIC_DIR="/home/aviapoint_server/public"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Синхронизация структуры папки public на продакшн${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Проверяем, запущен ли скрипт на сервере или локально
IS_ON_SERVER=false
if [ -f "/home/aviapoint_server/docker-compose.prod.yaml" ] || [ "$(pwd)" = "/home/aviapoint_server" ]; then
    IS_ON_SERVER=true
    echo -e "${YELLOW}1. Скрипт запущен на сервере${NC}"
    LOCAL_PUBLIC_DIR="public"
else
    # Проверка подключения к серверу
    echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
    if ! ssh -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo 'OK'" > /dev/null 2>&1; then
        echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Подключение установлено${NC}"
fi

# Проверка существования локальной папки public
if [ ! -d "$LOCAL_PUBLIC_DIR" ]; then
    echo -e "${RED}❌ Локальная папка public не найдена: $LOCAL_PUBLIC_DIR${NC}"
    exit 1
fi

echo -e "\n${YELLOW}2. Анализ структуры локальной папки public...${NC}"

# Функция для получения всех директорий (рекурсивно)
get_directories() {
    find "$1" -type d | sed "s|^$1/||" | grep -v "^$" | sort
}

# Получаем список всех директорий
DIRECTORIES=$(get_directories "$LOCAL_PUBLIC_DIR")
DIR_COUNT=$(echo "$DIRECTORIES" | wc -l | tr -d ' ')

echo -e "${GREEN}✅ Найдено директорий: $DIR_COUNT${NC}"

# Предупреждение
echo -e "\n${YELLOW}3. Внимание!${NC}"
echo -e "${YELLOW}   Будут созданы только директории (без файлов)${NC}"
echo -e "${YELLOW}   Существующие директории будут пропущены${NC}"
echo ""

read -p "Продолжить? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Операция отменена${NC}"
    exit 0
fi

# Создание директорий на сервере
echo -e "\n${YELLOW}4. Создание директорий на продакшн...${NC}"

CREATED_COUNT=0
EXISTING_COUNT=0

while IFS= read -r dir; do
    if [ -z "$dir" ]; then
        continue
    fi
    
    remote_path="$REMOTE_PUBLIC_DIR/$dir"
    
    if [ "$IS_ON_SERVER" = false ]; then
        # Локально - через SSH
        if ssh $SERVER_USER@$SERVER_IP "[ -d \"$remote_path\" ]" 2>/dev/null; then
            ((EXISTING_COUNT++))
        else
            ssh $SERVER_USER@$SERVER_IP "mkdir -p \"$remote_path\"" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "   ${GREEN}✓${NC} $dir"
                ((CREATED_COUNT++))
            else
                echo -e "   ${RED}✗${NC} $dir (ошибка создания)"
            fi
        fi
    else
        # На сервере - напрямую
        if [ -d "$remote_path" ]; then
            ((EXISTING_COUNT++))
        else
            mkdir -p "$remote_path" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "   ${GREEN}✓${NC} $dir"
                ((CREATED_COUNT++))
            else
                echo -e "   ${RED}✗${NC} $dir (ошибка создания)"
            fi
        fi
    fi
done <<< "$DIRECTORIES"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Синхронизация завершена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${YELLOW}Статистика:${NC}"
echo -e "   Создано директорий: ${GREEN}$CREATED_COUNT${NC}"
echo -e "   Уже существовало: ${YELLOW}$EXISTING_COUNT${NC}"
echo -e "   Всего обработано: $DIR_COUNT"


