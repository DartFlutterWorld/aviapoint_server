#!/bin/bash

# Скрипт для создания платежа через API
# Использование: ./create_payment.sh [USER_ID] [AMOUNT] [SUBSCRIPTION_TYPE] [PERIOD_DAYS]

BASE_URL=${BASE_URL:-"http://localhost:8080"}
USER_ID=${1:-1}
AMOUNT=${2:-1000.0}
SUBSCRIPTION_TYPE=${3:-"rosaviatest_365"}
PERIOD_DAYS=${4:-365}

echo "=========================================="
echo "Создание платежа"
echo "=========================================="
echo "URL: $BASE_URL/payments/create"
echo "User ID: $USER_ID"
echo "Amount: $AMOUNT ₽"
echo "Subscription Type: $SUBSCRIPTION_TYPE"
echo "Period Days: $PERIOD_DAYS"
echo ""

# Создаем платеж
RESPONSE=$(curl -s -X POST "$BASE_URL/payments/create" \
  -H "Content-Type: application/json" \
  -d "{
    \"amount\": $AMOUNT,
    \"currency\": \"RUB\",
    \"description\": \"Оплата подписки $SUBSCRIPTION_TYPE на $PERIOD_DAYS дней\",
    \"user_id\": $USER_ID,
    \"subscription_type\": \"$SUBSCRIPTION_TYPE\",
    \"period_days\": $PERIOD_DAYS
  }")

echo "Ответ сервера:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Извлекаем payment_id и payment_url
PAYMENT_ID=$(echo "$RESPONSE" | jq -r '.id' 2>/dev/null)
PAYMENT_URL=$(echo "$RESPONSE" | jq -r '.payment_url' 2>/dev/null)

if [ "$PAYMENT_ID" != "null" ] && [ -n "$PAYMENT_ID" ]; then
  echo "✅ Платеж создан успешно!"
  echo ""
  echo "Payment ID: $PAYMENT_ID"
  echo "Payment URL: $PAYMENT_URL"
  echo ""
  echo "=========================================="
  echo "Следующие шаги:"
  echo "=========================================="
  echo ""
  echo "1. Откройте Payment URL в браузере для оплаты:"
  echo "   $PAYMENT_URL"
  echo ""
  echo "2. Или симулируйте успешную оплату через webhook:"
  echo "   ./test_webhook.sh $PAYMENT_ID $USER_ID $AMOUNT $SUBSCRIPTION_TYPE $PERIOD_DAYS"
  echo ""
  echo "3. Проверьте статус платежа:"
  echo "   curl $BASE_URL/payments/$PAYMENT_ID/status"
  echo ""
else
  echo "❌ Ошибка при создании платежа!"
  exit 1
fi

