-- Миграция: Переименование flight_hours в total_flight_hours и добавление engine_power
-- Дата: 2026-01-13

BEGIN;

-- Переименовываем колонку flight_hours в total_flight_hours
ALTER TABLE aircraft_market 
RENAME COLUMN flight_hours TO total_flight_hours;

-- Добавляем новое поле engine_power (мощность двигателя в л.с.)
ALTER TABLE aircraft_market 
ADD COLUMN IF NOT EXISTS engine_power NUMERIC(10, 2);

COMMIT;
