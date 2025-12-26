-- Добавление поля airport_code в таблицу airport_ownership_requests

ALTER TABLE airport_ownership_requests ADD COLUMN IF NOT EXISTS airport_code VARCHAR(10);

-- Индекс для поиска заявок по коду аэропорта
CREATE INDEX IF NOT EXISTS idx_airport_ownership_requests_airport_code ON airport_ownership_requests(airport_code) WHERE airport_code IS NOT NULL;

COMMENT ON COLUMN airport_ownership_requests.airport_code IS 'Код ICAO аэропорта';


