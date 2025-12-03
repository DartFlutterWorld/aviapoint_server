-- Проверка и добавление всех необходимых полей в таблицу payments
-- Выполняет все миграции для payments в правильном порядке

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN
        -- 1. Добавляем subscription_type и period_days (если их нет)
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'payments' AND column_name = 'subscription_type'
        ) THEN
            ALTER TABLE payments
            ADD COLUMN subscription_type VARCHAR(50);
            
            CREATE INDEX IF NOT EXISTS idx_payments_subscription_type ON payments(subscription_type);
            
            RAISE NOTICE 'Added subscription_type column to payments table';
        ELSE
            RAISE NOTICE 'subscription_type column already exists';
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'payments' AND column_name = 'period_days'
        ) THEN
            ALTER TABLE payments
            ADD COLUMN period_days INTEGER;
            
            CREATE INDEX IF NOT EXISTS idx_payments_period_days ON payments(period_days);
            
            RAISE NOTICE 'Added period_days column to payments table';
        ELSE
            RAISE NOTICE 'period_days column already exists';
        END IF;

        -- 2. Добавляем user_id (если его нет)
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'payments' AND column_name = 'user_id'
        ) THEN
            ALTER TABLE payments
            ADD COLUMN user_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL;
            
            CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
            
            RAISE NOTICE 'Added user_id column to payments table';
        ELSE
            RAISE NOTICE 'user_id column already exists';
        END IF;

        RAISE NOTICE 'All required columns checked and added to payments table';
    ELSE
        RAISE NOTICE 'Таблица payments не существует. Создайте её сначала.';
    END IF;
END $$;

