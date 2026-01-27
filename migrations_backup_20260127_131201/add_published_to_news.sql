-- Миграция: добавление поля published и author_id в таблицу news
-- Поле published определяет, опубликована ли новость (true) или предложена пользователем (false)
-- Поле author_id связывает новость с пользователем, который её предложил

-- Добавляем поле author_id (если его еще нет)
DO $$ 
DECLARE
    column_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'news' AND column_name = 'author_id'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        ALTER TABLE news ADD COLUMN author_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_news_author_id ON news(author_id);

-- Добавляем поле published
DO $$ 
DECLARE
    column_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'news' AND column_name = 'published'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        ALTER TABLE news ADD COLUMN published BOOLEAN DEFAULT TRUE;
    END IF;
END $$;

-- Устанавливаем published = true для всех существующих новостей
UPDATE news SET published = TRUE WHERE published IS NULL;

-- Делаем поле NOT NULL после обновления
DO $$ 
DECLARE
    is_nullable BOOLEAN;
BEGIN
    SELECT is_nullable = 'YES' INTO is_nullable
    FROM information_schema.columns 
    WHERE table_name = 'news' AND column_name = 'published';
    
    IF is_nullable THEN
        ALTER TABLE news ALTER COLUMN published SET NOT NULL;
    END IF;
END $$;

ALTER TABLE news ALTER COLUMN published SET DEFAULT FALSE;

-- Создаем индекс для быстрой фильтрации
CREATE INDEX IF NOT EXISTS idx_news_published ON news(published);

-- Комментарии к полям
COMMENT ON COLUMN news.author_id IS 'ID пользователя, предложившего новость';
COMMENT ON COLUMN news.published IS 'Опубликована ли новость (true) или находится на модерации (false)';
