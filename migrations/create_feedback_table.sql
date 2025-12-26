-- Таблица для обратной связи от пользователей
CREATE TABLE IF NOT EXISTS feedback (
  id SERIAL PRIMARY KEY,
  source_page VARCHAR(100) NOT NULL, -- Страница, с которой была отправлена форма (например, 'airport_info', 'flight_detail', etc.)
  airport_code VARCHAR(10), -- Код аэропорта (если обратная связь связана с аэропортом)
  flight_id INTEGER REFERENCES flights(id) ON DELETE SET NULL, -- ID полета (если обратная связь связана с полетом)
  email VARCHAR(255),
  comment TEXT NOT NULL,
  photos JSONB DEFAULT '[]'::jsonb, -- Массив URL фотографий
  status VARCHAR(20) DEFAULT 'pending', -- pending, reviewed, resolved
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Индексы для производительности
CREATE INDEX IF NOT EXISTS idx_feedback_source_page ON feedback(source_page);
CREATE INDEX IF NOT EXISTS idx_feedback_airport_code ON feedback(airport_code) WHERE airport_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_feedback_flight_id ON feedback(flight_id) WHERE flight_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback(status);
CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON feedback(created_at);

COMMENT ON TABLE feedback IS 'Таблица для обратной связи от пользователей';
COMMENT ON COLUMN feedback.source_page IS 'Страница, с которой была отправлена форма обратной связи';
COMMENT ON COLUMN feedback.airport_code IS 'Код аэропорта (если обратная связь связана с аэропортом)';
COMMENT ON COLUMN feedback.flight_id IS 'ID полета (если обратная связь связана с полетом)';


