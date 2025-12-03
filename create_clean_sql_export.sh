#!/bin/bash

# Создание чистого SQL файла для импорта через Adminer
# Убирает все psql-специфичные команды

LOCAL_DB_CONTAINER="server-side-postgres-database"
OUTPUT_FILE="payments_subscriptions_clean.sql"

echo "Создание чистого SQL файла для импорта через Adminer..."

docker exec $LOCAL_DB_CONTAINER pg_dump -U postgres -d aviapoint \
  -t payments \
  -t subscriptions \
  --data-only \
  --inserts \
  --no-owner \
  --no-privileges \
  2>/dev/null | \
  grep -v "^\\\\" | \
  grep -v "^--" | \
  grep -v "^SET" | \
  grep -v "^SELECT pg_catalog" | \
  grep -v "^$" > $OUTPUT_FILE

# Если файл пустой или содержит только пробелы, значит таблицы пустые
if [ ! -s "$OUTPUT_FILE" ] || [ -z "$(cat $OUTPUT_FILE | tr -d '[:space:]')" ]; then
    echo "Предупреждение: Таблицы пустые или файл не содержит данных"
    echo "Создаю пустой файл с комментарием..."
    echo "-- Таблицы payments и subscriptions пустые" > $OUTPUT_FILE
else
    echo "SQL файл создан: $OUTPUT_FILE"
    echo "Размер: $(du -h $OUTPUT_FILE | cut -f1)"
    echo ""
    echo "Первые строки файла:"
    head -10 $OUTPUT_FILE
fi

