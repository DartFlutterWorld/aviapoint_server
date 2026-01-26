BEGIN;

-- Добавляем поле content для хранения Quill Delta JSON
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'news' AND column_name = 'content'
    ) THEN
        ALTER TABLE news ADD COLUMN content TEXT;
        COMMENT ON COLUMN news.content IS 'Quill Delta JSON контент новости (вместо body)';
    END IF;
END $$;

-- Убеждаемся, что у таблицы news есть PRIMARY KEY на id
DO $$ 
DECLARE
    duplicate_count INTEGER;
    max_id_val INTEGER;
BEGIN
    -- Сначала убеждаемся, что колонка id имеет NOT NULL
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
        -- Перенумеровываем дубликаты, оставляя первую запись с оригинальным id
        -- Используем UPDATE с подзапросом, который вычисляет новый id
        UPDATE news n1
        SET id = subquery.new_id
        FROM (
            SELECT ctid,
                   (SELECT COALESCE(MAX(id), 0) FROM news) + 
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
            SELECT COALESCE(MAX(id), 0) INTO max_id_val FROM news;
            PERFORM setval('news_id_seq', GREATEST(max_id_val, 1), false);
        END IF;
    END IF;
    
    -- Затем создаем PRIMARY KEY, если его еще нет
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conrelid = 'news'::regclass 
        AND contype = 'p'
    ) THEN
        -- Создаем PRIMARY KEY на id, если его еще нет
        ALTER TABLE news ADD CONSTRAINT news_pkey PRIMARY KEY (id);
    END IF;
END $$;

-- Создаем таблицу для дополнительных изображений новостей
-- Сначала проверяем, существует ли таблица без внешнего ключа, и удаляем её
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
        -- Таблица существует, но без внешнего ключа - удаляем её
        DROP TABLE IF EXISTS news_images CASCADE;
    END IF;
END $$;

-- Создаем таблицу для дополнительных изображений новостей
CREATE TABLE IF NOT EXISTS news_images (
    id SERIAL PRIMARY KEY,
    news_id INTEGER NOT NULL REFERENCES news(id) ON DELETE CASCADE,
    image_url VARCHAR(512) NOT NULL,
    image_path VARCHAR(512) NOT NULL,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Создаем индексы
CREATE INDEX IF NOT EXISTS idx_news_images_news_id ON news_images(news_id);
CREATE INDEX IF NOT EXISTS idx_news_images_order_index ON news_images(news_id, order_index);

COMMENT ON TABLE news_images IS 'Дополнительные изображения для новостей';
COMMENT ON COLUMN news_images.news_id IS 'ID новости';
COMMENT ON COLUMN news_images.image_url IS 'URL изображения (относительный путь)';
COMMENT ON COLUMN news_images.image_path IS 'Полный путь к файлу изображения';
COMMENT ON COLUMN news_images.order_index IS 'Порядок отображения изображений';

COMMIT;
