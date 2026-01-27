-- Создание таблицы для фотографий полетов

CREATE TABLE IF NOT EXISTS flight_photos (
  id SERIAL PRIMARY KEY,
  flight_id INTEGER NOT NULL REFERENCES flights(id) ON DELETE CASCADE,
  photo_url VARCHAR(500) NOT NULL,
  uploaded_by INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Индексы для производительности
CREATE INDEX IF NOT EXISTS idx_flight_photos_flight_id ON flight_photos(flight_id);
CREATE INDEX IF NOT EXISTS idx_flight_photos_uploaded_by ON flight_photos(uploaded_by);


