-- Миграция 077: Создание таблиц для объявлений о продаже запчастей

-- ============================================
-- 1. ТАБЛИЦА ПРОИЗВОДИТЕЛЕЙ ЗАПЧАСТЕЙ
-- ============================================

CREATE TABLE IF NOT EXISTS parts_manufacturers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    name_en VARCHAR(255),
    country VARCHAR(100),
    website VARCHAR(255),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_parts_manufacturers_name ON parts_manufacturers(name);
CREATE INDEX IF NOT EXISTS idx_parts_manufacturers_active ON parts_manufacturers(is_active);

COMMENT ON TABLE parts_manufacturers IS 'Таблица производителей авиазапчастей';
COMMENT ON COLUMN parts_manufacturers.name IS 'Название производителя';
COMMENT ON COLUMN parts_manufacturers.name_en IS 'Английское название';
COMMENT ON COLUMN parts_manufacturers.country IS 'Страна производителя';

-- ============================================
-- 2. ТАБЛИЦА ОБЪЯВЛЕНИЙ О ПРОДАЖЕ ЗАПЧАСТЕЙ
-- ============================================

CREATE TABLE IF NOT EXISTS parts_market (
    -- Основные идентификаторы
    id SERIAL PRIMARY KEY,
    seller_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    parts_subcategory_id INTEGER REFERENCES parts_subcategories(id) ON DELETE SET NULL,
    parts_main_category_id INTEGER REFERENCES parts_main_categories(id) ON DELETE SET NULL,
    
    -- Производитель (вариант 3)
    manufacturer_id INTEGER REFERENCES parts_manufacturers(id) ON DELETE SET NULL,
    manufacturer_name VARCHAR(255), -- Для ручного ввода, если производителя нет в списке
    
    -- Название и описание
    title VARCHAR(500) NOT NULL,
    description TEXT,
    
    -- Фотографии
    main_image_url VARCHAR(512),
    additional_image_urls JSONB DEFAULT '[]'::jsonb,
    
    -- Номера запчасти
    part_number VARCHAR(255),
    oem_number VARCHAR(255),
    
    -- Состояние
    condition VARCHAR(50) DEFAULT 'used', -- 'new', 'used', 'overhauled', 'repaired'
    
    -- Количество и цена
    quantity INTEGER DEFAULT 1,
    price NUMERIC(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RUB',
    
    -- Вес и размеры (опционально)
    weight_kg NUMERIC(10, 3),
    dimensions_length_cm NUMERIC(10, 2),
    dimensions_width_cm NUMERIC(10, 2),
    dimensions_height_cm NUMERIC(10, 2),
    
    -- Совместимость (вариант 3)
    compatible_aircraft_models_text TEXT, -- Для ручного ввода, если самолета нет в каталоге
    
    -- Местоположение
    location VARCHAR(255),
    
    -- Статус объявления
    is_published BOOLEAN DEFAULT FALSE, -- Опубликовано или нет
    is_active BOOLEAN DEFAULT TRUE, -- Активно ли объявление
    published_until TIMESTAMP WITH TIME ZONE, -- Срок действия публикации
    
    -- Статистика
    views_count INTEGER DEFAULT 0,
    favorites_count INTEGER DEFAULT 0,
    
    -- Временные метки
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sold_at TIMESTAMP WITH TIME ZONE
);

-- Индексы для parts_market
CREATE INDEX IF NOT EXISTS idx_parts_market_subcategory_id ON parts_market(parts_subcategory_id);
CREATE INDEX IF NOT EXISTS idx_parts_market_main_category_id ON parts_market(parts_main_category_id);
CREATE INDEX IF NOT EXISTS idx_parts_market_seller_id ON parts_market(seller_id);
CREATE INDEX IF NOT EXISTS idx_parts_market_manufacturer_id ON parts_market(manufacturer_id);
CREATE INDEX IF NOT EXISTS idx_parts_market_is_active ON parts_market(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_parts_market_is_published ON parts_market(is_published) WHERE is_published = TRUE;
CREATE INDEX IF NOT EXISTS idx_parts_market_published_until ON parts_market(published_until) WHERE published_until IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_parts_market_condition ON parts_market(condition);
CREATE INDEX IF NOT EXISTS idx_parts_market_price ON parts_market(price);
CREATE INDEX IF NOT EXISTS idx_parts_market_created_at ON parts_market(created_at DESC);

COMMENT ON TABLE parts_market IS 'Таблица объявлений о продаже запчастей';
COMMENT ON COLUMN parts_market.manufacturer_id IS 'ID производителя из parts_manufacturers';
COMMENT ON COLUMN parts_market.manufacturer_name IS 'Название производителя (для ручного ввода)';
COMMENT ON COLUMN parts_market.compatible_aircraft_models_text IS 'Совместимые модели самолетов (текст, если нет в каталоге)';

-- ============================================
-- 3. ТАБЛИЦА СОВМЕСТИМОСТИ С САМОЛЕТАМИ
-- ============================================

CREATE TABLE IF NOT EXISTS parts_market_aircraft_compatibility (
    part_id INTEGER NOT NULL REFERENCES parts_market(id) ON DELETE CASCADE,
    aircraft_model_id INTEGER NOT NULL REFERENCES aircraft_models(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (part_id, aircraft_model_id)
);

CREATE INDEX IF NOT EXISTS idx_parts_compatibility_part_id ON parts_market_aircraft_compatibility(part_id);
CREATE INDEX IF NOT EXISTS idx_parts_compatibility_aircraft_model_id ON parts_market_aircraft_compatibility(aircraft_model_id);

COMMENT ON TABLE parts_market_aircraft_compatibility IS 'Связь запчастей с моделями самолетов из каталога';

-- ============================================
-- 4. ТАБЛИЦА ИЗБРАННЫХ ЗАПЧАСТЕЙ
-- ============================================

CREATE TABLE IF NOT EXISTS user_favorite_parts_market (
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    part_id INTEGER NOT NULL REFERENCES parts_market(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, part_id)
);

CREATE INDEX IF NOT EXISTS idx_user_favorite_parts_market_user_id ON user_favorite_parts_market(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorite_parts_market_part_id ON user_favorite_parts_market(part_id);

COMMENT ON TABLE user_favorite_parts_market IS 'Таблица избранных запчастей пользователей';

-- ============================================
-- 5. НАСТРОЙКА ПУБЛИКАЦИИ
-- ============================================

-- Создаем таблицу publication_settings, если её нет
CREATE TABLE IF NOT EXISTS publication_settings (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL UNIQUE,
    publication_duration_months INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_publication_settings_table_name ON publication_settings(table_name);

-- Добавляем настройку для parts_market
INSERT INTO publication_settings (table_name, publication_duration_months)
VALUES ('parts_market', 1)
ON CONFLICT (table_name) DO NOTHING;

-- ============================================
-- 6. ЗАПОЛНЕНИЕ ПРОИЗВОДИТЕЛЕЙ
-- ============================================

INSERT INTO parts_manufacturers (name, name_en, country) VALUES
    -- Двигатели
    ('Lycoming', 'Lycoming', 'USA'),
    ('Continental Motors', 'Continental Motors', 'USA'),
    ('Pratt & Whitney', 'Pratt & Whitney', 'USA'),
    ('Rolls-Royce', 'Rolls-Royce', 'UK'),
    ('General Electric Aviation', 'General Electric Aviation', 'USA'),
    ('Safran', 'Safran', 'France'),
    ('Honeywell Aerospace', 'Honeywell Aerospace', 'USA'),
    ('Turbomeca', 'Turbomeca', 'France'),
    ('Williams International', 'Williams International', 'USA'),
    ('Rotax', 'Rotax', 'Austria'),
    ('Jabiru', 'Jabiru', 'Australia'),
    ('ULPower', 'ULPower', 'Belgium'),
    ('Superior Air Parts', 'Superior Air Parts', 'USA'),
    ('TCM', 'TCM', 'USA'),
    
    -- Авионика
    ('Garmin', 'Garmin', 'USA'),
    ('Collins Aerospace', 'Collins Aerospace', 'USA'),
    ('Bendix/King', 'Bendix/King', 'USA'),
    ('Avidyne', 'Avidyne', 'USA'),
    ('Aspen Avionics', 'Aspen Avionics', 'USA'),
    ('Universal Avionics', 'Universal Avionics', 'USA'),
    ('Rockwell Collins', 'Rockwell Collins', 'USA'),
    ('Thales', 'Thales', 'France'),
    ('L3Harris', 'L3Harris', 'USA'),
    ('JPI', 'JPI', 'USA'),
    ('Dynon Avionics', 'Dynon Avionics', 'USA'),
    ('GRT Avionics', 'GRT Avionics', 'USA'),
    ('MGL Avionics', 'MGL Avionics', 'South Africa'),
    ('Trig Avionics', 'Trig Avionics', 'UK'),
    ('PS Engineering', 'PS Engineering', 'USA'),
    ('ICOM', 'ICOM', 'Japan'),
    ('Yaesu', 'Yaesu', 'Japan'),
    ('Becker Avionics', 'Becker Avionics', 'Germany'),
    
    -- Пропеллеры
    ('Hartzell', 'Hartzell', 'USA'),
    ('McCauley', 'McCauley', 'USA'),
    ('Sensenich', 'Sensenich', 'USA'),
    ('MT-Propeller', 'MT-Propeller', 'Germany'),
    ('Whirl Wind', 'Whirl Wind', 'USA'),
    
    -- Шины
    ('Goodyear', 'Goodyear', 'USA'),
    ('Michelin', 'Michelin', 'France'),
    ('Dunlop', 'Dunlop', 'UK'),
    ('Bridgestone', 'Bridgestone', 'Japan'),
    ('Continental', 'Continental', 'Germany'),
    
    -- Гидравлика
    ('Parker Hannifin', 'Parker Hannifin', 'USA'),
    ('Eaton Aerospace', 'Eaton Aerospace', 'USA'),
    ('Liebherr Aerospace', 'Liebherr Aerospace', 'Germany'),
    ('Moog', 'Moog', 'USA'),
    ('Woodward', 'Woodward', 'USA'),
    
    -- Головные гарнитуры
    ('Bose', 'Bose', 'USA'),
    ('David Clark', 'David Clark', 'USA'),
    ('Lightspeed', 'Lightspeed', 'USA'),
    ('Telex', 'Telex', 'USA'),
    ('Flightcom', 'Flightcom', 'USA'),
    ('ASA', 'ASA', 'USA'),
    ('Peltor', 'Peltor', 'Sweden'),
    
    -- Производители самолетов (OEM)
    ('Cessna', 'Cessna', 'USA'),
    ('Piper', 'Piper', 'USA'),
    ('Beechcraft', 'Beechcraft', 'USA'),
    ('Mooney', 'Mooney', 'USA'),
    ('Cirrus', 'Cirrus', 'USA'),
    ('Diamond', 'Diamond', 'Austria'),
    ('Robinson', 'Robinson', 'USA'),
    ('Bell', 'Bell', 'USA'),
    ('Airbus Helicopters', 'Airbus Helicopters', 'France'),
    ('Sikorsky', 'Sikorsky', 'USA'),
    ('Boeing', 'Boeing', 'USA'),
    ('Airbus', 'Airbus', 'France'),
    ('Embraer', 'Embraer', 'Brazil'),
    ('Bombardier', 'Bombardier', 'Canada'),
    ('Gulfstream', 'Gulfstream', 'USA'),
    ('Dassault', 'Dassault', 'France'),
    ('Pilatus', 'Pilatus', 'Switzerland'),
    
    -- Дистрибьюторы
    ('Aircraft Spruce', 'Aircraft Spruce', 'USA'),
    ('Univair', 'Univair', 'USA'),
    ('Wag-Aero', 'Wag-Aero', 'USA'),
    ('Aviall', 'Aviall', 'USA'),
    ('Wesco Aircraft', 'Wesco Aircraft', 'USA'),
    ('AAR', 'AAR', 'USA'),
    ('Triumph Group', 'Triumph Group', 'USA'),
    ('Spirit AeroSystems', 'Spirit AeroSystems', 'USA'),
    ('TransDigm', 'TransDigm', 'USA'),
    ('HEICO', 'HEICO', 'USA'),
    
    -- Российские производители
    ('Авиадвигатель', 'Aviadvigatel', 'Russia'),
    ('Пермские моторы', 'Perm Motors', 'Russia'),
    ('Климов', 'Klimov', 'Russia'),
    ('Сатурн', 'Saturn', 'Russia'),
    ('НПО Сатурн', 'NPO Saturn', 'Russia'),
    ('УМПО', 'UMPO', 'Russia'),
    ('Авиаагрегат', 'Aviaagregat', 'Russia'),
    ('Авиаприбор', 'Aviapribor', 'Russia'),
    ('Авиаавтоматика', 'Aviaavtomatika', 'Russia'),
    ('Радиоавионика', 'Radioavionika', 'Russia'),
    ('Аэросила', 'Aerosila', 'Russia'),
    ('Туполев', 'Tupolev', 'Russia'),
    ('Сухой', 'Sukhoi', 'Russia'),
    ('Ильюшин', 'Ilyushin', 'Russia'),
    ('Антонов', 'Antonov', 'Ukraine'),
    ('Миль', 'Mil', 'Russia'),
    ('Камов', 'Kamov', 'Russia'),
    ('Рыбинские моторы', 'Rybinsk Motors', 'Russia'),
    ('Мотор Сич', 'Motor Sich', 'Ukraine'),
    ('Прогресс', 'Progress', 'Ukraine'),
    
    -- Другие компоненты
    ('Amphenol', 'Amphenol', 'USA'),
    ('TE Connectivity', 'TE Connectivity', 'Switzerland'),
    ('ITT Cannon', 'ITT Cannon', 'USA'),
    ('Souriau', 'Souriau', 'France'),
    ('Radiall', 'Radiall', 'France'),
    ('Crane Aerospace', 'Crane Aerospace', 'USA'),
    ('Zodiac Aerospace', 'Zodiac Aerospace', 'France'),
    ('Safran Landing Systems', 'Safran Landing Systems', 'France'),
    ('Raytheon Technologies', 'Raytheon Technologies', 'USA')
ON CONFLICT (name) DO NOTHING;
