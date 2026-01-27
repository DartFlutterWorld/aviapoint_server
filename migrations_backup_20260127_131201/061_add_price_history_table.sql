-- Миграция: Создание таблицы истории цен для объявлений о самолетах
-- Дата: 2026-01-13

BEGIN;

-- Создаем таблицу истории цен
CREATE TABLE IF NOT EXISTS aircraft_market_price_history (
    id SERIAL PRIMARY KEY,
    aircraft_market_id INTEGER NOT NULL REFERENCES aircraft_market(id) ON DELETE CASCADE,
    price INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создаем индекс для быстрого поиска по объявлению
CREATE INDEX IF NOT EXISTS idx_aircraft_market_price_history_aircraft_market_id 
ON aircraft_market_price_history(aircraft_market_id);

-- Создаем индекс для сортировки по дате
CREATE INDEX IF NOT EXISTS idx_aircraft_market_price_history_created_at 
ON aircraft_market_price_history(created_at DESC);

-- Заполняем историю для существующих объявлений (первая запись - дата создания)
INSERT INTO aircraft_market_price_history (aircraft_market_id, price, created_at)
SELECT id, price, created_at
FROM aircraft_market
WHERE created_at IS NOT NULL
ON CONFLICT DO NOTHING;

COMMIT;
