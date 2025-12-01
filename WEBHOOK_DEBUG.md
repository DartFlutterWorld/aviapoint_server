# 🔍 Отладка проблемы с webhook

## Проблема

Платеж успешно прошел, но записи нет в БД (ни в `payments`, ни в `subscriptions`).

## Причины и решения

### 1. Webhook не приходит на сервер

**Проверка:**
```bash
# На сервере - проверьте логи
docker-compose -f docker-compose.prod.yaml logs --tail=100 app | grep -i webhook
```

**Должны быть записи:**
```
Received webhook from YooKassa: payment.succeeded
Updating payment status: ...
```

**Если записей нет:**
- Webhook не настроен в личном кабинете ЮKassa
- URL webhook недоступен из интернета
- Nginx не проксирует запросы на `/payments/webhook`

**Решение:**
1. Проверьте настройки в личном кабинете ЮKassa:
   - URL: `https://avia-point.com/payments/webhook`
   - События: `payment.succeeded`, `payment.canceled`
2. Проверьте доступность endpoint:
   ```bash
   curl -X POST https://avia-point.com/payments/webhook \
     -H "Content-Type: application/json" \
     -d '{"test": "data"}'
   ```
3. Проверьте nginx.conf - должен проксировать `/payments/webhook`

---

### 2. Webhook приходит, но есть ошибка при сохранении

**Проверка:**
```bash
# На сервере - проверьте логи на ошибки
docker-compose -f docker-compose.prod.yaml logs --tail=100 app | grep -i error
```

**Типичные ошибки:**
- `Failed to update payment status` - ошибка при сохранении в БД
- `Payment has no user_id` - не передан user_id
- `Payment not found in database` - платеж не найден (но это нормально для первого сохранения)

**Решение:**
- Проверьте структуру таблицы `payments` - должно быть поле `user_id`
- Запустите миграцию: `migrations/add_user_id_to_payments.sql`
- Проверьте, что `user_id` передается при создании платежа

---

### 3. Платеж сохраняется, но подписка не создается

**Проверка:**
```bash
# Проверьте, есть ли платеж в БД
# В Adminer выполните:
SELECT * FROM payments WHERE paid = true ORDER BY created_at DESC LIMIT 5;
```

**Если платеж есть, но подписки нет:**
- Проверьте логи на ошибки создания подписки:
  ```bash
  docker-compose -f docker-compose.prod.yaml logs --tail=100 app | grep -i subscription
  ```
- Проверьте, что у платежа есть `user_id`:
  ```sql
  SELECT id, user_id, subscription_type, period_days FROM payments WHERE paid = true;
  ```

---

## Пошаговая диагностика

### Шаг 1: Проверьте логи webhook

```bash
# На сервере
docker-compose -f docker-compose.prod.yaml logs --tail=200 app | grep -A 5 -B 5 webhook
```

Ищите:
- `Received webhook from YooKassa: payment.succeeded`
- `Updating payment status: ...`
- `Payment saved to database from webhook: ...`
- `Subscription activated for user ...`

### Шаг 2: Проверьте структуру БД

```sql
-- В Adminer проверьте структуру таблицы payments
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'payments';
```

Должны быть поля:
- `id`
- `status`
- `amount`
- `currency`
- `description`
- `payment_url`
- `created_at`
- `paid`
- `subscription_type`
- `period_days`
- `user_id` ← **ВАЖНО!**

### Шаг 3: Запустите миграцию

```bash
# На сервере
psql -h localhost -U postgres -d aviapoint -f migrations/add_user_id_to_payments.sql
```

### Шаг 4: Проверьте настройки webhook в ЮKassa

1. Зайдите в личный кабинет: https://yookassa.ru/my
2. Перейдите в **"Настройки"** → **"Уведомления"**
3. Проверьте URL: `https://avia-point.com/payments/webhook`
4. Проверьте, что выбраны события:
   - ✅ `payment.succeeded`
   - ✅ `payment.canceled`
   - ✅ `payment.waiting_for_capture`

### Шаг 5: Проверьте доступность endpoint

```bash
# С вашего компьютера
curl -X POST https://avia-point.com/payments/webhook \
  -H "Content-Type: application/json" \
  -d '{"event": "test", "object": {"id": "test"}}'
```

Должен вернуть: `{"status": "ok"}`

---

## Исправления в коде

### 1. Добавлено поле `user_id` в metadata

Теперь `user_id` передается в metadata при создании платежа и извлекается в webhook.

### 2. Добавлено сохранение `user_id` в БД

При сохранении платежа из webhook теперь сохраняется `user_id`.

### 3. Создана миграция

`migrations/add_user_id_to_payments.sql` - добавляет поле `user_id` в таблицу `payments`.

---

## Что нужно сделать

1. **Запустить миграцию:**
   ```bash
   psql -h localhost -U postgres -d aviapoint -f migrations/add_user_id_to_payments.sql
   ```

2. **Пересобрать и перезапустить сервер:**
   ```bash
   cd /home/aviapoint_server
   docker-compose -f docker-compose.prod.yaml build app
   docker-compose -f docker-compose.prod.yaml up -d app
   ```

3. **Проверить логи:**
   ```bash
   docker-compose -f docker-compose.prod.yaml logs -f app
   ```

4. **Создать тестовый платеж** и проверить, что webhook обрабатывается

---

## Проверка после исправления

После применения исправлений проверьте:

1. **Платеж сохраняется в БД:**
   ```sql
   SELECT * FROM payments WHERE paid = true ORDER BY created_at DESC LIMIT 1;
   ```
   - Должен быть `user_id`
   - Должны быть `subscription_type` и `period_days`

2. **Подписка создается:**
   ```sql
   SELECT * FROM subscriptions ORDER BY created_at DESC LIMIT 1;
   ```
   - Должна быть запись с правильным `user_id` и `payment_id`

---

**Готово!** Теперь webhook должен работать правильно! 🔧

