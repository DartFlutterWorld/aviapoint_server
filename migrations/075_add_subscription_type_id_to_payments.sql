-- Миграция 075: Добавление subscription_type_id и удаление subscription_type из таблицы payments
-- Заменяет использование subscription_type (код) на subscription_type_id (ID)

DO $$ 
BEGIN
    -- Добавляем поле subscription_type_id для хранения ID типа подписки
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'payments' AND column_name = 'subscription_type_id'
    ) THEN
        ALTER TABLE payments ADD COLUMN subscription_type_id INTEGER;
        COMMENT ON COLUMN payments.subscription_type_id IS 'ID типа подписки из таблицы subscription_types';
        
        -- Создаем внешний ключ на subscription_types
        ALTER TABLE payments 
        ADD CONSTRAINT fk_payments_subscription_type_id 
        FOREIGN KEY (subscription_type_id) 
        REFERENCES subscription_types(id);
        
        -- Создаем индекс для быстрого поиска
        CREATE INDEX idx_payments_subscription_type_id ON payments(subscription_type_id);
    END IF;
    
    -- Удаляем старое поле subscription_type (больше не используется)
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
