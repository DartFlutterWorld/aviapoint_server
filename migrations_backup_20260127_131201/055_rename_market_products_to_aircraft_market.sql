-- Миграция для переименования таблицы market_products в aircraft_market
-- Также переименовываем связанные объекты: индексы, внешние ключи, таблицу user_favorite_products

BEGIN;

-- Переименовываем таблицу market_products в aircraft_market
ALTER TABLE IF EXISTS market_products RENAME TO aircraft_market;

-- Переименовываем индексы
ALTER INDEX IF EXISTS idx_market_products_aircraft_subcategories_id RENAME TO idx_aircraft_market_aircraft_subcategories_id;
ALTER INDEX IF EXISTS idx_market_products_seller_id RENAME TO idx_aircraft_market_seller_id;
ALTER INDEX IF EXISTS idx_market_products_is_active RENAME TO idx_aircraft_market_is_active;

-- Переименовываем PRIMARY KEY constraint (только если существует старое имя)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'market_products_pkey' 
    AND conrelid = 'aircraft_market'::regclass
  ) THEN
    ALTER TABLE aircraft_market 
      RENAME CONSTRAINT market_products_pkey TO aircraft_market_pkey;
  END IF;
END $$;

-- Переименовываем FOREIGN KEY constraints (только если существуют старые имена)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'market_products_seller_id_fkey' 
    AND conrelid = 'aircraft_market'::regclass
  ) THEN
    ALTER TABLE aircraft_market 
      RENAME CONSTRAINT market_products_seller_id_fkey TO aircraft_market_seller_id_fkey;
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'market_products_aircraft_subcategories_id_fkey' 
    AND conrelid = 'aircraft_market'::regclass
  ) THEN
    ALTER TABLE aircraft_market 
      RENAME CONSTRAINT market_products_aircraft_subcategories_id_fkey TO aircraft_market_aircraft_subcategories_id_fkey;
  END IF;
END $$;

-- Переименовываем sequence для id (если используется старое имя)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'market_products_id_seq') THEN
    ALTER SEQUENCE market_products_id_seq RENAME TO aircraft_market_id_seq;
    ALTER TABLE aircraft_market ALTER COLUMN id SET DEFAULT nextval('aircraft_market_id_seq'::regclass);
  END IF;
END $$;

-- Переименовываем таблицу user_favorite_products в user_favorite_aircraft_market
ALTER TABLE IF EXISTS user_favorite_products RENAME TO user_favorite_aircraft_market;

-- Обновляем внешний ключ в user_favorite_aircraft_market
-- Сначала удаляем старый внешний ключ
ALTER TABLE IF EXISTS user_favorite_aircraft_market 
  DROP CONSTRAINT IF EXISTS user_favorite_products_product_id_fkey;

-- Добавляем новый внешний ключ с правильным именем (только если не существует)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'user_favorite_aircraft_market_product_id_fkey'
    AND conrelid = 'user_favorite_aircraft_market'::regclass
  ) THEN
    ALTER TABLE user_favorite_aircraft_market
      ADD CONSTRAINT user_favorite_aircraft_market_product_id_fkey 
      FOREIGN KEY (product_id) REFERENCES aircraft_market(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Переименовываем индексы для user_favorite_aircraft_market
ALTER INDEX IF EXISTS idx_user_favorite_products_user_id RENAME TO idx_user_favorite_aircraft_market_user_id;
ALTER INDEX IF EXISTS idx_user_favorite_products_product_id RENAME TO idx_user_favorite_aircraft_market_product_id;

COMMIT;
