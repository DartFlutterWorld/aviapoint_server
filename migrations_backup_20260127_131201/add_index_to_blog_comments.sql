-- Добавление индексов для таблицы blog_comments

-- Индекс для быстрого поиска ответов на комментарий
CREATE INDEX IF NOT EXISTS idx_blog_comments_parent_comment_id ON blog_comments(parent_comment_id) WHERE parent_comment_id IS NOT NULL;

-- Индекс для быстрого поиска комментариев по автору
CREATE INDEX IF NOT EXISTS idx_blog_comments_author_id ON blog_comments(author_id);

-- Индекс для сортировки по дате создания
CREATE INDEX IF NOT EXISTS idx_blog_comments_created_at ON blog_comments(created_at DESC);
