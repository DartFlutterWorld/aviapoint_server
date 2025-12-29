# 🔄 Синхронизация таблицы profiles между локальной и продакшн БД

## Проблема

Локальная таблица `profiles` отличается от продакшн, и вы не хотите затереть данные на продакшн.

## Решение

### Вариант 1: Копировать profiles с продакшн на локальную (рекомендуется)

Это заменит локальные данные профилей данными с продакшн:

```bash
# Сделать скрипт исполняемым
chmod +x sync_profiles_from_prod.sh

# Запустить скрипт
./sync_profiles_from_prod.sh 83.166.246.205
```

**Что делает скрипт:**
1. Экспортирует таблицу `profiles` с продакшн (только данные)
2. Очищает локальную таблицу `profiles`
3. Импортирует данные с продакшн в локальную БД

---

### Вариант 2: Применить только миграции (структуру) на продакшн

Если нужно только обновить структуру таблицы `profiles` на продакшн (добавить поля `telegram` и `max`), но сохранить данные:

```bash
# Сделать скрипт исполняемым
chmod +x apply_migrations_only_to_prod.sh

# Запустить скрипт
./apply_migrations_only_to_prod.sh 83.166.246.205
```

**Что делает скрипт:**
1. Применяет только миграции структуры (без данных)
2. Пропускает миграцию 025 (`clear_all_flights_data`) - она удаляет данные
3. Регистрирует миграции в `schema_migrations`

---

## Ручной способ

### Копирование profiles с продакшн на локальную

```bash
# 1. Экспорт с продакшн
ssh root@83.166.246.205
docker exec aviapoint-postgres pg_dump -U postgres -d aviapoint \
  -t profiles \
  --data-only \
  --column-inserts > /tmp/profiles_export.sql

# 2. Копирование на локальную машину
scp root@83.166.246.205:/tmp/profiles_export.sql ./

# 3. Очистка локальной таблицы
docker exec aviapoint-postgres psql -U postgres -d aviapoint -c "TRUNCATE TABLE profiles CASCADE;"

# 4. Импорт данных
cat profiles_export.sql | docker exec -i aviapoint-postgres psql -U postgres -d aviapoint
```

### Применение только миграции 029 (добавление telegram и max)

```bash
# На сервере
ssh root@83.166.246.205
cd /home/aviapoint_server

# Применить миграцию через Adminer или psql
docker exec aviapoint-postgres psql -U postgres -d aviapoint -f migrations/add_telegram_and_max_to_profiles.sql

# Зарегистрировать миграцию
docker exec aviapoint-postgres psql -U postgres -d aviapoint -c \
  "INSERT INTO schema_migrations (version, name) VALUES ('029', 'add_telegram_and_max_to_profiles') ON CONFLICT (version) DO NOTHING;"
```

---

## Важные замечания

⚠️ **Миграция 025 (`clear_all_flights_data`)** удаляет все данные о полетах. Она пропущена в скрипте `apply_migrations_only_to_prod.sh`.

✅ **Миграция 029 (`add_telegram_and_max_to_profiles`)** только добавляет новые поля в таблицу `profiles` и не затрагивает существующие данные.

---

## Проверка после синхронизации

### Проверить количество записей

```bash
# Локально
docker exec aviapoint-postgres psql -U postgres -d aviapoint -c "SELECT COUNT(*) FROM profiles;"

# На продакшн
ssh root@83.166.246.205
docker exec aviapoint-postgres psql -U postgres -d aviapoint -c "SELECT COUNT(*) FROM profiles;"
```

### Проверить новые поля

```bash
# Проверить наличие полей telegram и max
docker exec aviapoint-postgres psql -U postgres -d aviapoint -c "\d profiles" | grep -E "telegram|max"
```

---

## Резервное копирование перед синхронизацией

Рекомендуется сделать резервную копию перед синхронизацией:

```bash
# Резервная копия локальной таблицы profiles
docker exec aviapoint-postgres pg_dump -U postgres -d aviapoint \
  -t profiles \
  --data-only \
  --column-inserts > profiles_backup_$(date +%Y%m%d_%H%M%S).sql
```

