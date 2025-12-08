#!/bin/bash

# Скрипт для тестирования создания платежа
# Использование: ./test_payment.sh [USER_ID] [AMOUNT] [SUBSCRIPTION_TYPE] [PERIOD_DAYS]

BASE_URL=${BASE_URL:-"http://localhost:8080"}
USER_ID=${1:-1}
AMOUNT=${2:-700.0}
SUBSCRIPTION_TYPE=${3:-"rosaviatest_365"}
PERIOD_DAYS=${4:-365}

echo "=========================================="
echo "Тестирование создания платежа"
echo "=========================================="
echo "URL: $BASE_URL/payments/create"
echo "User ID: $USER_ID"
echo "Amount: $AMOUNT"
echo ""

# Создаем платеж
echo "1. Создание платежа..."
RESPONSE=$(curl -s -X POST "$BASE_URL/payments/create" \
  -H "Content-Type: application/json" \
  -d "{
    \"amount\": $AMOUNT,
    \"currency\": \"RUB\",
    \"description\": \"Тестовая оплата подписки\",
    \"user_id\": $USER_ID,
    \"subscription_type\": \"$SUBSCRIPTION_TYPE\",
    \"period_days\": $PERIOD_DAYS
  }")

echo "Response:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Извлекаем payment_id и payment_url
PAYMENT_ID=$(echo "$RESPONSE" | jq -r '.id' 2>/dev/null)
PAYMENT_URL=$(echo "$RESPONSE" | jq -r '.payment_url' 2>/dev/null)

if [ "$PAYMENT_ID" != "null" ] && [ -n "$PAYMENT_ID" ]; then
  echo "✅ Платеж создан успешно!"
  echo "Payment ID: $PAYMENT_ID"
  echo "Payment URL: $PAYMENT_URL"
  echo ""
  
  # Проверяем статус платежа
  echo "2. Проверка статуса платежа..."
  STATUS_RESPONSE=$(curl -s -X GET "$BASE_URL/payments/$PAYMENT_ID/status")
  echo "Status:"
  echo "$STATUS_RESPONSE" | jq '.' 2>/dev/null || echo "$STATUS_RESPONSE"
  echo ""
  
  echo "=========================================="
  echo "Для тестирования webhook используйте:"
  echo "./test_webhook.sh $PAYMENT_ID $USER_ID $AMOUNT $SUBSCRIPTION_TYPE $PERIOD_DAYS"
  echo "=========================================="
else
  echo "❌ Ошибка при создании платежа!"
  exit 1
fi

