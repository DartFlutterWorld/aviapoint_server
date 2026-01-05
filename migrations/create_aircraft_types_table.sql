-- Создание таблицы каталога типов самолётов

CREATE TABLE IF NOT EXISTS aircraft_types (
  id SERIAL PRIMARY KEY,
  manufacturer VARCHAR(100) NOT NULL,
  model VARCHAR(100) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  category VARCHAR(50), -- single_engine, twin_engine, helicopter, ultralight, etc.
  seats INTEGER,
  max_speed_kmh INTEGER,
  cruise_speed_kmh INTEGER,
  range_km INTEGER,
  engine_type VARCHAR(50), -- piston, turboprop, jet, etc.
  engine_count INTEGER,
  description TEXT,
  photo_url TEXT,
  source_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(manufacturer, model)
);

-- Индексы для производительности
CREATE INDEX IF NOT EXISTS idx_aircraft_types_manufacturer ON aircraft_types(manufacturer);
CREATE INDEX IF NOT EXISTS idx_aircraft_types_category ON aircraft_types(category);
CREATE INDEX IF NOT EXISTS idx_aircraft_types_active ON aircraft_types(is_active);
CREATE INDEX IF NOT EXISTS idx_aircraft_types_full_name ON aircraft_types(full_name);

-- Триггер для обновления updated_at
DROP TRIGGER IF EXISTS update_aircraft_types_updated_at ON aircraft_types;
CREATE TRIGGER update_aircraft_types_updated_at BEFORE UPDATE ON aircraft_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Комментарии к таблице и полям
COMMENT ON TABLE aircraft_types IS 'Каталог типов самолётов малой авиации';
COMMENT ON COLUMN aircraft_types.manufacturer IS 'Производитель (например, Cessna, Piper, Cirrus)';
COMMENT ON COLUMN aircraft_types.model IS 'Модель (например, 172, SR22, PA-28)';
COMMENT ON COLUMN aircraft_types.full_name IS 'Полное название модели (например, Cessna 172 Skyhawk)';
COMMENT ON COLUMN aircraft_types.category IS 'Категория: single_engine, twin_engine, helicopter, ultralight, jet, etc.';
COMMENT ON COLUMN aircraft_types.seats IS 'Количество мест';
COMMENT ON COLUMN aircraft_types.max_speed_kmh IS 'Максимальная скорость в км/ч';
COMMENT ON COLUMN aircraft_types.cruise_speed_kmh IS 'Крейсерская скорость в км/ч';
COMMENT ON COLUMN aircraft_types.range_km IS 'Дальность полёта в км';
COMMENT ON COLUMN aircraft_types.engine_type IS 'Тип двигателя: piston, turboprop, jet, etc.';
COMMENT ON COLUMN aircraft_types.engine_count IS 'Количество двигателей';
COMMENT ON COLUMN aircraft_types.source_url IS 'Ссылка на источник данных (например, PlaneCheck.com)';

