-- Добавление поля user_id в таблицу payments
-- Это необходимо для связи платежа с пользователем

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN
        -- Добавляем колонку user_id, если её нет
        ALTER TABLE payments
        ADD COLUMN IF NOT EXISTS user_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL;

        -- Создаем индекс для быстрого поиска платежей по пользователю
        CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
        
        RAISE NOTICE 'user_id field added to payments table';
    ELSE
        RAISE NOTICE 'Таблица payments не существует. Создайте её сначала.';
    END IF;
END $$;

