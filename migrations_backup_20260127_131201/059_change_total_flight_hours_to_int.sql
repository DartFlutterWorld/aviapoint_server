-- Миграция: Изменение типа total_flight_hours с NUMERIC на INTEGER
-- Дата: 2026-01-13

BEGIN;

-- Изменяем тип total_flight_hours с NUMERIC на INTEGER
ALTER TABLE aircraft_market 
ALTER COLUMN total_flight_hours TYPE INTEGER USING total_flight_hours::INTEGER;

COMMIT;
