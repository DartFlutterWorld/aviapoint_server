#!/bin/bash

# Скрипт для тестирования webhook от ЮKassa
# Использование: ./test_webhook.sh [PAYMENT_ID] [USER_ID] [AMOUNT] [SUBSCRIPTION_TYPE] [PERIOD_DAYS]

BASE_URL=${BASE_URL:-"http://localhost:8080"}
PAYMENT_ID=${1:-"test-payment-$(date +%s)"}
USER_ID=${2:-1}
AMOUNT=${3:-700.00}
SUBSCRIPTION_TYPE=${4:-"rosaviatest_365"}
PERIOD_DAYS=${5:-365}

echo "=========================================="
echo "Тестирование webhook от ЮKassa"
echo "=========================================="
echo "URL: $BASE_URL/payments/webhook"
echo "Payment ID: $PAYMENT_ID"
echo "User ID: $USER_ID"
echo ""

# Создаем тестовый webhook payload
WEBHOOK_PAYLOAD=$(cat <<EOF
{
  "type": "notification",
  "event": "payment.succeeded",
  "object": {
    "id": "$PAYMENT_ID",
    "status": "succeeded",
    "paid": true,
    "amount": {
      "value": "$AMOUNT",
      "currency": "RUB"
    },
    "description": "Тестовая оплата подписки",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")",
    "confirmation": {
      "type": "redirect",
      "confirmation_url": "https://yoomoney.ru/checkout/payments/v2/contract?orderId=$PAYMENT_ID"
    },
    "metadata": {
      "user_id": $USER_ID,
      "subscription_type": "$SUBSCRIPTION_TYPE",
      "period_days": $PERIOD_DAYS
    }
  }
}
EOF
)

echo "Отправка webhook..."
RESPONSE=$(curl -s -X POST "$BASE_URL/payments/webhook" \
  -H "Content-Type: application/json" \
  -d "$WEBHOOK_PAYLOAD")

echo "Response:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Проверяем, что платеж сохранился в БД
echo "Проверка платежа в БД..."
STATUS_RESPONSE=$(curl -s -X GET "$BASE_URL/payments/$PAYMENT_ID/status")
echo "Payment status:"
echo "$STATUS_RESPONSE" | jq '.' 2>/dev/null || echo "$STATUS_RESPONSE"
echo ""

# Проверяем подписку (нужен токен авторизации)
echo "=========================================="
echo "Для проверки подписки используйте:"
echo "curl -H \"Authorization: Bearer YOUR_TOKEN\" $BASE_URL/subscriptions/active"
echo "=========================================="

