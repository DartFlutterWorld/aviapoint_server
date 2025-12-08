#!/bin/bash

# Скрипт для диагностики проблемы с созданием подписки
# Использование: ./check_subscription_issue.sh [PAYMENT_ID]

PAYMENT_ID=${1:-""}

echo "=========================================="
echo "Диагностика проблемы с подпиской"
echo "=========================================="
echo ""

if [ -z "$PAYMENT_ID" ]; then
  echo "Использование: ./check_subscription_issue.sh PAYMENT_ID"
  echo ""
  echo "Пример: ./check_subscription_issue.sh test-payment-123"
  exit 1
fi

echo "1. Проверка платежа в БД..."
echo "SELECT * FROM payments WHERE id = '$PAYMENT_ID';"
echo ""

echo "2. Проверка типов подписок в БД..."
echo "SELECT id, code, name, is_active FROM subscription_types WHERE is_active = true;"
echo ""

echo "3. Проверка пользователя из платежа..."
echo "SELECT p.user_id, pr.id, pr.phone FROM payments p LEFT JOIN profiles pr ON p.user_id = pr.id WHERE p.id = '$PAYMENT_ID';"
echo ""

echo "4. Проверка существующих подписок для этого платежа..."
echo "SELECT * FROM subscriptions WHERE payment_id = '$PAYMENT_ID';"
echo ""

echo "5. Проверка foreign key constraints..."
echo "-- Проверка subscription_type_id"
echo "SELECT st.id FROM subscription_types st WHERE st.code = 'monthly';"
echo ""
echo "-- Проверка payment_id"
echo "SELECT id FROM payments WHERE id = '$PAYMENT_ID';"
echo ""
echo "-- Проверка user_id"
echo "SELECT id FROM profiles WHERE id = (SELECT user_id FROM payments WHERE id = '$PAYMENT_ID');"
echo ""

echo "=========================================="
echo "Выполните эти запросы в Adminer или psql"
echo "=========================================="

