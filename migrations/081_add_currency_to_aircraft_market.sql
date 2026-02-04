-- Миграция 081: Добавление поля currency в таблицу aircraft_market

-- Добавляем поле currency, если его нет
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'aircraft_market' 
        AND column_name = 'currency'
    ) THEN
        ALTER TABLE aircraft_market 
        ADD COLUMN currency VARCHAR(3) DEFAULT 'RUB';
        
        -- Устанавливаем значение по умолчанию для существующих записей
        UPDATE aircraft_market 
        SET currency = 'RUB' 
        WHERE currency IS NULL;
        
        -- Делаем поле NOT NULL после установки значений
        ALTER TABLE aircraft_market 
        ALTER COLUMN currency SET NOT NULL;
        
        -- Создаем индекс для быстрого поиска по валюте
        CREATE INDEX IF NOT EXISTS idx_aircraft_market_currency 
        ON aircraft_market(currency);
        
        COMMENT ON COLUMN aircraft_market.currency IS 'Валюта цены (RUB, USD, EUR)';
    END IF;
END $$;
