-- Миграция 080: Создание таблицы истории цен для объявлений о запчастях
-- Дата: 2026-02-01

BEGIN;

-- Создаем таблицу истории цен
CREATE TABLE IF NOT EXISTS parts_market_price_history (
    id SERIAL PRIMARY KEY,
    part_id INTEGER NOT NULL REFERENCES parts_market(id) ON DELETE CASCADE,
    price INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создаем индекс для быстрого поиска по объявлению
CREATE INDEX IF NOT EXISTS idx_parts_market_price_history_part_id 
ON parts_market_price_history(part_id);

-- Создаем индекс для сортировки по дате
CREATE INDEX IF NOT EXISTS idx_parts_market_price_history_created_at 
ON parts_market_price_history(created_at DESC);

-- Заполняем историю для существующих объявлений (первая запись - дата создания)
INSERT INTO parts_market_price_history (part_id, price, created_at)
SELECT id, price, created_at
FROM parts_market
WHERE created_at IS NOT NULL
ON CONFLICT DO NOTHING;

COMMIT;
