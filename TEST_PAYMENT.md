# 🧪 Тестирование создания платежа

## Способ 1: Использование готовых скриптов

### Тест создания платежа:
```bash
# Локально
./test_payment.sh 1 700.0

# На продакшене
BASE_URL=https://avia-point.com ./test_payment.sh 1 700.0
```

### Тест webhook (симуляция успешной оплаты):
```bash
# Локально
./test_webhook.sh test-payment-123 1 700.00

# На продакшене
BASE_URL=https://avia-point.com ./test_webhook.sh test-payment-123 1 700.00
```

---

## Способ 2: Через curl

### 1. Создание платежа

```bash
curl -X POST http://localhost:8080/payments/create \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 700.0,
    "currency": "RUB",
    "description": "Оплата подписки на тренировочный режим AviaPoint",
    "user_id": 1,
    "subscription_type": "monthly",
    "period_days": 30
  }'
```

**Ответ:**
```json
{
  "id": "2c5c5e5e-5e5e-5e5e-5e5e-5e5e5e5e5e5e",
  "status": "pending",
  "amount": 700.0,
  "currency": "RUB",
  "description": "Оплата подписки на тренировочный режим AviaPoint",
  "payment_url": "https://yoomoney.ru/checkout/payments/v2/contract?orderId=...",
  "created_at": "2025-12-08T12:00:00.000Z",
  "paid": false
}
```

### 2. Проверка статуса платежа

```bash
curl http://localhost:8080/payments/{PAYMENT_ID}/status
```

### 3. Симуляция webhook (успешная оплата)

```bash
curl -X POST http://localhost:8080/payments/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "type": "notification",
    "event": "payment.succeeded",
    "object": {
      "id": "2c5c5e5e-5e5e-5e5e-5e5e-5e5e5e5e5e5e",
      "status": "succeeded",
      "paid": true,
      "amount": {
        "value": "700.00",
        "currency": "RUB"
      },
      "description": "Оплата подписки на тренировочный режим AviaPoint",
      "created_at": "2025-12-08T12:00:00.000Z",
      "confirmation": {
        "type": "redirect",
        "confirmation_url": "https://yoomoney.ru/checkout/payments/v2/contract?orderId=..."
      },
      "metadata": {
        "user_id": 1,
        "subscription_type": "monthly",
        "period_days": 30
      }
    }
  }'
```

### 4. Проверка подписки (требуется авторизация)

```bash
curl -X GET http://localhost:8080/subscriptions/active \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Способ 3: Через Postman/Insomnia

### Создание платежа

**Request:**
- Method: `POST`
- URL: `http://localhost:8080/payments/create`
- Headers:
  - `Content-Type: application/json`
- Body (JSON):
```json
{
  "amount": 700.0,
  "currency": "RUB",
  "description": "Оплата подписки на тренировочный режим AviaPoint",
  "user_id": 1,
  "subscription_type": "monthly",
  "period_days": 30
}
```

### Симуляция webhook

**Request:**
- Method: `POST`
- URL: `http://localhost:8080/payments/webhook`
- Headers:
  - `Content-Type: application/json`
- Body (JSON): см. пример выше в curl

---

## Способ 4: Тестирование через ЮKassa Sandbox

1. **Создайте платеж** через API (см. выше)
2. **Скопируйте `payment_url`** из ответа
3. **Откройте URL** в браузере
4. **Используйте тестовые карты** ЮKassa:
   - Успешная оплата: `5555 5555 5555 4444`
   - Отклоненная оплата: `5555 5555 5555 4477`
   - CVV: `123`
   - Срок действия: любая будущая дата

5. **После оплаты** ЮKassa автоматически отправит webhook на ваш сервер

---

## Проверка результатов

### 1. Проверка платежа в БД (через Adminer)

```sql
SELECT * FROM payments 
WHERE id = 'PAYMENT_ID' 
ORDER BY created_at DESC 
LIMIT 1;
```

**Ожидаемые поля:**
- `id` - ID платежа
- `status` - `succeeded`
- `paid` - `true`
- `user_id` - ID пользователя
- `subscription_type` - `monthly`
- `period_days` - `30`

### 2. Проверка подписки в БД

```sql
SELECT * FROM subscriptions 
WHERE payment_id = 'PAYMENT_ID';
```

**Ожидаемые поля:**
- `user_id` - ID пользователя
- `payment_id` - ID платежа
- `subscription_type_id` - ID типа подписки
- `period_days` - `30`
- `is_active` - `true`
- `start_date` - дата создания
- `end_date` - start_date + 30 дней

### 3. Проверка через API

```bash
# Проверка активных подписок
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8080/subscriptions/active
```

---

## Отладка

### Просмотр логов сервера

```bash
# Локально
# Логи выводятся в консоль

# На продакшене
docker-compose -f docker-compose.prod.yaml logs --tail=100 app | grep -i payment
```

### Что проверять в логах:

1. **При создании платежа:**
   - `Creating payment in YooKassa: amount=...`
   - `Payment created successfully: ...`

2. **При получении webhook:**
   - `Received webhook from YooKassa: payment.succeeded`
   - `Payment status updated successfully: ...`
   - `Subscription activated for user ...`

3. **Ошибки:**
   - `Failed to update payment status: ...`
   - `Failed to activate subscription: ...`

---

## Типичные проблемы

### 1. Платеж создается, но webhook не приходит

**Решение:**
- Проверьте, что URL webhook доступен из интернета (не localhost)
- Для локального тестирования используйте ngrok или тестовый webhook скрипт

### 2. Webhook приходит, но платеж не сохраняется

**Решение:**
- Проверьте логи на ошибки INSERT
- Убедитесь, что все поля в таблице `payments` существуют
- Проверьте, что `user_id` существует в таблице `profiles`

### 3. Подписка не создается

**Решение:**
- Проверьте, что `subscription_type` и `period_days` передаются в metadata
- Проверьте логи на ошибки в `createSubscription`
- Убедитесь, что таблица `subscription_types` содержит нужные типы

---

## Пример полного теста

```bash
# 1. Создаем платеж
PAYMENT_RESPONSE=$(curl -s -X POST http://localhost:8080/payments/create \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 700.0,
    "currency": "RUB",
    "description": "Тестовая оплата",
    "user_id": 1,
    "subscription_type": "monthly",
    "period_days": 30
  }')

PAYMENT_ID=$(echo $PAYMENT_RESPONSE | jq -r '.id')
echo "Payment ID: $PAYMENT_ID"

# 2. Симулируем успешную оплату через webhook
curl -X POST http://localhost:8080/payments/webhook \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"notification\",
    \"event\": \"payment.succeeded\",
    \"object\": {
      \"id\": \"$PAYMENT_ID\",
      \"status\": \"succeeded\",
      \"paid\": true,
      \"amount\": {
        \"value\": \"700.00\",
        \"currency\": \"RUB\"
      },
      \"description\": \"Тестовая оплата\",
      \"created_at\": \"$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")\",
      \"metadata\": {
        \"user_id\": 1,
        \"subscription_type\": \"monthly\",
        \"period_days\": 30
      }
    }
  }"

# 3. Проверяем статус платежа
curl http://localhost:8080/payments/$PAYMENT_ID/status
```

---

**Готово!** Теперь вы можете протестировать создание платежа различными способами.

