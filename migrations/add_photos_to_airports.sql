-- Добавление поля photos в таблицу airports для хранения фотографий аэродрома

ALTER TABLE airports ADD COLUMN IF NOT EXISTS photos JSONB DEFAULT '[]'::jsonb;

-- Индекс для поиска по фотографиям (опционально)
CREATE INDEX IF NOT EXISTS idx_airports_photos ON airports USING GIN (photos) WHERE photos IS NOT NULL AND jsonb_array_length(photos) > 0;

COMMENT ON COLUMN airports.photos IS 'Массив URL фотографий аэродрома';


