-- Создание нормализованной структуры базы данных для каталога самолётов
-- Структура: manufacturers -> aircraft_models -> aircraft_model_specs (опционально)

-- ============================================
-- Таблица производителей
-- ============================================
CREATE TABLE IF NOT EXISTS manufacturers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  country VARCHAR(100),
  website VARCHAR(255),
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Индексы для производителей
CREATE INDEX IF NOT EXISTS idx_manufacturers_name ON manufacturers(name);
CREATE INDEX IF NOT EXISTS idx_manufacturers_active ON manufacturers(is_active);
CREATE INDEX IF NOT EXISTS idx_manufacturers_country ON manufacturers(country);

-- ============================================
-- Таблица моделей самолётов
-- ============================================
CREATE TABLE IF NOT EXISTS aircraft_models (
  id SERIAL PRIMARY KEY,
  manufacturer_id INTEGER NOT NULL REFERENCES manufacturers(id) ON DELETE CASCADE,
  model_code VARCHAR(100) NOT NULL, -- Код модели (например, "172", "SR22", "PA-28")
  full_name VARCHAR(255) NOT NULL,  -- Полное название (например, "Cessna 172 Skyhawk")
  category VARCHAR(50),              -- single_engine, twin_engine, helicopter, ultralight, jet, etc.
  engine_type VARCHAR(50),           -- piston, turboprop, jet, turbine, electric
  engine_count INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(manufacturer_id, model_code)
);

-- Индексы для моделей
CREATE INDEX IF NOT EXISTS idx_aircraft_models_manufacturer ON aircraft_models(manufacturer_id);
CREATE INDEX IF NOT EXISTS idx_aircraft_models_category ON aircraft_models(category);
CREATE INDEX IF NOT EXISTS idx_aircraft_models_active ON aircraft_models(is_active);
CREATE INDEX IF NOT EXISTS idx_aircraft_models_full_name ON aircraft_models(full_name);
CREATE INDEX IF NOT EXISTS idx_aircraft_models_model_code ON aircraft_models(model_code);

-- ============================================
-- Таблица расширенных характеристик моделей (опционально)
-- ============================================
CREATE TABLE IF NOT EXISTS aircraft_model_specs (
  id SERIAL PRIMARY KEY,
  aircraft_model_id INTEGER NOT NULL REFERENCES aircraft_models(id) ON DELETE CASCADE,
  seats INTEGER,                     -- Количество мест
  max_speed_kmh INTEGER,             -- Максимальная скорость (км/ч)
  cruise_speed_kmh INTEGER,          -- Крейсерская скорость (км/ч)
  range_km INTEGER,                  -- Дальность полёта (км)
  max_altitude_ft INTEGER,           -- Практический потолок (футы)
  max_takeoff_weight_kg INTEGER,     -- Максимальный взлётный вес (кг)
  empty_weight_kg INTEGER,           -- Вес пустого (кг)
  fuel_capacity_liters INTEGER,      -- Ёмкость топливных баков (литры)
  description TEXT,                  -- Описание модели
  photo_url TEXT,                    -- URL фотографии
  source_url TEXT,                   -- Ссылка на источник данных
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(aircraft_model_id)
);

-- Индекс для характеристик
CREATE INDEX IF NOT EXISTS idx_aircraft_model_specs_model ON aircraft_model_specs(aircraft_model_id);

-- ============================================
-- Обновление таблицы flights для связи с новой структурой
-- ============================================
-- Опционально: можно добавить внешний ключ на aircraft_models.id
-- Пока оставляем aircraft_type как VARCHAR для обратной совместимости
-- ALTER TABLE flights ADD COLUMN IF NOT EXISTS aircraft_model_id INTEGER REFERENCES aircraft_models(id);
-- CREATE INDEX IF NOT EXISTS idx_flights_aircraft_model ON flights(aircraft_model_id);

-- ============================================
-- Триггеры для обновления updated_at
-- ============================================
DROP TRIGGER IF EXISTS update_manufacturers_updated_at ON manufacturers;
CREATE TRIGGER update_manufacturers_updated_at BEFORE UPDATE ON manufacturers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_aircraft_models_updated_at ON aircraft_models;
CREATE TRIGGER update_aircraft_models_updated_at BEFORE UPDATE ON aircraft_models
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_aircraft_model_specs_updated_at ON aircraft_model_specs;
CREATE TRIGGER update_aircraft_model_specs_updated_at BEFORE UPDATE ON aircraft_model_specs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Комментарии к таблицам и полям
-- ============================================
COMMENT ON TABLE manufacturers IS 'Каталог производителей самолётов';
COMMENT ON COLUMN manufacturers.name IS 'Название производителя (например, Cessna, Piper, Cirrus)';
COMMENT ON COLUMN manufacturers.country IS 'Страна происхождения';
COMMENT ON COLUMN manufacturers.is_active IS 'Активен ли производитель для выбора';

COMMENT ON TABLE aircraft_models IS 'Каталог моделей самолётов';
COMMENT ON COLUMN aircraft_models.manufacturer_id IS 'Ссылка на производителя';
COMMENT ON COLUMN aircraft_models.model_code IS 'Код модели (например, "172", "SR22", "PA-28")';
COMMENT ON COLUMN aircraft_models.full_name IS 'Полное название модели (например, "Cessna 172 Skyhawk")';
COMMENT ON COLUMN aircraft_models.category IS 'Категория: single_engine, twin_engine, helicopter, ultralight, jet';
COMMENT ON COLUMN aircraft_models.engine_type IS 'Тип двигателя: piston, turboprop, jet, turbine, electric';
COMMENT ON COLUMN aircraft_models.engine_count IS 'Количество двигателей';

COMMENT ON TABLE aircraft_model_specs IS 'Расширенные технические характеристики моделей самолётов';
COMMENT ON COLUMN aircraft_model_specs.aircraft_model_id IS 'Ссылка на модель самолёта';
COMMENT ON COLUMN aircraft_model_specs.seats IS 'Количество мест';
COMMENT ON COLUMN aircraft_model_specs.max_speed_kmh IS 'Максимальная скорость в км/ч';
COMMENT ON COLUMN aircraft_model_specs.cruise_speed_kmh IS 'Крейсерская скорость в км/ч';
COMMENT ON COLUMN aircraft_model_specs.range_km IS 'Дальность полёта в км';

-- ============================================
-- Представления для удобства запросов
-- ============================================
-- Примечание: Представление aircraft_catalog_view было удалено миграцией 051,
-- так как не используется в коде. Фронтенд работает напрямую с таблицами через JOIN.

