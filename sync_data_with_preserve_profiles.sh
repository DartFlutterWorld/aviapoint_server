#!/bin/bash

# Скрипт для синхронизации данных с локальной БД на продакшн
# С сохранением профилей пользователей из продакшн
# Использование: ./sync_data_with_preserve_profiles.sh [--yes|-y] [SERVER_IP]

# Проверка флагов автоматического подтверждения
AUTO_CONFIRM=false
if [[ "$1" == "--yes" ]] || [[ "$1" == "-y" ]] || [[ "${AUTO_CONFIRM_ENV}" == "true" ]]; then
    AUTO_CONFIRM=true
    SERVER_IP=${2:-"83.166.246.205"}
else
    SERVER_IP=${1:-"83.166.246.205"}
fi
SERVER_USER="root"
SERVER_PASSWORD=${SERVER_PASSWORD:-"uOTC0OWjMVIoaRxI"}
LOCAL_DB_CONTAINER="aviapoint-postgres"
SERVER_DB_CONTAINER="aviapoint-postgres"
DB_NAME="aviapoint"
DB_USER="postgres"

# Функция для выполнения SSH команд с паролем
ssh_with_password() {
    if command -v sshpass >/dev/null 2>&1; then
        sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$@"
    elif command -v expect >/dev/null 2>&1; then
        # Используем expect для автоматического ввода пароля
        # Используем eval для правильной обработки аргументов с кавычками
        local expect_file=$(mktemp)
        {
            echo "set timeout 30"
            echo "set ssh_args {}"
            for arg in "$@"; do
                # Экранируем специальные символы для Tcl/expect
                # Заменяем кавычки на экранированные кавычки и обрамляем в двойные кавычки
                arg_escaped=$(printf '%s' "$arg" | sed 's/\\/\\\\/g; s/\[/\\\[/g; s/\]/\\\]/g; s/\$/\\\$/g; s/"/\\"/g; s/`/\\`/g')
                echo "lappend ssh_args \"$arg_escaped\""
            done
            echo 'eval spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $ssh_args'
            echo "expect {"
            echo '    "password:" {'
            echo "        send \"$SERVER_PASSWORD\\r\""
            echo "        exp_continue"
            echo "    }"
            echo '    "yes/no" {'
            echo '        send "yes\r"'
            echo "        exp_continue"
            echo "    }"
            echo "    eof"
            echo "}"
            echo "catch wait result"
            echo "exit [lindex \$result 3]"
        } > "$expect_file"
        expect -f "$expect_file"
        local exit_code=$?
        rm -f "$expect_file"
        return $exit_code
    else
        echo -e "${YELLOW}⚠️  sshpass и expect не установлены. Используется обычный SSH (может потребоваться ввод пароля вручную)${NC}" >&2
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$@"
    fi
}

# Функция для выполнения SCP с паролем
scp_with_password() {
    if command -v sshpass >/dev/null 2>&1; then
        sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no "$@"
    elif command -v expect >/dev/null 2>&1; then
        # Используем expect для автоматического ввода пароля
        expect <<EOF
set timeout 30
spawn scp -o StrictHostKeyChecking=no $*
expect {
    "password:" {
        send "$SERVER_PASSWORD\r"
        exp_continue
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    eof
}
catch wait result
exit [lindex \$result 3]
EOF
    else
        echo -e "${YELLOW}⚠️  sshpass и expect не установлены. Используется обычный SCP (может потребоваться ввод пароля вручную)${NC}" >&2
        scp -o StrictHostKeyChecking=no "$@"
    fi
}

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Синхронизация данных (локальная -> продакшн)${NC}"
echo -e "${BLUE}  С сохранением профилей из продакшн${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Проверка подключения к серверу
echo -e "${YELLOW}1. Проверка подключения к серверу...${NC}"
echo -e "${YELLOW}   Если потребуется, введите пароль для SSH подключения${NC}"
if ! ssh_with_password $SERVER_USER@$SERVER_IP "echo 'OK'" 2>&1; then
    echo -e "${RED}❌ Не удалось подключиться к серверу!${NC}"
    echo -e "${YELLOW}   Возможные причины:${NC}"
    echo -e "   - Неверный пароль"
    echo -e "   - SSH ключ не добавлен в агент (выполните: ssh-add ~/.ssh/id_rsa)"
    echo -e "   - SSH ключ не добавлен на сервер"
    echo -e "   - Неверный IP адрес или пользователь"
    echo -e ""
    echo -e "${YELLOW}   Попробуйте подключиться вручную:${NC}"
    echo -e "   ssh $SERVER_USER@$SERVER_IP"
    exit 1
fi
echo -e "${GREEN}✅ Подключение установлено${NC}"

# Проверка локальной БД
echo -e "\n${YELLOW}2. Проверка локальной БД...${NC}"
if ! docker ps | grep -q $LOCAL_DB_CONTAINER; then
    echo -e "${RED}❌ Локальный контейнер БД не запущен!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Локальная БД доступна${NC}"

# Создание временной директории
TEMP_DIR=$(mktemp -d)
BACKUP_DIR="$TEMP_DIR/backup"
mkdir -p $BACKUP_DIR

# Создание полной резервной копии БД на продакшн
echo -e "\n${YELLOW}3. Создание полной резервной копии БД на продакшн...${NC}"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/tmp/aviapoint_backup_${BACKUP_TIMESTAMP}.sql"
BACKUP_FILE_LOCAL="$BACKUP_DIR/aviapoint_backup_${BACKUP_TIMESTAMP}.sql"

echo -e "${YELLOW}   Создание резервной копии на сервере: $BACKUP_FILE${NC}"
# Создаем полную резервную копию БД (структура + данные)
ssh_with_password $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME \
  --clean \
  --if-exists \
  --format=plain \
  --no-owner \
  --no-privileges" > $BACKUP_FILE_LOCAL

if [ $? -ne 0 ] || [ ! -s "$BACKUP_FILE_LOCAL" ]; then
    echo -e "${RED}❌ Ошибка при создании резервной копии БД!${NC}"
    rm -rf $TEMP_DIR
    exit 1
fi

# Также сохраняем на сервере
scp_with_password $BACKUP_FILE_LOCAL $SERVER_USER@$SERVER_IP:$BACKUP_FILE > /dev/null 2>&1

BACKUP_SIZE=$(du -h "$BACKUP_FILE_LOCAL" | cut -f1)
echo -e "${GREEN}✅ Резервная копия создана:${NC}"
echo -e "${GREEN}   Локально: $BACKUP_FILE_LOCAL (размер: $BACKUP_SIZE)${NC}"
echo -e "${GREEN}   На сервере: $BACKUP_FILE (размер: $BACKUP_SIZE)${NC}"
echo -e "${YELLOW}   Для восстановления используйте:${NC}"
echo -e "${YELLOW}   cat $BACKUP_FILE | docker exec -i aviapoint-postgres psql -U postgres${NC}"

# Таблицы, которые нужно синхронизировать (данные из локальной БД)
SYNC_TABLES=(
    "aircraft_manufacturers"
    "aircraft_models"
    "aircraft_model_specs"
    "app_settings"
    "blog_categories"
    "blog_tags"
    "subscription_types"
    "airports"
    "hand_book_main_categories"
    "normal_categories"
    "emergency_categories"
    "preflight_inspection_categories"
    "preflight_inspection_check_list"
    "normal_check_list"
    "rosaviatest_category"
    "rosaviatest_questions"
    "rosaviatest_answers"
    "type_certificates"
    "question_type_certificates"
    "rosaviatest_type_certificates_category"
    "type_correct_answers"
)

# Таблицы, которые НЕ нужно синхронизировать (сохраняем из продакшн)
PRESERVE_TABLES=(
    "profiles"
    "flights"
    "bookings"
    "reviews"
    "airport_reviews"
    "airport_feedback"
    "airport_ownership_requests"
    "flight_photos"
    "flight_waypoints"
    "flight_questions"
    "blog_articles"
    "blog_article_tags"
    "blog_comments"
    "payments"
    "subscriptions"
    "stories"
    "news"
    "category_news"
    "video"
    "feedback"
    "airport_visitor_photos"
)

echo -e "\n${YELLOW}4. Создание резервной копии профилей с продакшн...${NC}"
PROFILES_BACKUP="$BACKUP_DIR/profiles_backup.sql"
ssh_with_password $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME \
  -t profiles \
  --data-only \
  --column-inserts" > $PROFILES_BACKUP

if [ $? -ne 0 ] || [ ! -s "$PROFILES_BACKUP" ]; then
    echo -e "${RED}❌ Ошибка при создании резервной копии профилей!${NC}"
    rm -rf $TEMP_DIR
    exit 1
fi

PROFILES_COUNT=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c 'SELECT COUNT(*) FROM profiles;'" 2>/dev/null | grep -v "spawn" | grep -v "password" | tr -d ' \n\r' || echo "0")
echo -e "${GREEN}✅ Резервная копия создана: $PROFILES_BACKUP (${PROFILES_COUNT} профилей)${NC}"

# Предупреждение
echo -e "\n${YELLOW}5. Внимание!${NC}"
echo -e "${RED}   Это заменит данные на продакшн!${NC}"
echo -e "${YELLOW}   Будут синхронизированы следующие таблицы:${NC}"
for table in "${SYNC_TABLES[@]}"; do
    echo -e "   - $table"
done
echo -e ""
echo -e "${YELLOW}   НЕ будут затронуты (сохранятся из продакшн):${NC}"
for table in "${PRESERVE_TABLES[@]}"; do
    echo -e "   - $table"
done
echo ""
if [ "$AUTO_CONFIRM" = true ]; then
    echo -e "${YELLOW}Продолжить? (y/n): y (автоматическое подтверждение)${NC}"
    REPLY="y"
else
    echo -e "${YELLOW}Продолжить? (y/n): ${NC}"
    read -n 1 -r
    echo
fi
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Операция отменена${NC}"
    rm -rf $TEMP_DIR
    exit 0
fi

# Проверка существования таблиц на продакшн
echo -e "\n${YELLOW}5.1. Проверка существования таблиц на продакшн...${NC}"
MISSING_TABLES=()
for table in "${SYNC_TABLES[@]}"; do
    TABLE_EXISTS=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table');\"" 2>/dev/null | grep -v "spawn" | grep -v "password" | tr -d ' \n\r' || echo "f")
    if [[ "$TABLE_EXISTS" != "t" ]]; then
        MISSING_TABLES+=("$table")
        echo -e "${RED}   ⚠️  Таблица $table не существует на продакшн${NC}"
    else
        echo -e "${GREEN}   ✅ Таблица $table существует${NC}"
    fi
done

if [ ${#MISSING_TABLES[@]} -gt 0 ]; then
    echo -e "\n${RED}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}❌ ОШИБКА: На продакшн отсутствуют следующие таблицы:${NC}"
    for table in "${MISSING_TABLES[@]}"; do
        echo -e "${RED}   - $table${NC}"
    done
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Перед синхронизацией данных необходимо применить миграции!${NC}"
    echo -e "${YELLOW}Выполните на продакшн:${NC}"
    echo -e "${YELLOW}   ./deploy_migrations_to_prod.sh${NC}"
    echo -e "${YELLOW}   или${NC}"
    echo -e "${YELLOW}   docker exec aviapoint-postgres psql -U postgres -d aviapoint -f /path/to/migration.sql${NC}"
    echo ""
    rm -rf $TEMP_DIR
    exit 1
fi

# Экспорт данных из локальной БД
echo -e "\n${YELLOW}6. Экспорт данных из локальной БД...${NC}"
DATA_FILE="$TEMP_DIR/data_export.sql"

# Создаем SQL файл с данными для синхронизации
echo "-- Экспорт данных для синхронизации" > $DATA_FILE
echo "-- Исключены: profiles и связанные таблицы" >> $DATA_FILE
echo "" >> $DATA_FILE

for table in "${SYNC_TABLES[@]}"; do
    echo -e "${YELLOW}   Экспорт таблицы: $table${NC}"
    docker exec $LOCAL_DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME \
      -t $table \
      --data-only \
      --column-inserts >> $DATA_FILE 2>/dev/null
    
    if [ $? -eq 0 ]; then
        COUNT=$(docker exec $LOCAL_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM $table;" 2>/dev/null | tr -d ' ' || echo "0")
        echo -e "${GREEN}     ✅ $table: $COUNT записей${NC}"
    else
        echo -e "${YELLOW}     ⚠️  $table: таблица не найдена или пуста${NC}"
    fi
done

FILE_SIZE=$(du -h "$DATA_FILE" | cut -f1)
echo -e "${GREEN}✅ Экспорт завершен: $DATA_FILE (размер: $FILE_SIZE)${NC}"

# Копирование файла на сервер
echo -e "\n${YELLOW}7. Копирование данных на сервер...${NC}"
scp_with_password $DATA_FILE $SERVER_USER@$SERVER_IP:/tmp/data_export.sql > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при копировании файла на сервер!${NC}"
    rm -rf $TEMP_DIR
    exit 1
fi
echo -e "${GREEN}✅ Файл скопирован на сервер${NC}"

# Применение данных на продакшн
echo -e "\n${YELLOW}8. Применение данных на продакшн...${NC}"
echo -e "${YELLOW}   Это может занять некоторое время...${NC}"

# Сначала очищаем таблицы на продакшн (кроме profiles)
for table in "${SYNC_TABLES[@]}"; do
    echo -e "${YELLOW}   Очистка таблицы: $table${NC}"
    ssh_with_password $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c \"TRUNCATE TABLE $table CASCADE;\"" > /dev/null 2>&1
done

# Затем импортируем данные
ssh_with_password $SERVER_USER@$SERVER_IP "cat /tmp/data_export.sql | docker exec -i $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Данные применены${NC}"
else
    echo -e "${YELLOW}⚠️  Применение завершено (возможны предупреждения)${NC}"
fi

# Проверка, что профили не затронуты
echo -e "\n${YELLOW}9. Проверка сохранности профилей...${NC}"
NEW_PROFILES_COUNT=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c 'SELECT COUNT(*) FROM profiles;'" 2>/dev/null | grep -v "spawn" | grep -v "password" | tr -d ' \n\r' || echo "0")

if [ "$PROFILES_COUNT" == "$NEW_PROFILES_COUNT" ]; then
    echo -e "${GREEN}✅ Профили сохранены: $NEW_PROFILES_COUNT записей${NC}"
else
    echo -e "${RED}❌ ВНИМАНИЕ! Количество профилей изменилось!${NC}"
    echo -e "${RED}   Было: $PROFILES_COUNT, Стало: $NEW_PROFILES_COUNT${NC}"
    echo -e "${YELLOW}   Восстановление из резервной копии...${NC}"
    
    # Восстановление профилей
    scp_with_password $PROFILES_BACKUP $SERVER_USER@$SERVER_IP:/tmp/profiles_restore.sql > /dev/null 2>&1
    ssh_with_password $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c 'TRUNCATE TABLE profiles CASCADE;'" > /dev/null 2>&1
    ssh_with_password $SERVER_USER@$SERVER_IP "cat /tmp/profiles_restore.sql | docker exec -i $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME" > /dev/null 2>&1
    
    RESTORED_COUNT=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c 'SELECT COUNT(*) FROM profiles;'" 2>/dev/null | grep -v "spawn" | grep -v "password" | tr -d ' \n\r' || echo "0")
    if [ "$PROFILES_COUNT" == "$RESTORED_COUNT" ]; then
        echo -e "${GREEN}✅ Профили восстановлены: $RESTORED_COUNT записей${NC}"
    else
        echo -e "${RED}❌ Ошибка при восстановлении профилей!${NC}"
    fi
fi

# Очистка временных файлов
echo -e "\n${YELLOW}11. Очистка временных файлов...${NC}"
ssh_with_password $SERVER_USER@$SERVER_IP "rm -f /tmp/data_export.sql /tmp/profiles_restore.sql" > /dev/null 2>&1
echo -e "${GREEN}✅ Временные файлы удалены${NC}"
echo -e "${YELLOW}   Резервная копия БД сохранена:${NC}"
echo -e "${YELLOW}   - Локально: $BACKUP_FILE_LOCAL${NC}"
echo -e "${YELLOW}   - На сервере: $BACKUP_FILE${NC}"
echo -e "${YELLOW}   Резервная копия профилей: $PROFILES_BACKUP${NC}"

# Предложение сохранить резервную копию
echo ""
if [ "$AUTO_CONFIRM" = true ]; then
    echo -e "${YELLOW}Сохранить резервную копию БД локально? (y/n): n (автоматическое подтверждение)${NC}"
    REPLY="n"
else
    echo -e "${YELLOW}Сохранить резервную копию БД локально? (y/n): ${NC}"
    read -n 1 -r
    echo
fi
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BACKUP_SAVE_DIR="./backups"
    mkdir -p $BACKUP_SAVE_DIR
    cp $BACKUP_FILE_LOCAL "$BACKUP_SAVE_DIR/aviapoint_backup_${BACKUP_TIMESTAMP}.sql"
    echo -e "${GREEN}✅ Резервная копия сохранена в: $BACKUP_SAVE_DIR/aviapoint_backup_${BACKUP_TIMESTAMP}.sql${NC}"
fi

rm -rf $TEMP_DIR

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Синхронизация данных завершена!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"

# Итоговая статистика
echo -e "\n${YELLOW}10. Итоговая статистика:${NC}"
for table in "${SYNC_TABLES[@]}"; do
    RESULT=$(ssh_with_password $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c \"SELECT COUNT(*) FROM $table;\"" 2>&1 | grep -v "spawn" | grep -v "password" | tr -d '\n\r')
    if echo "$RESULT" | grep -qi "ERROR\|does not exist\|doesnotexist"; then
        echo -e "${RED}   $table: ОШИБКА (таблица не существует)${NC}"
    else
        COUNT=$(echo "$RESULT" | tr -d ' ')
        if [[ -z "$COUNT" ]] || [[ "$COUNT" == "" ]]; then
            COUNT="0"
        fi
        echo -e "${GREEN}   $table: ${COUNT} записей${NC}"
    fi
done
