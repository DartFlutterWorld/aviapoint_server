-- Миграция: Обновление категорий авиаблога и удаление slug/description
-- Дата создания: 2025-01-XX
-- Описание: Удаление полей slug и description, обновление категорий

BEGIN;

-- Удаляем уникальный индекс на name (если существует)
DROP INDEX IF EXISTS blog_categories_name_key;
DROP INDEX IF EXISTS blog_categories_name_idx;

-- Удаляем колонки slug и description (если они существуют)
-- Сначала проверяем и удаляем индексы, которые могут зависеть от slug
DO $$
BEGIN
  -- Удаляем колонки slug и description
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'blog_categories' AND column_name = 'slug') THEN
    ALTER TABLE blog_categories DROP COLUMN slug;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'blog_categories' AND column_name = 'description') THEN
    ALTER TABLE blog_categories DROP COLUMN description;
  END IF;
END $$;

-- Обновляем или добавляем категории
-- Сначала удаляем старые категории (статьи будут иметь category_id = NULL из-за ON DELETE SET NULL)
DELETE FROM blog_categories;

-- 1. Обучение и сертификация
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Обучение и сертификация',
  '#0A6EFA',
  1
);

-- 2. Безопасность полетов
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Безопасность полетов',
  '#EF4444',
  2
);

-- 3. Обзоры самолетов
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Обзоры самолетов',
  '#10B981',
  3
);

-- 4. Маршруты и путешествия
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Маршруты и путешествия',
  '#3B82F6',
  4
);

-- 5. Техника и оборудование
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Техника и оборудование',
  '#8B5CF6',
  5
);

-- 6. Советы пилотам
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Советы пилотам',
  '#F59E0B',
  6
);

-- 7. Истории из практики
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Истории из практики',
  '#06B6D4',
  7
);

-- 8. Навигация и планирование
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Навигация и планирование',
  '#14B8A6',
  8
);

-- 9. Правила и регламенты
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Правила и регламенты',
  '#64748B',
  9
);

-- 10. Новости авиации
INSERT INTO blog_categories (name, color, order_index) 
VALUES (
  'Новости авиации',
  '#EC4899',
  10
);

COMMIT;

-- Комментарий к миграции
COMMENT ON TABLE blog_categories IS 'Категории статей авиаблога без полей slug и description';
