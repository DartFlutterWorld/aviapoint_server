-- Добавляем поле visitor_photos для хранения фотографий посетителей
ALTER TABLE airports ADD COLUMN IF NOT EXISTS visitor_photos JSONB DEFAULT '[]'::jsonb;

-- Комментарий к полю
COMMENT ON COLUMN airports.visitor_photos IS 'Массив URL фотографий, добавленных посетителями аэропорта';


