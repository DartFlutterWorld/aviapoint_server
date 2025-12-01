-- Скрипт для выполнения всех миграций в правильном порядке

-- 1. Сначала создаем таблицу subscriptions
\i migrations/create_subscriptions_table.sql

-- 2. Потом добавляем поля в профиль
\i migrations/add_subscription_fields_to_profiles.sql

