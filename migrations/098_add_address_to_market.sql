-- Миграция 098: Структурированный адрес (Nominatim) для маркета самолётов и запчастей

-- aircraft_market: добавляем колонку address (JSONB)
ALTER TABLE aircraft_market
  ADD COLUMN IF NOT EXISTS address JSONB;

COMMENT ON COLUMN aircraft_market.address IS 'Структура адреса из геокодинга (country, region, city, street, house_number, postcode). Колонка location — текстовая строка для отображения (дублирует или собирается из address).';

-- parts_market: добавляем колонку address (JSONB)
ALTER TABLE parts_market
  ADD COLUMN IF NOT EXISTS address JSONB;

COMMENT ON COLUMN parts_market.address IS 'Структура адреса из геокодинга (country, region, city, street, house_number, postcode). Колонка location — текстовая строка для отображения.';

-- Индексы для поиска по адресу (опционально, для будущего поиска по региону/городу)
CREATE INDEX IF NOT EXISTS idx_aircraft_market_address_gin ON aircraft_market USING GIN (address) WHERE address IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_parts_market_address_gin ON parts_market USING GIN (address) WHERE address IS NOT NULL;
