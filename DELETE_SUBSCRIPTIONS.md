# 🗑️ Удаление записей из таблицы subscriptions

## Проблема

Ошибка: `null value in column "payment_id" of relation "subscriptions" violates not-null constraint`

Это происходит, когда поле `payment_id` имеет ограничение `NOT NULL`, но система пытается установить его в `NULL` при удалении связанных записей.

## Решение 1: Сделать payment_id nullable (рекомендуется)

### Запустить миграцию:

```bash
# На сервере
psql -h localhost -U postgres -d aviapoint -f migrations/make_payment_id_nullable_in_subscriptions.sql
```

Или через Adminer:
1. Откройте Adminer
2. Перейдите в "SQL-запрос"
3. Выполните:
   ```sql
   ALTER TABLE subscriptions
   ALTER COLUMN payment_id DROP NOT NULL;
   ```

### После этого можно удалять записи:

```sql
-- Удалить конкретную подписку
DELETE FROM subscriptions WHERE id = 3;

-- Удалить все подписки пользователя
DELETE FROM subscriptions WHERE user_id = 1;

-- Удалить все подписки с определенным payment_id
DELETE FROM subscriptions WHERE payment_id = 'test-payment-id-3';
```

---

## Решение 2: Удаление через SQL напрямую

Если не хотите менять структуру таблицы, удаляйте записи напрямую:

```sql
-- Удалить конкретную подписку по ID
DELETE FROM subscriptions WHERE id = 3;

-- Удалить все подписки пользователя
DELETE FROM subscriptions WHERE user_id = 1;

-- Удалить подписки с определенным payment_id
DELETE FROM subscriptions WHERE payment_id = 'test-payment-id-3';
```

---

## Решение 3: Удаление через Adminer

1. Откройте Adminer: `http://localhost:8082` (или на сервере)
2. Выберите базу `aviapoint`
3. Перейдите в таблицу `subscriptions`
4. Отметьте нужные записи (чекбоксы)
5. Нажмите "Стереть" (Delete)
6. Подтвердите удаление

---

## Проверка структуры таблицы

Проверьте текущие ограничения:

```sql
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'subscriptions' 
  AND column_name = 'payment_id';
```

**Должно быть:**
- `is_nullable = 'YES'` (после миграции)

---

## Удаление нескольких записей

### Удалить по списку ID:

```sql
DELETE FROM subscriptions 
WHERE id IN (3, 4, 5);
```

### Удалить все тестовые подписки:

```sql
DELETE FROM subscriptions 
WHERE payment_id LIKE 'test-%';
```

### Удалить все подписки старше определенной даты:

```sql
DELETE FROM subscriptions 
WHERE end_date < '2025-01-01';
```

---

## Важно!

⚠️ **Перед удалением сделайте бэкап:**

```bash
# Экспорт таблицы subscriptions
pg_dump -h localhost -U postgres -d aviapoint -t subscriptions --data-only > subscriptions_backup.sql
```

---

## После удаления

Проверьте, что записи удалены:

```sql
SELECT COUNT(*) FROM subscriptions;
SELECT * FROM subscriptions ORDER BY id;
```

---

**Готово!** Теперь вы можете удалять записи без ошибок! 🗑️

