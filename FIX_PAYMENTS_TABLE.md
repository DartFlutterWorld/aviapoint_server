# 🔧 Исправление структуры таблицы payments

## Проблема

Ошибка: `column "subscription_type" of relation "payments" does not exist`

Это означает, что в таблице `payments` отсутствуют необходимые колонки:
- `subscription_type`
- `period_days`
- `user_id` (возможно)

## Решение

### Вариант 1: Запустить комплексную миграцию (рекомендуется)

```bash
# На сервере
cd /home/aviapoint_server
psql -h localhost -U postgres -d aviapoint -f migrations/check_and_add_payment_fields.sql
```

Эта миграция:
- Проверяет наличие каждой колонки
- Добавляет только отсутствующие колонки
- Создает индексы
- Безопасна для повторного запуска

### Вариант 2: Запустить миграции по отдельности

```bash
# На сервере
cd /home/aviapoint_server

# 1. Добавить subscription_type и period_days
psql -h localhost -U postgres -d aviapoint -f migrations/add_subscription_fields_to_payments.sql

# 2. Добавить user_id
psql -h localhost -U postgres -d aviapoint -f migrations/add_user_id_to_payments.sql
```

### Вариант 3: Через Adminer

1. Откройте Adminer: `http://83.166.246.205:8082`
2. Подключитесь к БД
3. Перейдите в "SQL-запрос"
4. Скопируйте содержимое `migrations/check_and_add_payment_fields.sql`
5. Выполните запрос

## Проверка после миграции

### Проверить структуру таблицы:

```sql
-- В Adminer или psql
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'payments'
ORDER BY ordinal_position;
```

**Должны быть колонки:**
- `id` (VARCHAR)
- `status` (VARCHAR)
- `amount` (DECIMAL)
- `currency` (VARCHAR)
- `description` (TEXT)
- `payment_url` (TEXT)
- `created_at` (TIMESTAMP)
- `paid` (BOOLEAN)
- `updated_at` (TIMESTAMP)
- `subscription_type` (VARCHAR) ← **Должна быть**
- `period_days` (INTEGER) ← **Должна быть**
- `user_id` (INTEGER) ← **Должна быть**

### Проверить индексы:

```sql
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'payments';
```

**Должны быть индексы:**
- `idx_payments_status`
- `idx_payments_created_at`
- `idx_payments_subscription_type`
- `idx_payments_period_days`
- `idx_payments_user_id`

## Тестирование после исправления

После выполнения миграции протестируйте webhook:

```bash
curl -X POST https://avia-point.com/payments/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "event": "payment.succeeded",
    "object": {
      "id": "test-payment-id-2",
      "status": "succeeded",
      "amount": {"value": "1000.00", "currency": "RUB"},
      "created_at": "2024-01-01T12:00:00.000Z",
      "paid": true,
      "metadata": {
        "user_id": 123,
        "subscription_type": "quarterly",
        "period_days": 90
      }
    }
  }'
```

**Ожидаемый ответ:** `{"status":"ok"}`

## Проверка в БД

После успешного webhook проверьте, что платеж сохранился:

```sql
SELECT id, user_id, status, paid, subscription_type, period_days 
FROM payments 
WHERE id = 'test-payment-id-2';
```

Должна быть запись с:
- `user_id = 123`
- `subscription_type = 'quarterly'`
- `period_days = 90`
- `paid = true`

## Если миграция не помогла

### Проверить текущую структуру:

```sql
\d payments
```

Или:

```sql
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'payments';
```

### Создать колонки вручную:

```sql
-- Если колонок нет, создайте их вручную
ALTER TABLE payments 
ADD COLUMN IF NOT EXISTS subscription_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS period_days INTEGER,
ADD COLUMN IF NOT EXISTS user_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL;

-- Создать индексы
CREATE INDEX IF NOT EXISTS idx_payments_subscription_type ON payments(subscription_type);
CREATE INDEX IF NOT EXISTS idx_payments_period_days ON payments(period_days);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
```

---

**Готово!** После выполнения миграции webhook должен работать корректно! 🔧

