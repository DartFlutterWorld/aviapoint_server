# Реализация анонимных FCM токенов на бэкенде

## Описание

Добавлена поддержка сбора FCM токенов от неавторизованных пользователей для массовых рассылок.

## Изменения в базе данных

### Миграция 066: `066_add_anonymous_fcm_tokens_support.sql`

1. **Переименование таблицы:** `user_fcm_tokens` → `fcm_tokens`
2. **Изменение структуры:** `user_id` теперь nullable (NULL для анонимных токенов)
3. **Уникальность:** Токен (`fcm_token`) теперь уникален глобально (не только в рамках пользователя)
4. **Индексы:** Добавлены индексы для быстрого поиска анонимных токенов

### Структура таблицы `fcm_tokens`:

```sql
CREATE TABLE fcm_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES profiles(id) ON DELETE CASCADE, -- NULL для анонимных
    fcm_token VARCHAR(512) NOT NULL UNIQUE,
    platform VARCHAR(20) NOT NULL DEFAULT 'mobile',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## API Endpoints

### 1. Сохранение токена авторизованного пользователя
**POST** `/api/profile/fcm-token`
- Требует авторизации (JWT токен)
- Автоматически привязывает токен к `user_id` из токена

**Request Headers:**
```
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "fcm_token": "dKj3h...",
  "platform": "ios"
}
```

**Response:**
```json
{
  "success": true
}
```

### 2. Сохранение анонимного токена
**POST** `/api/fcm-token`
- Не требует авторизации
- Сохраняет токен с `user_id = NULL`

**Request Body:**
```json
{
  "fcm_token": "dKj3h...",
  "platform": "android"
}
```

**Response:**
```json
{
  "success": true
}
```

## Изменения в коде

### 1. ProfileRepository

Добавлен метод `saveAnonymousFcmToken()`:
```dart
Future<void> saveAnonymousFcmToken({
  required String? fcmToken, 
  String? platform
}) async
```

Обновлен метод `updateFcmToken()` для работы с новой таблицей `fcm_tokens`.

### 2. ProfileController

Добавлен эндпоинт `saveAnonymousFcmToken()`:
```dart
@Route.post('/api/fcm-token')
Future<Response> saveAnonymousFcmToken(Request request)
```

### 3. Обновлены все упоминания таблицы

- `lib/on_the_way/repositories/on_the_way_repository.dart`
- `lib/market/repositories/market_repository.dart`
- `lib/profiles/data/repositories/profile_repository.dart`

Все запросы к `user_fcm_tokens` обновлены на `fcm_tokens`.

## Применение миграции

### Локально:
```bash
cd /Users/admin/Projects/aviapoint_server
psql -d aviapoint -f migrations/066_add_anonymous_fcm_tokens_support.sql
```

### На сервере:
Миграция будет применена автоматически при следующем запуске сервера через `MigrationManager`.

Или вручную:
```bash
psql -U postgres -d aviapoint -f migrations/066_add_anonymous_fcm_tokens_support.sql
```

## Генерация кода

После изменений нужно запустить build_runner:

```bash
cd /Users/admin/Projects/aviapoint_server
dart run build_runner build --delete-conflicting-outputs
```

Это обновит:
- `lib/profiles/controller/profile_cantroller.g.dart`

## Использование на бэкенде

### Массовая рассылка всем пользователям:
```sql
SELECT fcm_token FROM fcm_tokens;
```

### Персонализированная рассылка:
```sql
SELECT fcm_token FROM fcm_tokens WHERE user_id = 123;
```

### Рассылка только анонимным пользователям:
```sql
SELECT fcm_token FROM fcm_tokens WHERE user_id IS NULL;
```

### Рассылка по платформе:
```sql
SELECT fcm_token FROM fcm_tokens WHERE platform = 'ios';
```

### Привязка анонимного токена к пользователю при авторизации:

При авторизации пользователя анонимный токен автоматически обновляется с `user_id` через эндпоинт `/api/profile/fcm-token`, так как используется `ON CONFLICT (fcm_token)` с обновлением `user_id`.

## Важные моменты

1. **Уникальность токена:** `fcm_token` теперь уникален глобально (один токен = одна запись)
2. **Обновление токена:** При обновлении FCM токена старый токен обновляется (не создается дубликат)
3. **Привязка при авторизации:** При авторизации анонимный токен автоматически привязывается к `user_id`
4. **Обратная совместимость:** Старое поле `profiles.fcm_token` все еще обновляется для совместимости

## Тестирование

1. **Анонимный токен:**
   ```bash
   curl -X POST http://localhost:8080/api/fcm-token \
     -H "Content-Type: application/json" \
     -d '{"fcm_token": "test_token_123", "platform": "ios"}'
   ```

2. **Токен авторизованного пользователя:**
   ```bash
   curl -X POST http://localhost:8080/api/profile/fcm-token \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{"fcm_token": "test_token_456", "platform": "android"}'
   ```

3. **Проверка в БД:**
   ```sql
   SELECT * FROM fcm_tokens WHERE fcm_token = 'test_token_123';
   -- user_id должен быть NULL
   
   SELECT * FROM fcm_tokens WHERE fcm_token = 'test_token_456';
   -- user_id должен быть установлен
   ```
