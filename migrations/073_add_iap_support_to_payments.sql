-- Миграция 073: Добавление поддержки Apple In-App Purchases
-- Добавляет поля для различения источников платежей (YooKassa vs Apple IAP)

DO $$ 
BEGIN
    -- Добавляем поле payment_source для указания источника платежа
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'payments' AND column_name = 'payment_source'
    ) THEN
        ALTER TABLE payments ADD COLUMN payment_source VARCHAR(50) DEFAULT 'yookassa';
        COMMENT ON COLUMN payments.payment_source IS 'Источник платежа: yookassa или apple_iap';
    END IF;

    -- Добавляем поле apple_transaction_id для хранения transaction_id от Apple
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'payments' AND column_name = 'apple_transaction_id'
    ) THEN
        ALTER TABLE payments ADD COLUMN apple_transaction_id VARCHAR(255);
        COMMENT ON COLUMN payments.apple_transaction_id IS 'Transaction ID от Apple App Store для IAP платежей';
    END IF;

    -- Добавляем поле apple_original_transaction_id для отслеживания подписок
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'payments' AND column_name = 'apple_original_transaction_id'
    ) THEN
        ALTER TABLE payments ADD COLUMN apple_original_transaction_id VARCHAR(255);
        COMMENT ON COLUMN payments.apple_original_transaction_id IS 'Original Transaction ID от Apple для отслеживания подписок';
    END IF;

    -- Создаем индекс для быстрого поиска по Apple transaction_id
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'payments' AND indexname = 'idx_payments_apple_transaction_id'
    ) THEN
        CREATE INDEX idx_payments_apple_transaction_id ON payments(apple_transaction_id);
    END IF;

    -- Создаем индекс для поиска по payment_source
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'payments' AND indexname = 'idx_payments_payment_source'
    ) THEN
        CREATE INDEX idx_payments_payment_source ON payments(payment_source);
    END IF;
END $$;
