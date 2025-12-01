-- Добавление полей для хранения информации о подписке в таблице payments
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN
        -- Добавляем поля для типа подписки и периода
        ALTER TABLE payments 
        ADD COLUMN IF NOT EXISTS subscription_type VARCHAR(50),
        ADD COLUMN IF NOT EXISTS period_days INTEGER;

        -- Создаем индекс для быстрого поиска
        CREATE INDEX IF NOT EXISTS idx_payments_subscription_type ON payments(subscription_type);
    ELSE
        RAISE NOTICE 'Таблица payments не существует. Создайте её сначала через migrations/create_payments_table.sql';
    END IF;
END $$;

