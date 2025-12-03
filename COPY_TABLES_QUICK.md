# 📥 Быстрое копирование таблиц с сервера (исправлено)

## Проблема с паролем

Если получаете ошибку `password authentication failed`, используйте один из способов ниже.

---

## Способ 1: Через Docker контейнер (рекомендуется)

Если локальная БД запущена в Docker:

```bash
# Экспорт с сервера и импорт в локальный Docker контейнер
ssh root@83.166.246.205 "docker exec aviapoint-postgres pg_dump -U postgres -d aviapoint -t payments -t subscriptions --data-only" | \
docker exec -i server-side-postgres-database psql -U postgres -d aviapoint
```

---

## Способ 2: Через файл (если пароль не работает)

### Шаг 1: Экспорт с сервера в файл

```bash
ssh root@83.166.246.205 "docker exec aviapoint-postgres pg_dump -U postgres -d aviapoint -t payments -t subscriptions --data-only" > payments_subscriptions.sql
```

### Шаг 2: Импорт через Docker

```bash
# Если БД в Docker
docker exec -i server-side-postgres-database psql -U postgres -d aviapoint < payments_subscriptions.sql
```

### Шаг 3: Или через psql с паролем

```bash
# Указать пароль через переменную окружения
PGPASSWORD=password psql -h localhost -U postgres -d aviapoint < payments_subscriptions.sql
```

---

## Способ 3: Использовать скрипт (автоматически определит Docker)

```bash
./download_tables_from_server.sh
```

Скрипт автоматически определит, используется ли Docker контейнер.

---

## Способ 4: Через Adminer (без пароля)

### Экспорт с сервера:

1. Откройте Adminer на сервере: `http://83.166.246.205:8082`
2. Подключитесь к БД
3. Перейдите в "Экспорт"
4. Выберите:
   - **Формат:** SQL
   - **Таблицы:** `payments`, `subscriptions`
   - **Данные:** ✅ Да
5. Нажмите "Экспорт"
6. Сохраните файл `payments_subscriptions.sql`

### Импорт в локальную БД:

1. Откройте Adminer локально: `http://localhost:8082`
2. Подключитесь к БД
3. Перейдите в "Импорт"
4. Выберите файл `payments_subscriptions.sql`
5. Нажмите "Выполнить"

---

## Проверка подключения к локальной БД

### Если БД в Docker:

```bash
# Проверить, запущен ли контейнер
docker ps | grep postgres

# Подключиться к БД
docker exec -it server-side-postgres-database psql -U postgres -d aviapoint
```

### Если БД не в Docker:

```bash
# Проверить подключение
PGPASSWORD=password psql -h localhost -U postgres -d aviapoint -c "SELECT 1;"
```

---

## Очистка таблиц перед импортом (опционально)

Если нужно заменить данные:

### Через Docker:

```bash
docker exec -i server-side-postgres-database psql -U postgres -d aviapoint << SQL
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE subscriptions CASCADE;
SQL
```

### Через psql:

```bash
PGPASSWORD=password psql -h localhost -U postgres -d aviapoint << SQL
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE subscriptions CASCADE;
SQL
```

---

## Полная команда с очисткой

```bash
# 1. Очистить локальные таблицы
docker exec -i server-side-postgres-database psql -U postgres -d aviapoint << SQL
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE subscriptions CASCADE;
SQL

# 2. Скопировать с сервера
ssh root@83.166.246.205 "docker exec aviapoint-postgres pg_dump -U postgres -d aviapoint -t payments -t subscriptions --data-only" | \
docker exec -i server-side-postgres-database psql -U postgres -d aviapoint
```

---

**Готово!** Теперь должно работать! ✅

