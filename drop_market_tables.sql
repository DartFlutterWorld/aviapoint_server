-- Удаление таблиц маркета
-- ВНИМАНИЕ: Это удалит все данные из этих таблиц!

BEGIN;

-- 1. Удаляем таблицу избранных (зависит от market_products)
DROP TABLE IF EXISTS market_favorites CASCADE;

-- 2. Удаляем таблицу продуктов (зависит от market_categories)
DROP TABLE IF EXISTS market_products CASCADE;

-- 3. Удаляем таблицу категорий
DROP TABLE IF EXISTS market_categories CASCADE;

-- 4. Удаляем тип ENUM (если он больше не используется)
DROP TYPE IF EXISTS market_product_type CASCADE;

COMMIT;
