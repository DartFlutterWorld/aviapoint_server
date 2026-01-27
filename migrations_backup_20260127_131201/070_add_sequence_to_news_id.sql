-- Миграция: создание sequence для поля id в таблице news
-- Эта миграция создает sequence и устанавливает DEFAULT для автоматической генерации id

BEGIN;

-- Создаем sequence для id, если его еще нет
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'news_id_seq') THEN
        -- Создаем sequence
        CREATE SEQUENCE news_id_seq;
        
        -- Устанавливаем текущее значение sequence на максимальный id + 1
        -- Это гарантирует, что новые записи получат уникальные id
        PERFORM setval('news_id_seq', COALESCE((SELECT MAX(id) FROM news), 0) + 1, false);
        
        -- Устанавливаем DEFAULT для id
        ALTER TABLE news ALTER COLUMN id SET DEFAULT nextval('news_id_seq');
        
        -- Делаем sequence владельцем колонки (для автоматического удаления при удалении колонки)
        ALTER SEQUENCE news_id_seq OWNED BY news.id;
    ELSE
        -- Если sequence уже существует, просто обновляем его значение
        PERFORM setval('news_id_seq', COALESCE((SELECT MAX(id) FROM news), 0) + 1, false);
    END IF;
END $$;

COMMIT;
