-- Миграция: Добавление/обновление поля slug в таблице blog_articles
-- Версия: 040
-- Дата создания: 2025-01-XX

-- Поле slug уже существует в таблице blog_articles из миграции 038
-- Эта миграция добавлена для возможных будущих изменений

-- Если нужно изменить поле slug (например, сделать его nullable или изменить размер):
-- ALTER TABLE blog_articles 
--   ALTER COLUMN slug TYPE VARCHAR(500),
--   ALTER COLUMN slug DROP NOT NULL;

-- Если нужно добавить индекс для slug (если его еще нет):
-- CREATE INDEX IF NOT EXISTS idx_blog_articles_slug ON blog_articles(slug);

-- Комментарий к миграции
COMMENT ON COLUMN blog_articles.slug IS 'URL-friendly идентификатор статьи';

