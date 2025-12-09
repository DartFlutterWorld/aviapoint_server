#!/bin/bash

# Скрипт для создания платежа на продакшене
# Использование: ./create_payment_prod.sh [USER_ID] [AMOUNT] [SUBSCRIPTION_TYPE] [PERIOD_DAYS]

BASE_URL="https://avia-point.com"
USER_ID=${1:-1}
AMOUNT=${2:-1000.0}
SUBSCRIPTION_TYPE=${3:-"rosaviatest_365"}
PERIOD_DAYS=${4:-365}

echo "=========================================="
echo "Создание платежа на ПРОДАКШЕНЕ"
echo "=========================================="
echo "URL: $BASE_URL/payments/create"
echo "User ID: $USER_ID"
echo "Amount: $AMOUNT ₽"
echo "Subscription Type: $SUBSCRIPTION_TYPE"
echo "Period Days: $PERIOD_DAYS"
echo ""

# Создаем платеж
echo "Отправка запроса на создание платежа..."
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

echo ""
echo "Ответ сервера:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Извлекаем payment_id и payment_url
PAYMENT_ID=$(echo "$RESPONSE" | jq -r '.id' 2>/dev/null)
PAYMENT_URL=$(echo "$RESPONSE" | jq -r '.payment_url' 2>/dev/null)
STATUS=$(echo "$RESPONSE" | jq -r '.status' 2>/dev/null)

if [ "$PAYMENT_ID" != "null" ] && [ -n "$PAYMENT_ID" ]; then
  echo "✅ Платеж создан успешно!"
  echo ""
  echo "📋 Детали платежа:"
  echo "   Payment ID: $PAYMENT_ID"
  echo "   Status: $STATUS"
  echo "   Payment URL: $PAYMENT_URL"
  echo ""
  echo "=========================================="
  echo "Следующие шаги:"
  echo "=========================================="
  echo ""
  echo "1. Откройте Payment URL в браузере для оплаты:"
  echo "   $PAYMENT_URL"
  echo ""
  echo "2. После успешной оплаты ЮKassa автоматически отправит webhook"
  echo "   и подписка будет активирована"
  echo ""
  echo "3. Проверьте статус платежа:"
  echo "   curl $BASE_URL/payments/$PAYMENT_ID/status"
  echo ""
  echo "4. Проверьте подписку (нужен токен авторизации):"
  echo "   curl -H \"Authorization: Bearer YOUR_TOKEN\" $BASE_URL/subscriptions/active"
  echo ""
else
  echo "❌ Ошибка при создании платежа!"
  echo ""
  echo "Проверьте:"
  echo "- Доступность сервера: curl $BASE_URL/openapi"
  echo "- Логи сервера на продакшене"
  echo "- Правильность параметров (USER_ID должен существовать в БД)"
  exit 1
fi

