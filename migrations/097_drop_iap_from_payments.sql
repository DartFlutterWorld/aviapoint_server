-- Миграция 097: Удаление поддержки Apple IAP из таблицы payments
-- Все платежи идут через YooKassa; колонки payment_source и apple_* больше не используются.

DO $$
BEGIN
    -- Удаляем индексы, связанные с IAP
    IF EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'payments' AND indexname = 'idx_payments_apple_transaction_id') THEN
        DROP INDEX idx_payments_apple_transaction_id;
    END IF;
    IF EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'payments' AND indexname = 'idx_payments_payment_source') THEN
        DROP INDEX idx_payments_payment_source;
    END IF;

    -- Удаляем колонки IAP
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'payments' AND column_name = 'apple_original_transaction_id') THEN
        ALTER TABLE payments DROP COLUMN apple_original_transaction_id;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'payments' AND column_name = 'apple_transaction_id') THEN
        ALTER TABLE payments DROP COLUMN apple_transaction_id;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'payments' AND column_name = 'payment_source') THEN
        ALTER TABLE payments DROP COLUMN payment_source;
    END IF;
END $$;
