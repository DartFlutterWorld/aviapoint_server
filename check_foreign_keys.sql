-- Скрипт для проверки foreign key constraints при создании подписки
-- Использование: выполните в Adminer или psql

-- 1. Проверка существования subscription_type_id
-- Замените 'monthly' на нужный код
SELECT 
    id, 
    code, 
    name, 
    is_active 
FROM subscription_types 
WHERE code = 'monthly';

-- Если запись не найдена, создайте её:
-- INSERT INTO subscription_types (code, name, period_days, price, is_active, description)
-- VALUES ('monthly', 'Месячная подписка', 30, 700, true, 'Месячная подписка')
-- ON CONFLICT (code) DO NOTHING;

-- 2. Проверка существования payment_id
-- Замените 'YOUR_PAYMENT_ID' на реальный ID платежа
SELECT 
    id, 
    status, 
    paid, 
    user_id,
    subscription_type,
    period_days
FROM payments 
WHERE id = 'YOUR_PAYMENT_ID';

-- 3. Проверка существования user_id
-- Замените YOUR_USER_ID на реальный ID пользователя
SELECT 
    id, 
    phone, 
    first_name, 
    last_name 
FROM profiles 
WHERE id = YOUR_USER_ID;

-- 4. Проверка всех foreign key constraints таблицы subscriptions
SELECT
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule,
    rc.update_rule
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
JOIN information_schema.referential_constraints AS rc
  ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name = 'subscriptions';

-- 5. Попытка создать тестовую подписку (для проверки)
-- ВНИМАНИЕ: Замените значения на реальные!
/*
INSERT INTO subscriptions (
    user_id, 
    payment_id, 
    subscription_type_id, 
    period_days,
    start_date, 
    end_date, 
    is_active, 
    amount
) VALUES (
    1,  -- user_id (должен существовать в profiles)
    'test-payment-123',  -- payment_id (должен существовать в payments)
    1,  -- subscription_type_id (должен существовать в subscription_types)
    30,  -- period_days
    CURRENT_TIMESTAMP,  -- start_date
    CURRENT_TIMESTAMP + INTERVAL '30 days',  -- end_date
    true,  -- is_active
    700  -- amount
);
*/

