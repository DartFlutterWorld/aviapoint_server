-- Миграция: Изменение типов price, engine_power, engine_volume с NUMERIC на INTEGER
-- Дата: 2026-01-13

BEGIN;

-- Изменяем тип price с NUMERIC на INTEGER
ALTER TABLE aircraft_market 
ALTER COLUMN price TYPE INTEGER USING price::INTEGER;

-- Изменяем тип engine_power с NUMERIC на INTEGER
ALTER TABLE aircraft_market 
ALTER COLUMN engine_power TYPE INTEGER USING engine_power::INTEGER;

-- Изменяем тип engine_volume с NUMERIC на INTEGER
ALTER TABLE aircraft_market 
ALTER COLUMN engine_volume TYPE INTEGER USING engine_volume::INTEGER;

COMMIT;
