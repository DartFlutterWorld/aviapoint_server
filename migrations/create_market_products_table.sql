-- Миграция для создания таблицы market_products

BEGIN;

-- Таблица продуктов маркета (самолёты)
CREATE TABLE IF NOT EXISTS market_products (
    id SERIAL PRIMARY KEY,
    seller_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    aircraft_subcategories_id INTEGER REFERENCES aircraft_subcategories(id) ON DELETE SET NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    
    -- Изображения
    main_image_url VARCHAR(512),                    -- Основное фото
    additional_image_urls JSONB DEFAULT '[]'::jsonb, -- Дополнительные фото (массив URL)
    
    brand VARCHAR(255),
    location VARCHAR(255),
    location_type VARCHAR(50),                      -- 'airport', 'city', 'region'
    
    -- Характеристики самолёта
    year INTEGER,
    flight_hours NUMERIC(10, 2),
    seats INTEGER,
    condition VARCHAR(50),                          -- 'new', 'used', 'restored'
    
    is_active BOOLEAN DEFAULT TRUE,
    views_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индекс для быстрого поиска по категории
CREATE INDEX IF NOT EXISTS idx_market_products_aircraft_subcategories_id ON market_products(aircraft_subcategories_id);

-- Индекс для быстрого поиска по продавцу
CREATE INDEX IF NOT EXISTS idx_market_products_seller_id ON market_products(seller_id);

-- Индекс для быстрого поиска активных продуктов
CREATE INDEX IF NOT EXISTS idx_market_products_is_active ON market_products(is_active);

-- Таблица для избранных продуктов пользователя
CREATE TABLE IF NOT EXISTS user_favorite_products (
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES market_products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, product_id)
);

-- Индекс для быстрого поиска избранных продуктов
CREATE INDEX IF NOT EXISTS idx_user_favorite_products_user_id ON user_favorite_products(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorite_products_product_id ON user_favorite_products(product_id);

COMMIT;
