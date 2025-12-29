#!/bin/bash

# Скрипт для исправления синтаксических ошибок в SQL миграции
# Использование: ./fix_schema_migration.sh [MIGRATION_FILE]

MIGRATION_FILE=${1:-""}

if [ -z "$MIGRATION_FILE" ] || [ ! -f "$MIGRATION_FILE" ]; then
    echo "❌ Укажите файл миграции!"
    echo "Использование: ./fix_schema_migration.sh <migration_file.sql>"
    exit 1
fi

echo "Исправление синтаксических ошибок в $MIGRATION_FILE..."

# Создаем резервную копию
cp "$MIGRATION_FILE" "${MIGRATION_FILE}.backup"

# Создаем временный файл
TEMP_FILE=$(mktemp)

# Исправляем файл
cat "$MIGRATION_FILE" | \
  # Удаляем все команды DROP TABLE (они вызывают ошибки и не нужны)
  grep -v "^DROP TABLE" | \
  # Удаляем команды DROP для schema_migrations
  grep -v "DROP TABLE.*schema_migrations" | \
  # Удаляем пустые строки подряд
  sed '/^$/N;/^\n$/d' > "$TEMP_FILE"

mv "$TEMP_FILE" "$MIGRATION_FILE"

echo "✅ Файл исправлен: $MIGRATION_FILE"
echo "Резервная копия: ${MIGRATION_FILE}.backup"
echo ""
echo "⚠️  Все команды DROP TABLE удалены (они не нужны для добавления структуры)"

