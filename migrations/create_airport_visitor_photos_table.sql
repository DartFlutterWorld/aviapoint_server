-- Создаем таблицу для фотографий посетителей аэропортов
CREATE TABLE IF NOT EXISTS airport_visitor_photos (
  id SERIAL PRIMARY KEY,
  airport_code VARCHAR(10) NOT NULL,
  airport_id INTEGER,
  photo_url TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  user_phone VARCHAR(20) NOT NULL,
  label TEXT, -- Подпись к фотографии (опционально)
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Внешние ключи
  CONSTRAINT fk_airport_visitor_photos_airport 
    FOREIGN KEY (airport_id) 
    REFERENCES airports(id) 
    ON DELETE CASCADE,
  CONSTRAINT fk_airport_visitor_photos_user 
    FOREIGN KEY (user_id) 
    REFERENCES profiles(id) 
    ON DELETE CASCADE,
  
  -- Уникальный индекс для предотвращения дубликатов (по airport_id, так как код может измениться)
  CONSTRAINT uq_airport_visitor_photos_airport_id_url 
    UNIQUE NULLS NOT DISTINCT (airport_id, photo_url)
);

-- Индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_airport_visitor_photos_airport_code 
  ON airport_visitor_photos(airport_code);
CREATE INDEX IF NOT EXISTS idx_airport_visitor_photos_airport_id 
  ON airport_visitor_photos(airport_id);
CREATE INDEX IF NOT EXISTS idx_airport_visitor_photos_user_id 
  ON airport_visitor_photos(user_id);
CREATE INDEX IF NOT EXISTS idx_airport_visitor_photos_uploaded_at 
  ON airport_visitor_photos(uploaded_at DESC);

-- Комментарии
COMMENT ON TABLE airport_visitor_photos IS 'Фотографии аэропортов, добавленные посетителями';
COMMENT ON COLUMN airport_visitor_photos.airport_code IS 'ICAO код аэропорта';
COMMENT ON COLUMN airport_visitor_photos.airport_id IS 'ID аэропорта (для связи с таблицей airports)';
COMMENT ON COLUMN airport_visitor_photos.photo_url IS 'URL фотографии относительно public/';
COMMENT ON COLUMN airport_visitor_photos.user_id IS 'ID пользователя, загрузившего фотографию';
COMMENT ON COLUMN airport_visitor_photos.user_phone IS 'Телефон пользователя, загрузившего фотографию';
COMMENT ON COLUMN airport_visitor_photos.label IS 'Подпись к фотографии (опционально)';
COMMENT ON COLUMN airport_visitor_photos.uploaded_at IS 'Дата и время загрузки фотографии';

