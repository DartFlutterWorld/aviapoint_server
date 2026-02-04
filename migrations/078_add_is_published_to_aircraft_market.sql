-- Миграция 078: Добавление поля is_published в таблицу aircraft_market

-- Добавляем поле is_published, если его нет
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'aircraft_market' 
        AND column_name = 'is_published'
    ) THEN
        ALTER TABLE aircraft_market 
        ADD COLUMN is_published BOOLEAN DEFAULT TRUE;
        
        -- Устанавливаем значение по умолчанию для существующих записей
        UPDATE aircraft_market 
        SET is_published = TRUE 
        WHERE is_published IS NULL;
        
        -- Делаем поле NOT NULL после установки значений
        ALTER TABLE aircraft_market 
        ALTER COLUMN is_published SET NOT NULL;
        
        -- Создаем индекс для быстрого поиска опубликованных объявлений
        CREATE INDEX IF NOT EXISTS idx_aircraft_market_is_published 
        ON aircraft_market(is_published) 
        WHERE is_published = TRUE;
        
        COMMENT ON COLUMN aircraft_market.is_published IS 'Опубликовано ли объявление пользователем (true) или сохранено как черновик (false)';
    END IF;
END $$;
