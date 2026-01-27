-- Миграция для синхронизации всех таблиц и полей между локальной и удаленной БД
-- Эта миграция создает все недостающие таблицы и добавляет все недостающие поля
-- Идемпотентна - можно запускать несколько раз

BEGIN;

-- ============================================
-- 1. ОСНОВНЫЕ ТАБЛИЦЫ ПРИЛОЖЕНИЯ
-- ============================================

-- Таблица profiles (если не существует, создается базовой структурой)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN
        CREATE TABLE profiles (
            id SERIAL PRIMARY KEY,
            phone VARCHAR(20) UNIQUE,
            email VARCHAR(255),
            first_name VARCHAR(100),
            last_name VARCHAR(100),
            avatar_url VARCHAR(512),
            telegram VARCHAR(100),
            max_rating INTEGER,
            created_at TIMESTAMP DEFAULT NOW(),
            updated_at TIMESTAMP DEFAULT NOW()
        );
    END IF;
END $$;

-- Добавляем недостающие поля в profiles
DO $$ 
BEGIN
    -- is_admin
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'is_admin') THEN
        ALTER TABLE profiles ADD COLUMN is_admin BOOLEAN DEFAULT FALSE NOT NULL;
        CREATE INDEX IF NOT EXISTS idx_profiles_is_admin ON profiles(is_admin) WHERE is_admin = true;
    END IF;
END $$;

-- Таблица payments
CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(255) PRIMARY KEY,
    status VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'RUB',
    description TEXT,
    payment_url TEXT,
    created_at TIMESTAMP NOT NULL,
    paid BOOLEAN NOT NULL DEFAULT false,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL,
    subscription_type VARCHAR(50) NOT NULL,
    period_days INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);

-- Таблица subscription_types
CREATE TABLE IF NOT EXISTS subscription_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    period_days INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    payment_id VARCHAR(255) REFERENCES payments(id) ON DELETE SET NULL,
    subscription_type_id INTEGER REFERENCES subscription_types(id),
    period_days INTEGER NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true,
    auto_renew BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_payment_id ON subscriptions(payment_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_end_date ON subscriptions(end_date);
-- CREATE INDEX IF NOT EXISTS idx_subscriptions_is_active ON subscriptions(is_active); -- Отключено: поле is_active не используется

-- Таблица schema_migrations
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    executed_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 2. ТАБЛИЦЫ САМОЛЕТОВ (AIRCRAFT)
-- ============================================

-- Таблица aircraft_main_categories
CREATE TABLE IF NOT EXISTS aircraft_main_categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT NOT NULL
);

-- Таблица aircraft_subcategories
CREATE TABLE IF NOT EXISTS aircraft_subcategories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT NOT NULL,
    main_categories_id INTEGER NOT NULL REFERENCES aircraft_main_categories(id) ON DELETE CASCADE,
    icon TEXT NOT NULL
);

-- Добавляем недостающие поля, если таблица уже существует
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'aircraft_subcategories') THEN
        -- Добавляем main_categories_id, если его нет (для совместимости со старыми версиями)
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'aircraft_subcategories' AND column_name = 'main_categories_id') THEN
            ALTER TABLE aircraft_subcategories ADD COLUMN main_categories_id INTEGER REFERENCES aircraft_main_categories(id) ON DELETE CASCADE;
        END IF;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_aircraft_subcategories_main_categories_id ON aircraft_subcategories(main_categories_id);

-- Таблица aircraft_manufacturers
CREATE TABLE IF NOT EXISTS aircraft_manufacturers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    country VARCHAR(100),
    website VARCHAR(255),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_aircraft_manufacturers_name ON aircraft_manufacturers(name);
-- CREATE INDEX IF NOT EXISTS idx_aircraft_manufacturers_active ON aircraft_manufacturers(is_active); -- Отключено: поле is_active не используется

-- Таблица aircraft_models
CREATE TABLE IF NOT EXISTS aircraft_models (
    id SERIAL PRIMARY KEY,
    manufacturer_id INTEGER NOT NULL REFERENCES aircraft_manufacturers(id) ON DELETE CASCADE,
    model_code VARCHAR(100) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    -- category VARCHAR(50), -- Отключено: поле не используется
    -- engine_type VARCHAR(50), -- Отключено: поле не используется
    -- engine_count INTEGER DEFAULT 1, -- Отключено: поле не используется
    -- is_active BOOLEAN DEFAULT true, -- Отключено: поле не используется
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(manufacturer_id, model_code)
);

CREATE INDEX IF NOT EXISTS idx_aircraft_models_manufacturer ON aircraft_models(manufacturer_id);
-- CREATE INDEX IF NOT EXISTS idx_aircraft_models_category ON aircraft_models(category); -- Отключено: поле category не используется

-- Таблица aircraft_model_specs
CREATE TABLE IF NOT EXISTS aircraft_model_specs (
    id SERIAL PRIMARY KEY,
    aircraft_model_id INTEGER NOT NULL REFERENCES aircraft_models(id) ON DELETE CASCADE,
    max_speed INTEGER,
    cruise_speed INTEGER,
    range INTEGER,
    ceiling INTEGER,
    empty_weight INTEGER,
    max_takeoff_weight INTEGER,
    fuel_capacity INTEGER,
    seats INTEGER,
    engine_power INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_aircraft_model_specs_model ON aircraft_model_specs(aircraft_model_id);

-- ============================================
-- 3. РЫНОК САМОЛЕТОВ (MARKET)
-- ============================================

-- Таблица aircraft_market (создается из market_products или создается заново)
DO $$ 
BEGIN
    -- Если существует market_products, переименовываем её
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'market_products') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'aircraft_market') THEN
        ALTER TABLE market_products RENAME TO aircraft_market;
    END IF;
    
    -- Если таблицы нет, создаем её
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'aircraft_market') THEN
        CREATE TABLE aircraft_market (
            id SERIAL PRIMARY KEY,
            seller_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
            aircraft_subcategories_id INTEGER REFERENCES aircraft_subcategories(id) ON DELETE SET NULL,
            title VARCHAR(500) NOT NULL,
            description TEXT,
            price INTEGER NOT NULL,
            main_image_url VARCHAR(512),
            additional_image_urls JSONB DEFAULT '[]'::jsonb,
            brand VARCHAR(255),
            location VARCHAR(255),
            location_type VARCHAR(50),
            year INTEGER,
            total_flight_hours INTEGER,
            engine_power INTEGER,
            engine_volume INTEGER,
            seats INTEGER,
            condition VARCHAR(50),
            is_share_sale BOOLEAN DEFAULT FALSE,
            share_numerator INTEGER,
            share_denominator INTEGER,
            is_leasing BOOLEAN DEFAULT FALSE,
            is_active BOOLEAN DEFAULT TRUE,
            published_until TIMESTAMP WITH TIME ZONE,
            views_count INTEGER DEFAULT 0,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END $$;

-- Добавляем недостающие поля в aircraft_market
DO $$ 
BEGIN
    -- published_until
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'aircraft_market' AND column_name = 'published_until') THEN
        ALTER TABLE aircraft_market ADD COLUMN published_until TIMESTAMP WITH TIME ZONE;
        ALTER TABLE aircraft_market ALTER COLUMN published_until SET DEFAULT (NOW() + INTERVAL '1 month');
    END IF;
    
    -- is_leasing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'aircraft_market' AND column_name = 'is_leasing') THEN
        ALTER TABLE aircraft_market ADD COLUMN is_leasing BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- Исправляем типы полей, если нужно
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'aircraft_market' AND column_name = 'price' AND data_type = 'numeric') THEN
        ALTER TABLE aircraft_market ALTER COLUMN price TYPE INTEGER USING price::INTEGER;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'aircraft_market' AND column_name = 'flight_hours') THEN
        ALTER TABLE aircraft_market RENAME COLUMN flight_hours TO total_flight_hours;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'aircraft_market' AND column_name = 'total_flight_hours' AND data_type = 'numeric') THEN
        ALTER TABLE aircraft_market ALTER COLUMN total_flight_hours TYPE INTEGER USING total_flight_hours::INTEGER;
    END IF;
END $$;

-- Индексы для aircraft_market
CREATE INDEX IF NOT EXISTS idx_aircraft_market_aircraft_subcategories_id ON aircraft_market(aircraft_subcategories_id);
CREATE INDEX IF NOT EXISTS idx_aircraft_market_seller_id ON aircraft_market(seller_id);
-- CREATE INDEX IF NOT EXISTS idx_aircraft_market_is_active ON aircraft_market(is_active); -- Отключено: поле is_active не используется
CREATE INDEX IF NOT EXISTS idx_aircraft_market_published_until ON aircraft_market(published_until);

-- Таблица aircraft_market_price_history
CREATE TABLE IF NOT EXISTS aircraft_market_price_history (
    id SERIAL PRIMARY KEY,
    aircraft_market_id INTEGER NOT NULL REFERENCES aircraft_market(id) ON DELETE CASCADE,
    price INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_aircraft_market_price_history_aircraft_market_id ON aircraft_market_price_history(aircraft_market_id);
CREATE INDEX IF NOT EXISTS idx_aircraft_market_price_history_created_at ON aircraft_market_price_history(created_at DESC);

-- Таблица user_favorite_aircraft_market
CREATE TABLE IF NOT EXISTS user_favorite_aircraft_market (
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES aircraft_market(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_user_favorite_aircraft_market_user_id ON user_favorite_aircraft_market(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorite_aircraft_market_product_id ON user_favorite_aircraft_market(product_id);

-- Таблица publication_settings
CREATE TABLE IF NOT EXISTS publication_settings (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL UNIQUE,
    publication_duration_months INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_publication_settings_table_name ON publication_settings(table_name);

INSERT INTO publication_settings (table_name, publication_duration_months)
VALUES ('aircraft_market', 1)
ON CONFLICT (table_name) DO NOTHING;

-- ============================================
-- 4. АЭРОПОРТЫ (AIRPORTS)
-- ============================================

-- Таблица airports
CREATE TABLE IF NOT EXISTS airports (
    id SERIAL PRIMARY KEY,
    is_active BOOLEAN DEFAULT TRUE,
    type VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    name_eng VARCHAR(255),
    city VARCHAR(255),
    ident VARCHAR(10) UNIQUE NOT NULL,
    ident_ru VARCHAR(10), -- Код аэродрома из АОПА (например, НЕЕ1)
    country_code VARCHAR(20),
    country VARCHAR(100),
    country_eng VARCHAR(100),
    region VARCHAR(255),
    region_eng VARCHAR(255),
    coordinates_text VARCHAR(100),
    longitude_deg DECIMAL(10, 7) NOT NULL,
    latitude_deg DECIMAL(10, 7) NOT NULL,
    elevation_ft INTEGER,
    ownership VARCHAR(100),
    is_international BOOLEAN DEFAULT FALSE,
    email VARCHAR(255),
    website VARCHAR(255),
    notes TEXT,
    runway_name VARCHAR(255),
    runway_length INTEGER,
    runway_width INTEGER,
    runway_surface VARCHAR(100),
    runway_magnetic_course VARCHAR(50),
    runway_lighting VARCHAR(50),
    services JSONB DEFAULT '{}',
    owner_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    source VARCHAR(50) DEFAULT 'aopa', -- Источник данных (aopa, manual, etc.)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    visitor_photos JSONB DEFAULT '[]', -- Массив URL фотографий, добавленных посетителями аэропорта
    photos JSONB DEFAULT '[]', -- Массив URL фотографий аэродрома
    CHECK (latitude_deg >= -90 AND latitude_deg <= 90),
    CHECK (longitude_deg >= -180 AND longitude_deg <= 180)
);

CREATE INDEX IF NOT EXISTS idx_airports_ident ON airports(ident);
CREATE INDEX IF NOT EXISTS idx_airports_type ON airports(type);
CREATE INDEX IF NOT EXISTS idx_airports_name ON airports(name);
CREATE INDEX IF NOT EXISTS idx_airports_is_active ON airports(is_active);
-- Индексы с условиями (только для не-NULL значений)
-- CREATE INDEX IF NOT EXISTS idx_airports_country_code ON airports(country_code) WHERE country_code IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_airports_city ON airports(city) WHERE city IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_airports_region ON airports(region) WHERE region IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_airports_ident_ru ON airports(ident_ru) WHERE ident_ru IS NOT NULL;
-- GIN индекс для photos (только если есть данные)
-- CREATE INDEX IF NOT EXISTS idx_airports_photos ON airports USING gin(photos) WHERE photos IS NOT NULL AND jsonb_array_length(photos) > 0;

-- Таблица airport_reviews
CREATE TABLE IF NOT EXISTS airport_reviews (
    id SERIAL PRIMARY KEY,
    airport_code VARCHAR(10) NOT NULL REFERENCES airports(ident) ON DELETE CASCADE,
    reviewer_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    photo_urls JSONB,
    reply_to_review_id INTEGER REFERENCES airport_reviews(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_airport_reviews_airport_code ON airport_reviews(airport_code);
CREATE INDEX IF NOT EXISTS idx_airport_reviews_reviewer_id ON airport_reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_airport_reviews_reply_to_review_id ON airport_reviews(reply_to_review_id);
CREATE INDEX IF NOT EXISTS idx_airport_reviews_created_at ON airport_reviews(created_at DESC);

-- Таблица airport_feedback
CREATE TABLE IF NOT EXISTS airport_feedback (
    id SERIAL PRIMARY KEY,
    airport_code VARCHAR(10) NOT NULL REFERENCES airports(ident) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    feedback_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_airport_feedback_airport_code ON airport_feedback(airport_code);
CREATE INDEX IF NOT EXISTS idx_airport_feedback_user_id ON airport_feedback(user_id);

-- Таблица airport_ownership_requests
CREATE TABLE IF NOT EXISTS airport_ownership_requests (
    id SERIAL PRIMARY KEY,
    airport_code VARCHAR(10) NOT NULL REFERENCES airports(ident) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    phone VARCHAR(20),
    full_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_airport_ownership_requests_airport_code ON airport_ownership_requests(airport_code);
CREATE INDEX IF NOT EXISTS idx_airport_ownership_requests_user_id ON airport_ownership_requests(user_id);

-- Таблица airport_visitor_photos
CREATE TABLE IF NOT EXISTS airport_visitor_photos (
    id SERIAL PRIMARY KEY,
    airport_code VARCHAR(10) NOT NULL REFERENCES airports(ident) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    photo_url VARCHAR(512) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_airport_visitor_photos_airport_code ON airport_visitor_photos(airport_code);
CREATE INDEX IF NOT EXISTS idx_airport_visitor_photos_user_id ON airport_visitor_photos(user_id);

-- ============================================
-- 5. ПОЛЕТЫ (FLIGHTS)
-- ============================================

-- Таблица flights
CREATE TABLE IF NOT EXISTS flights (
    id SERIAL PRIMARY KEY,
    pilot_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    departure_airport VARCHAR(255) NOT NULL,
    arrival_airport VARCHAR(255) NOT NULL,
    departure_date TIMESTAMP NOT NULL,
    available_seats INTEGER NOT NULL CHECK (available_seats > 0),
    price_per_seat DECIMAL(10, 2) NOT NULL CHECK (price_per_seat >= 0),
    aircraft_type VARCHAR(100),
    description TEXT,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_flights_departure_date ON flights(departure_date);
CREATE INDEX IF NOT EXISTS idx_flights_departure_airport ON flights(departure_airport);
CREATE INDEX IF NOT EXISTS idx_flights_arrival_airport ON flights(arrival_airport);
CREATE INDEX IF NOT EXISTS idx_flights_pilot_id ON flights(pilot_id);
CREATE INDEX IF NOT EXISTS idx_flights_status ON flights(status);

-- Таблица bookings
CREATE TABLE IF NOT EXISTS bookings (
    id SERIAL PRIMARY KEY,
    flight_id INTEGER NOT NULL REFERENCES flights(id) ON DELETE CASCADE,
    passenger_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    seats_count INTEGER NOT NULL CHECK (seats_count > 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookings_flight_id ON bookings(flight_id);
CREATE INDEX IF NOT EXISTS idx_bookings_passenger_id ON bookings(passenger_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);

-- Таблица reviews
CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    reviewer_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    reviewed_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    rating INTEGER,
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reviews_reviewed_id ON reviews(reviewed_id);
CREATE INDEX IF NOT EXISTS idx_reviews_booking_id ON reviews(booking_id);

-- Таблица flight_waypoints
CREATE TABLE IF NOT EXISTS flight_waypoints (
    id SERIAL PRIMARY KEY,
    flight_id INTEGER NOT NULL REFERENCES flights(id) ON DELETE CASCADE,
    waypoint_order INTEGER NOT NULL,
    airport_code VARCHAR(10),
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_flight_waypoints_flight_id ON flight_waypoints(flight_id);

-- Таблица flight_photos
CREATE TABLE IF NOT EXISTS flight_photos (
    id SERIAL PRIMARY KEY,
    flight_id INTEGER NOT NULL REFERENCES flights(id) ON DELETE CASCADE,
    photo_url VARCHAR(512) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_flight_photos_flight_id ON flight_photos(flight_id);

-- Таблица flight_questions
CREATE TABLE IF NOT EXISTS flight_questions (
    id SERIAL PRIMARY KEY,
    flight_id INTEGER NOT NULL REFERENCES flights(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT,
    answered_by INTEGER REFERENCES profiles(id),
    created_at TIMESTAMP DEFAULT NOW(),
    answered_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_flight_questions_flight_id ON flight_questions(flight_id);
CREATE INDEX IF NOT EXISTS idx_flight_questions_user_id ON flight_questions(user_id);

-- ============================================
-- 6. БЛОГ (BLOG)
-- ============================================

-- Таблица blog_categories
CREATE TABLE IF NOT EXISTS blog_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(512),
    color VARCHAR(7) DEFAULT '#0A6EFA',
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица blog_articles
CREATE TABLE IF NOT EXISTS blog_articles (
    id SERIAL PRIMARY KEY,
    author_id INTEGER NOT NULL REFERENCES profiles(id),
    category_id INTEGER REFERENCES blog_categories(id) ON DELETE SET NULL,
    aircraft_model_id INTEGER REFERENCES aircraft_models(id) ON DELETE SET NULL,
    title VARCHAR(500) NOT NULL,
    excerpt TEXT,
    content TEXT NOT NULL,
    cover_image_url VARCHAR(512),
    status VARCHAR(50) DEFAULT 'draft',
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_blog_articles_category ON blog_articles(category_id);
CREATE INDEX IF NOT EXISTS idx_blog_articles_aircraft ON blog_articles(aircraft_model_id);
CREATE INDEX IF NOT EXISTS idx_blog_articles_status ON blog_articles(status);
CREATE INDEX IF NOT EXISTS idx_blog_articles_published ON blog_articles(published_at DESC);

-- Таблица blog_tags
CREATE TABLE IF NOT EXISTS blog_tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица blog_article_tags
CREATE TABLE IF NOT EXISTS blog_article_tags (
    article_id INTEGER NOT NULL REFERENCES blog_articles(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES blog_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (article_id, tag_id)
);

-- Таблица blog_comments
CREATE TABLE IF NOT EXISTS blog_comments (
    id SERIAL PRIMARY KEY,
    article_id INTEGER NOT NULL REFERENCES blog_articles(id) ON DELETE CASCADE,
    author_id INTEGER NOT NULL REFERENCES profiles(id),
    parent_comment_id INTEGER REFERENCES blog_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_blog_comments_article ON blog_comments(article_id);
CREATE INDEX IF NOT EXISTS idx_blog_comments_author ON blog_comments(author_id);
CREATE INDEX IF NOT EXISTS idx_blog_comments_parent ON blog_comments(parent_comment_id);

-- ============================================
-- 7. НОВОСТИ (NEWS)
-- ============================================

-- Таблица news уже существует на сервере, только добавляем недостающие поля и исправляем структуру
DO $$ 
DECLARE
    duplicate_count INTEGER;
    max_id_val INTEGER;
BEGIN
    -- Проверяем, существует ли таблица news
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'news') THEN
        -- Убеждаемся, что колонка id имеет NOT NULL
        IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'news' 
            AND column_name = 'id' 
            AND is_nullable = 'YES'
        ) THEN
            ALTER TABLE news ALTER COLUMN id SET NOT NULL;
        END IF;
        
        -- Проверяем наличие дубликатов в id
        SELECT COUNT(*) INTO duplicate_count
        FROM (
            SELECT id, COUNT(*) as cnt
            FROM news
            GROUP BY id
            HAVING COUNT(*) > 1
        ) duplicates;
        
        -- Если есть дубликаты, исправляем их
        IF duplicate_count > 0 THEN
            -- Получаем максимальный id ДО использования в UPDATE
            SELECT COALESCE(MAX(id), 0) INTO max_id_val FROM news;
            
            -- Исправляем дубликаты, перенумеровывая их
            UPDATE news n1
            SET id = subquery.new_id
            FROM (
                SELECT ctid,
                       max_id_val + 
                       ROW_NUMBER() OVER (ORDER BY ctid) as new_id
                FROM (
                    SELECT ctid, 
                           ROW_NUMBER() OVER (PARTITION BY id ORDER BY ctid) as rn
                    FROM news
                ) numbered
                WHERE numbered.rn > 1
            ) subquery
            WHERE n1.ctid = subquery.ctid;
            
            -- Обновляем sequence, если он существует
            IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'news_id_seq') THEN
                -- Получаем новый максимальный id после обновления
                SELECT COALESCE(MAX(id), 0) INTO max_id_val FROM news;
                PERFORM setval('news_id_seq', GREATEST(max_id_val, 1), false);
            END IF;
        END IF;
        
        -- Создаем PRIMARY KEY, если его еще нет
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint 
            WHERE conrelid = 'news'::regclass 
            AND contype = 'p'
        ) THEN
            ALTER TABLE news ADD CONSTRAINT news_pkey PRIMARY KEY (id);
        END IF;
    END IF;
END $$;

-- Добавляем недостающие поля в news (только если таблица существует)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'news') THEN
        -- author_id
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'news' AND column_name = 'author_id') THEN
            ALTER TABLE news ADD COLUMN author_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL;
            CREATE INDEX IF NOT EXISTS idx_news_author_id ON news(author_id);
        END IF;
        
        -- published
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'news' AND column_name = 'published') THEN
            ALTER TABLE news ADD COLUMN published BOOLEAN DEFAULT TRUE;
            UPDATE news SET published = TRUE WHERE published IS NULL;
            ALTER TABLE news ALTER COLUMN published SET NOT NULL;
            ALTER TABLE news ALTER COLUMN published SET DEFAULT FALSE;
            CREATE INDEX IF NOT EXISTS idx_news_published ON news(published);
        END IF;
        
        -- content
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'news' AND column_name = 'content') THEN
            ALTER TABLE news ADD COLUMN content TEXT;
        END IF;
    END IF;
END $$;

-- Создаем sequence для news.id, если его еще нет (только если таблица существует)
DO $$ 
DECLARE
    max_id_val INTEGER;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'news') THEN
        -- Получаем максимальный id из таблицы news
        SELECT COALESCE(MAX(id), 0) INTO max_id_val FROM news;
        
        IF NOT EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'news_id_seq') THEN
            CREATE SEQUENCE news_id_seq;
            PERFORM setval('news_id_seq', GREATEST(max_id_val, 1), false);
            ALTER TABLE news ALTER COLUMN id SET DEFAULT nextval('news_id_seq');
            ALTER SEQUENCE news_id_seq OWNED BY news.id;
        ELSE
            PERFORM setval('news_id_seq', GREATEST(max_id_val, 1), false);
        END IF;
    END IF;
END $$;

-- Таблица news_images
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'news_images'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'news_images' 
        AND constraint_type = 'FOREIGN KEY'
        AND constraint_name LIKE '%news_id%'
    ) THEN
        DROP TABLE IF EXISTS news_images CASCADE;
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS news_images (
    id SERIAL PRIMARY KEY,
    news_id INTEGER NOT NULL REFERENCES news(id) ON DELETE CASCADE,
    image_url VARCHAR(512) NOT NULL,
    image_path VARCHAR(512) NOT NULL,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_news_images_news_id ON news_images(news_id);
CREATE INDEX IF NOT EXISTS idx_news_images_order_index ON news_images(news_id, order_index);

-- Таблица category_news
CREATE TABLE IF NOT EXISTS category_news (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 8. НАСТРОЙКИ И ДРУГИЕ
-- ============================================

-- Таблица app_settings
CREATE TABLE IF NOT EXISTS app_settings (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) NOT NULL UNIQUE,
    value BOOLEAN NOT NULL DEFAULT true,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_settings_key ON app_settings(key);

-- Таблица user_fcm_tokens (fcm_tokens)
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    fcm_token VARCHAR(512) NOT NULL,
    platform VARCHAR(20) NOT NULL DEFAULT 'mobile',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, fcm_token)
);

CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_platform ON user_fcm_tokens(platform);
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_token ON user_fcm_tokens(fcm_token) WHERE fcm_token IS NOT NULL;

-- Таблица feedback
CREATE TABLE IF NOT EXISTS feedback (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON feedback(user_id);

-- Таблица stories
CREATE TABLE IF NOT EXISTS stories (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content_url VARCHAR(512) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stories_user_id ON stories(user_id);

-- Таблица video
CREATE TABLE IF NOT EXISTS video (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    video_url VARCHAR(512) NOT NULL,
    thumbnail_url VARCHAR(512),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 9. СПРАВОЧНИКИ И ТЕСТЫ
-- ============================================

-- Таблицы справочников (создаются базовой структурой, если не существуют)
CREATE TABLE IF NOT EXISTS normal_categories (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    main_category_id INTEGER NOT NULL,
    title_eng VARCHAR(255) NOT NULL,
    picture VARCHAR(512) NOT NULL,
    sub_title VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS normal_check_list (
    id SERIAL PRIMARY KEY,
    normal_category_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    doing TEXT NOT NULL,
    picture VARCHAR(512) NOT NULL,
    title_eng VARCHAR(255) NOT NULL,
    doing_eng TEXT NOT NULL,
    check_list BOOLEAN NOT NULL,
    sub_category VARCHAR(255),
    sub_category_eng VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS preflight_inspection_categories (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    title_eng VARCHAR(255) NOT NULL,
    picture VARCHAR(512) NOT NULL
);

CREATE TABLE IF NOT EXISTS preflight_inspection_check_list (
    id SERIAL PRIMARY KEY,
    preflight_inspection_category_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    doing TEXT NOT NULL,
    picture VARCHAR(512) NOT NULL,
    title_eng VARCHAR(255) NOT NULL,
    doing_eng TEXT NOT NULL,
    check_list BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS emergency_categories (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    title_eng VARCHAR(255) NOT NULL,
    picture VARCHAR(512) NOT NULL
);

CREATE TABLE IF NOT EXISTS airspeeds_for_emergency_operations (
    id SERIAL PRIMARY KEY,
    emergency_category_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    speed INTEGER NOT NULL,
    title_eng VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS hand_book_main_categories (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    title_eng VARCHAR(255) NOT NULL,
    picture VARCHAR(512) NOT NULL
);

CREATE TABLE IF NOT EXISTS rosaviatest_category (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    title_eng VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS rosaviatest_questions (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,
    question TEXT NOT NULL,
    question_eng TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS rosaviatest_answers (
    id SERIAL PRIMARY KEY,
    question_id INTEGER NOT NULL,
    answer TEXT NOT NULL,
    answer_eng TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS rosaviatest_type_certificates_category (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    title_eng VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS question_type_certificates (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,
    question TEXT NOT NULL,
    question_eng TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS type_certificates (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    title_eng VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS type_correct_answers (
    id SERIAL PRIMARY KEY,
    question_id INTEGER NOT NULL,
    answer TEXT NOT NULL,
    answer_eng TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL
);

-- ============================================
-- 10. ФУНКЦИИ И ТРИГГЕРЫ
-- ============================================

-- Функция для обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Функция для обновления updated_at в user_fcm_tokens
CREATE OR REPLACE FUNCTION update_user_fcm_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггеры (создаются только если не существуют)
DO $$
BEGIN
    -- Триггер для flights
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_flights_updated_at') THEN
        CREATE TRIGGER update_flights_updated_at BEFORE UPDATE ON flights
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    -- Триггер для bookings
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_bookings_updated_at') THEN
        CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    -- Триггер для blog_categories
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_blog_categories_updated_at') THEN
        CREATE TRIGGER tr_blog_categories_updated_at BEFORE UPDATE ON blog_categories
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    -- Триггер для blog_articles
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_blog_articles_updated_at') THEN
        CREATE TRIGGER tr_blog_articles_updated_at BEFORE UPDATE ON blog_articles
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    -- Триггер для blog_comments
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_blog_comments_updated_at') THEN
        CREATE TRIGGER tr_blog_comments_updated_at BEFORE UPDATE ON blog_comments
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    -- Триггер для app_settings
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_app_settings_updated_at') THEN
        CREATE TRIGGER tr_app_settings_updated_at BEFORE UPDATE ON app_settings
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    -- Триггер для user_fcm_tokens
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_update_user_fcm_tokens_updated_at') THEN
        CREATE TRIGGER trigger_update_user_fcm_tokens_updated_at
            BEFORE UPDATE ON user_fcm_tokens
            FOR EACH ROW
            EXECUTE FUNCTION update_user_fcm_tokens_updated_at();
    END IF;
END $$;

COMMIT;
