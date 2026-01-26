# Применение миграции 066 для анонимных FCM токенов

## Важно!

Миграция 066 должна быть применена **ДО** использования эндпоинта `/api/fcm-token`.

## Проверка текущего состояния

Проверьте, существует ли таблица `fcm_tokens`:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('fcm_tokens', 'user_fcm_tokens');
```

Если видите только `user_fcm_tokens` - миграция не применена.

## Применение миграции

### Локально:
```bash
cd /Users/admin/Projects/aviapoint_server
psql -U postgres -d aviapoint -f migrations/066_add_anonymous_fcm_tokens_support.sql
```

### На сервере:
```bash
# Подключитесь к серверу и выполните:
psql -U postgres -d aviapoint -f migrations/066_add_anonymous_fcm_tokens_support.sql
```

Или через Docker:
```bash
docker exec -i aviapoint_postgres psql -U postgres -d aviapoint < migrations/066_add_anonymous_fcm_tokens_support.sql
```

## Проверка после применения

```sql
-- Проверяем, что таблица переименована
SELECT table_name FROM information_schema.tables WHERE table_name = 'fcm_tokens';

-- Проверяем, что user_id может быть NULL
SELECT column_name, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'fcm_tokens' AND column_name = 'user_id';
-- is_nullable должно быть 'YES'

-- Проверяем уникальный индекс на fcm_token
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'fcm_tokens' 
  AND indexdef LIKE '%UNIQUE%fcm_token%';
```

## Если миграция уже применена через MigrationManager

Миграция должна примениться автоматически при следующем запуске сервера, если она добавлена в `migration_manager.dart`.
