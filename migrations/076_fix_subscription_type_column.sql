-- Миграция 076: Исправление удаления subscription_type из таблицы payments
-- Удаляет NOT NULL ограничение перед удалением колонки

DO $$ 
BEGIN
    -- Сначала удаляем NOT NULL ограничение, если оно есть
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'payments' 
        AND column_name = 'subscription_type'
        AND is_nullable = 'NO'
    ) THEN
        -- Делаем колонку nullable перед удалением
        ALTER TABLE payments ALTER COLUMN subscription_type DROP NOT NULL;
    END IF;
    
    -- Теперь удаляем колонку
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'payments' 
        AND column_name = 'subscription_type'
    ) THEN
        ALTER TABLE payments DROP COLUMN subscription_type;
    END IF;
END $$;
