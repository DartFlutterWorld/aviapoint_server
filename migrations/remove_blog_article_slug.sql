-- Удаление колонки slug из таблицы blog_articles
-- Также удаляем уникальный индекс на slug, если он существует

-- Удаляем уникальный индекс на slug (если существует)
DROP INDEX IF EXISTS blog_articles_slug_key;
DROP INDEX IF EXISTS blog_articles_slug_idx;

-- Удаляем колонку slug
ALTER TABLE blog_articles
DROP COLUMN IF EXISTS slug;

