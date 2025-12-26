-- Удаление старой таблицы airports и создание новой на основе данных АОПА-Россия
-- Эта миграция удаляет все существующие данные и создает новую структуру

-- Удаляем старую таблицу (если существует)
DROP TABLE IF EXISTS airports CASCADE;

-- Создаем новую таблицу с полями из CSV АОПА
CREATE TABLE airports (
  id SERIAL PRIMARY KEY,
  
  -- Основные данные из АОПА CSV
  is_active BOOLEAN DEFAULT TRUE, -- Действующий (из CSV: "Действующий")
  type VARCHAR(50) NOT NULL, -- Тип (Вертодром, Аэродром и т.д.)
  name VARCHAR(255) NOT NULL, -- Название
  name_eng VARCHAR(255), -- Название [eng]
  city VARCHAR(255), -- Город
  ident VARCHAR(10) UNIQUE NOT NULL, -- Индекс (код аэродрома, например HEE1)
  ident_ru VARCHAR(10), -- Индекс RU (русский код, например ХЕЕ1)
  country_code VARCHAR(20), -- Код страны (например, UU-RUSSIA)
  country VARCHAR(100), -- Страна
  country_eng VARCHAR(100), -- Страна [анг]
  region VARCHAR(255), -- Регион
  region_eng VARCHAR(255), -- Регион [анг]
  coordinates_text VARCHAR(100), -- КТА (текстовое представление координат)
  longitude_deg DECIMAL(10, 7) NOT NULL, -- Долгота КТА
  latitude_deg DECIMAL(10, 7) NOT NULL, -- Широта КТА
  elevation_ft INTEGER, -- Превышение (высота над уровнем моря)
  ownership VARCHAR(100), -- Принадлежность
  is_international BOOLEAN DEFAULT FALSE, -- Международный
  email VARCHAR(255), -- Email
  website VARCHAR(255), -- Web-сайт
  notes TEXT, -- Примечание
  
  -- Данные о ВПП
  runway_name VARCHAR(255), -- Название основной ВПП
  runway_length INTEGER, -- Длина основной ВПП (в метрах)
  runway_width INTEGER, -- Ширина основной ВПП (в метрах)
  runway_surface VARCHAR(100), -- Покрытие основной ВПП
  runway_magnetic_course VARCHAR(50), -- Магнитный курс основной ВПП
  runway_lighting VARCHAR(50), -- Освещение основной ВПП
  
  -- Дополнительные поля
  services JSONB DEFAULT '{}', -- JSON объект с услугами аэропорта
  owner_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL, -- Владелец аэропорта
  is_verified BOOLEAN DEFAULT FALSE, -- Проверен ли аэропорт администрацией
  
  -- Метаданные
  source VARCHAR(50) DEFAULT 'aopa', -- Источник данных
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Ограничения
  CHECK (latitude_deg >= -90 AND latitude_deg <= 90),
  CHECK (longitude_deg >= -180 AND longitude_deg <= 180)
);

-- Индексы для производительности
CREATE INDEX idx_airports_ident ON airports(ident);
CREATE INDEX idx_airports_ident_ru ON airports(ident_ru) WHERE ident_ru IS NOT NULL;
CREATE INDEX idx_airports_country_code ON airports(country_code) WHERE country_code IS NOT NULL;
CREATE INDEX idx_airports_type ON airports(type);
CREATE INDEX idx_airports_name ON airports(name);
CREATE INDEX idx_airports_city ON airports(city) WHERE city IS NOT NULL;
CREATE INDEX idx_airports_region ON airports(region) WHERE region IS NOT NULL;
CREATE INDEX idx_airports_is_active ON airports(is_active);
CREATE INDEX idx_airports_location ON airports USING GIST (point(longitude_deg, latitude_deg));

-- Триггер для обновления updated_at
DROP TRIGGER IF EXISTS update_airports_updated_at ON airports;
CREATE TRIGGER update_airports_updated_at BEFORE UPDATE ON airports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Комментарии к таблице и полям
COMMENT ON TABLE airports IS 'База данных аэропортов на основе данных АОПА-Россия';
COMMENT ON COLUMN airports.ident IS 'Код аэродрома из АОПА (например, HEE1)';
COMMENT ON COLUMN airports.ident_ru IS 'Русский код аэродрома (например, ХЕЕ1)';
COMMENT ON COLUMN airports.source IS 'Источник данных (aopa, manual, etc.)';

