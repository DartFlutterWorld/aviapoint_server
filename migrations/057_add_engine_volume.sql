-- Миграция: Добавление поля engine_volume (объём двигателя)
-- Дата: 2026-01-13

BEGIN;

-- Добавляем новое поле engine_volume (объём двигателя в литрах)
ALTER TABLE aircraft_market 
ADD COLUMN IF NOT EXISTS engine_volume NUMERIC(10, 2);

COMMIT;
