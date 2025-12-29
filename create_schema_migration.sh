#!/bin/bash

# Скрипт для создания миграции структуры БД (локальная -> продакшн)
# Создает SQL файл миграции, который можно применить на продакшн
# Использование: ./create_schema_migration.sh [OUTPUT_FILE]

OUTPUT_FILE=${1:-"migrations/sync_schema_from_local_$(date +%Y%m%d_%H%M%S).sql"}
LOCAL_DB_CONTAINER="aviapoint-postgres"
DB_NAME="aviapoint"
DB_USER="postgres"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Создание миграции структуры БД${NC}"
echo -e "${BLUE}  Локальная БД -> SQL файл миграции${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Проверка локальной БД
echo -e "${YELLOW}1. Проверка локальной БД...${NC}"
if ! docker ps | grep -q $LOCAL_DB_CONTAINER; then
    echo -e "${RED}❌ Локальный контейнер БД не запущен!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Локальная БД доступна${NC}"

# Создание директории migrations если её нет
MIGRATIONS_DIR="migrations"
if [ ! -d "$MIGRATIONS_DIR" ]; then
    mkdir -p "$MIGRATIONS_DIR"
    echo -e "${YELLOW}   Создана директория $MIGRATIONS_DIR${NC}"
fi

# Экспорт структуры
echo -e "\n${YELLOW}2. Экспорт структуры БД...${NC}"

# Создаем SQL файл с заголовком
cat > "$OUTPUT_FILE" << 'EOF'
-- Миграция структуры БД с локальной на продакшн
-- Создано автоматически
-- ВНИМАНИЕ: Эта миграция изменяет только структуру, НЕ переносит данные

BEGIN;

EOF

# Экспортируем структуру (только схему, без данных)
# НЕ используем --clean и --if-exists, чтобы избежать проблем с DROP TABLE
ERROR_OUTPUT=$(docker exec $LOCAL_DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME \
  --schema-only \
  --no-owner \
  --no-privileges \
  --exclude-table=schema_migrations 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при экспорте структуры БД!${NC}"
    echo -e "${RED}Детали ошибки:${NC}"
    echo "$ERROR_OUTPUT" | head -10
    rm -f "$OUTPUT_FILE"
    exit 1
fi

# Записываем результат в файл
echo "$ERROR_OUTPUT" >> "$OUTPUT_FILE"

# Добавляем COMMIT в конец файла
echo "" >> "$OUTPUT_FILE"
echo "COMMIT;" >> "$OUTPUT_FILE"

# Обработка файла: удаляем команды, которые могут вызвать проблемы
echo -e "${YELLOW}3. Обработка SQL файла...${NC}"

# Обработка файла: удаляем команды, которые могут вызвать проблемы
# Создаем временный файл
TEMP_FILE=$(mktemp)
cat "$OUTPUT_FILE" | \
  # Удаляем команды DROP для schema_migrations
  grep -v "DROP TABLE.*schema_migrations" | \
  # Удаляем команды CREATE для schema_migrations
  grep -v "CREATE TABLE.*schema_migrations" | \
  # Удаляем все команды DROP TABLE (они не нужны, так как мы только добавляем структуру)
  grep -v "^DROP TABLE" | \
  # Удаляем пустые строки подряд
  sed '/^$/N;/^\n$/d' > "$TEMP_FILE"

mv "$TEMP_FILE" "$OUTPUT_FILE"

FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
echo -e "${GREEN}✅ Миграция создана: $OUTPUT_FILE (размер: $FILE_SIZE)${NC}"

# Показываем статистику
echo -e "\n${YELLOW}4. Статистика миграции:${NC}"
TABLE_COUNT=$(grep -c "CREATE TABLE" "$OUTPUT_FILE" 2>/dev/null || echo "0")
ALTER_COUNT=$(grep -c "ALTER TABLE" "$OUTPUT_FILE" 2>/dev/null || echo "0")
INDEX_COUNT=$(grep -c "CREATE INDEX" "$OUTPUT_FILE" 2>/dev/null || echo "0")

echo -e "   Создание таблиц: ${TABLE_COUNT}"
echo -e "   Изменение таблиц: ${ALTER_COUNT}"
echo -e "   Создание индексов: ${INDEX_COUNT}"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Миграция создана!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Следующие шаги:${NC}"
echo -e "1. Проверьте файл миграции: $OUTPUT_FILE"
echo -e "2. Примените на продакшн через Adminer или psql"
echo -e "3. Или используйте скрипт: ./apply_schema_migration_to_prod.sh $OUTPUT_FILE"

