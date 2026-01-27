-- Скрипт для полной очистки таблиц payments и subscriptions
-- ВНИМАНИЕ: Это удалит ВСЕ данные из этих таблиц!
-- Использование: выполните в Adminer или через psql

-- Очистка таблиц (CASCADE удалит связанные данные)
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE subscriptions CASCADE;

-- Проверка количества записей (должно быть 0)
SELECT 
    'payments' as table_name, 
    COUNT(*) as count 
FROM payments 
UNION ALL 
SELECT 
    'subscriptions', 
    COUNT(*) 
FROM subscriptions;

