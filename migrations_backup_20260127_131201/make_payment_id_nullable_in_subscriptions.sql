-- Изменение поля payment_id в таблице subscriptions на nullable
-- Это позволит удалять подписки без ошибки ограничения NOT NULL

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
        -- Изменяем колонку payment_id на nullable
        ALTER TABLE subscriptions
        ALTER COLUMN payment_id DROP NOT NULL;
        
        RAISE NOTICE 'payment_id column in subscriptions table is now nullable';
    ELSE
        RAISE NOTICE 'Таблица subscriptions не существует';
    END IF;
END $$;

