-- Миграция: Удаление полей meta_title, meta_description и is_featured из таблицы blog_articles
-- Дата создания: 2025-01-XX

-- Удаляем колонки из таблицы blog_articles
ALTER TABLE blog_articles 
  DROP COLUMN IF EXISTS meta_title,
  DROP COLUMN IF EXISTS meta_description,
  DROP COLUMN IF EXISTS is_featured;

-- Комментарий к миграции
COMMENT ON TABLE blog_articles IS 'Таблица статей блога без полей meta_title, meta_description и is_featured';
