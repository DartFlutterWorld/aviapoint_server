-- Миграция 076: Создание таблицы для объявлений о продаже запчастей
-- Таблица parts_market для размещения объявлений о продаже запчастей

-- ============================================
-- СОЗДАНИЕ ТАБЛИЦЫ
-- ============================================

CREATE TABLE IF NOT EXISTS parts_market (
    id SERIAL PRIMARY KEY,
    
    -- Связи
    seller_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    parts_subcategory_id INTEGER REFERENCES parts_subcategories(id) ON DELETE SET NULL,
    parts_main_category_id INTEGER REFERENCES parts_main_categories(id) ON DELETE SET NULL,
    
    -- Основная информация
    title VARCHAR(500) NOT NULL,
    description TEXT,
    
    -- Цена и валюта
    price NUMERIC(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RUB', -- RUB, USD, EUR
    
    -- Изображения
    main_image_url VARCHAR(512),
    additional_image_urls JSONB DEFAULT '[]'::jsonb,
    
    -- Информация о запчасти
    part_number VARCHAR(255), -- Номер запчасти (артикул производителя)
    manufacturer VARCHAR(255), -- Производитель запчасти
    oem_number VARCHAR(255), -- OEM номер (оригинальный номер производителя)
    
    -- Совместимость
    compatible_aircraft_models TEXT[], -- Массив моделей самолетов (например: ['Cessna 172', 'Cessna 182'])
    compatible_aircraft_manufacturers TEXT[], -- Массив производителей самолетов
    
    -- Состояние запчасти
    condition VARCHAR(50) DEFAULT 'used', -- 'new' (новое), 'used' (б/у), 'refurbished' (восстановленное), 'damaged' (поврежденное)
    
    -- Количество и наличие
    quantity INTEGER DEFAULT 1, -- Количество запчастей в наличии
    is_available BOOLEAN DEFAULT TRUE, -- Доступна ли запчасть для продажи
    
    -- Местоположение
    location VARCHAR(255), -- Город/регион
    location_type VARCHAR(50), -- 'airport', 'city', 'region', 'warehouse'
    
    -- Дополнительная информация
    serial_number VARCHAR(255), -- Серийный номер (если есть)
    certification_status VARCHAR(100), -- Статус сертификации (например: 'certified', 'uncertified')
    warranty_period_months INTEGER, -- Гарантийный период в месяцах
    notes TEXT, -- Дополнительные примечания
    
    -- Статус и публикация
    is_active BOOLEAN DEFAULT TRUE,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'sold', 'archived', 'moderation'
    published_until TIMESTAMP WITH TIME ZONE, -- Срок действия публикации
    
    -- Статистика
    views_count INTEGER DEFAULT 0,
    favorites_count INTEGER DEFAULT 0,
    
    -- Временные метки
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sold_at TIMESTAMP WITH TIME ZONE -- Дата продажи (если продано)
);

-- ============================================
-- ИНДЕКСЫ ДЛЯ БЫСТРОГО ПОИСКА
-- ============================================

-- Индекс для поиска по категории запчасти
CREATE INDEX IF NOT EXISTS idx_parts_market_subcategory_id 
ON parts_market(parts_subcategory_id);

-- Индекс для поиска по основной категории
CREATE INDEX IF NOT EXISTS idx_parts_market_main_category_id 
ON parts_market(parts_main_category_id);

-- Индекс для поиска по продавцу
CREATE INDEX IF NOT EXISTS idx_parts_market_seller_id 
ON parts_market(seller_id);

-- Индекс для поиска активных объявлений
CREATE INDEX IF NOT EXISTS idx_parts_market_is_active 
ON parts_market(is_active) WHERE is_active = TRUE;

-- Индекс для поиска по статусу
CREATE INDEX IF NOT EXISTS idx_parts_market_status 
ON parts_market(status) WHERE status = 'active';

-- Индекс для поиска по состоянию запчасти
CREATE INDEX IF NOT EXISTS idx_parts_market_condition 
ON parts_market(condition);

-- Индекс для поиска по производителю
CREATE INDEX IF NOT EXISTS idx_parts_market_manufacturer 
ON parts_market(manufacturer) WHERE manufacturer IS NOT NULL;

-- Индекс для поиска по номеру запчасти
CREATE INDEX IF NOT EXISTS idx_parts_market_part_number 
ON parts_market(part_number) WHERE part_number IS NOT NULL;

-- Индекс для поиска по цене (для сортировки)
CREATE INDEX IF NOT EXISTS idx_parts_market_price 
ON parts_market(price);

-- Индекс для поиска по местоположению
CREATE INDEX IF NOT EXISTS idx_parts_market_location 
ON parts_market(location) WHERE location IS NOT NULL;

-- Индекс для полнотекстового поиска по названию и описанию
CREATE INDEX IF NOT EXISTS idx_parts_market_title_description 
ON parts_market USING gin(to_tsvector('russian', coalesce(title, '') || ' ' || coalesce(description, '')));

-- Индекс для поиска по дате создания (для сортировки новых)
CREATE INDEX IF NOT EXISTS idx_parts_market_created_at 
ON parts_market(created_at DESC);

-- Индекс для поиска по сроку публикации
CREATE INDEX IF NOT EXISTS idx_parts_market_published_until 
ON parts_market(published_until) WHERE published_until IS NOT NULL;

-- ============================================
-- КОММЕНТАРИИ К ПОЛЯМ
-- ============================================

COMMENT ON TABLE parts_market IS 'Таблица объявлений о продаже запчастей';
COMMENT ON COLUMN parts_market.seller_id IS 'ID продавца (пользователя)';
COMMENT ON COLUMN parts_market.parts_subcategory_id IS 'ID подкатегории запчасти';
COMMENT ON COLUMN parts_market.parts_main_category_id IS 'ID основной категории (для быстрого поиска)';
COMMENT ON COLUMN parts_market.title IS 'Название объявления';
COMMENT ON COLUMN parts_market.description IS 'Подробное описание запчасти';
COMMENT ON COLUMN parts_market.price IS 'Цена запчасти';
COMMENT ON COLUMN parts_market.currency IS 'Валюта (RUB, USD, EUR)';
COMMENT ON COLUMN parts_market.part_number IS 'Номер запчасти (артикул производителя)';
COMMENT ON COLUMN parts_market.manufacturer IS 'Производитель запчасти';
COMMENT ON COLUMN parts_market.oem_number IS 'OEM номер (оригинальный номер производителя)';
COMMENT ON COLUMN parts_market.compatible_aircraft_models IS 'Массив совместимых моделей самолетов';
COMMENT ON COLUMN parts_market.compatible_aircraft_manufacturers IS 'Массив совместимых производителей самолетов';
COMMENT ON COLUMN parts_market.condition IS 'Состояние: new, used, refurbished, damaged';
COMMENT ON COLUMN parts_market.quantity IS 'Количество запчастей в наличии';
COMMENT ON COLUMN parts_market.is_available IS 'Доступна ли запчасть для продажи';
COMMENT ON COLUMN parts_market.location IS 'Местоположение продавца';
COMMENT ON COLUMN parts_market.serial_number IS 'Серийный номер запчасти';
COMMENT ON COLUMN parts_market.certification_status IS 'Статус сертификации';
COMMENT ON COLUMN parts_market.warranty_period_months IS 'Гарантийный период в месяцах';
COMMENT ON COLUMN parts_market.status IS 'Статус объявления: active, sold, archived, moderation';
COMMENT ON COLUMN parts_market.published_until IS 'Срок действия публикации';
