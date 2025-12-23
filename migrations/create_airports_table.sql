-- Создание таблицы аэропортов на основе данных OurAirports
-- С расширяемыми полями для будущей функциональности

CREATE TABLE IF NOT EXISTS airports (
  id SERIAL PRIMARY KEY,
  
  -- Основные данные из OurAirports
  ident VARCHAR(10) UNIQUE NOT NULL, -- ICAO код (например, UUDD)
  type VARCHAR(50) NOT NULL, -- airport, heliport, seaplane_base, etc.
  name VARCHAR(255) NOT NULL,
  latitude_deg DECIMAL(10, 7) NOT NULL,
  longitude_deg DECIMAL(10, 7) NOT NULL,
  elevation_ft INTEGER,
  continent VARCHAR(2), -- EU, AS, NA, SA, AF, AN, OC
  iso_country VARCHAR(2) NOT NULL, -- RU, US, etc.
  iso_region VARCHAR(10), -- RU-MOW, US-CA, etc.
  municipality VARCHAR(255), -- Город
  scheduled_service VARCHAR(3), -- yes/no
  gps_code VARCHAR(10), -- GPS код
  iata_code VARCHAR(3), -- IATA код (если есть)
  local_code VARCHAR(10), -- Локальный код
  
  -- Дополнительные поля для расширения функциональности
  services JSONB DEFAULT '{}', -- JSON объект с услугами аэропорта (заправка, стоянка, ремонт и т.д.)
  owner_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL, -- Владелец аэропорта (для будущего функционала)
  is_verified BOOLEAN DEFAULT FALSE, -- Проверен ли аэропорт администрацией
  is_active BOOLEAN DEFAULT TRUE, -- Активен ли аэропорт
  
  -- Метаданные
  source VARCHAR(50) DEFAULT 'ourairports', -- Источник данных
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Ограничения
  CHECK (latitude_deg >= -90 AND latitude_deg <= 90),
  CHECK (longitude_deg >= -180 AND longitude_deg <= 180)
);

-- Индексы для производительности
CREATE INDEX IF NOT EXISTS idx_airports_ident ON airports(ident);
CREATE INDEX IF NOT EXISTS idx_airports_iata_code ON airports(iata_code) WHERE iata_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_airports_gps_code ON airports(gps_code) WHERE gps_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_airports_iso_country ON airports(iso_country);
CREATE INDEX IF NOT EXISTS idx_airports_type ON airports(type);
CREATE INDEX IF NOT EXISTS idx_airports_name ON airports(name);
CREATE INDEX IF NOT EXISTS idx_airports_municipality ON airports(municipality) WHERE municipality IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_airports_location ON airports USING GIST (point(longitude_deg, latitude_deg)); -- Для геопоиска (требует расширение postgis)
CREATE INDEX IF NOT EXISTS idx_airports_owner_id ON airports(owner_id) WHERE owner_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_airports_is_active ON airports(is_active);

-- Триггер для обновления updated_at
DROP TRIGGER IF EXISTS update_airports_updated_at ON airports;
CREATE TRIGGER update_airports_updated_at BEFORE UPDATE ON airports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Комментарии к таблице и полям
COMMENT ON TABLE airports IS 'База данных аэропортов на основе OurAirports с расширяемыми полями';
COMMENT ON COLUMN airports.services IS 'JSON объект с услугами: {"fuel": true, "parking": true, "maintenance": false, "catering": true, etc.}';
COMMENT ON COLUMN airports.owner_id IS 'ID владельца аэропорта из таблицы profiles (для будущего функционала редактирования)';
COMMENT ON COLUMN airports.is_verified IS 'Проверен ли аэропорт администрацией платформы';
COMMENT ON COLUMN airports.source IS 'Источник данных (ourairports, manual, etc.)';

