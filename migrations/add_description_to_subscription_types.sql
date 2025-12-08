-- Добавление поля description в таблицу subscription_types
-- Это поле содержит описание типа подписки

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscription_types') THEN
        -- Добавляем поле description, если его нет
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'subscription_types' AND column_name = 'description'
        ) THEN
            ALTER TABLE subscription_types
            ADD COLUMN description TEXT NOT NULL DEFAULT '';
            
            -- Обновляем существующие записи, если description пустой
            UPDATE subscription_types SET description = '' WHERE description IS NULL;
            
            RAISE NOTICE 'Added description column to subscription_types table';
        ELSE
            RAISE NOTICE 'description column already exists in subscription_types table';
        END IF;
    ELSE
        RAISE NOTICE 'Таблица subscription_types не существует. Создайте её сначала через migrations/create_subscriptions_table.sql';
    END IF;
END $$;

