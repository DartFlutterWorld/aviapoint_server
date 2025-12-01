#!/bin/bash

# Скрипт для выполнения миграций в правильном порядке

echo "Выполнение миграций в правильном порядке..."

# 1. Создание таблицы payments (если еще не создана)
echo "1. Создание таблицы payments..."
psql -h localhost -U postgres -d aviapoint -f migrations/create_payments_table.sql

# 2. Создание таблицы subscriptions
echo "2. Создание таблицы subscriptions..."
psql -h localhost -U postgres -d aviapoint -f migrations/create_subscriptions_table.sql

# 3. Добавление полей подписки в профиль
echo "3. Добавление полей подписки в профиль..."
psql -h localhost -U postgres -d aviapoint -f migrations/add_subscription_fields_to_profiles.sql

echo "Миграции выполнены!"

