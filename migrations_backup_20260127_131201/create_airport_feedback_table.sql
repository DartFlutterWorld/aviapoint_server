-- Таблица для обратной связи об аэропортах
CREATE TABLE IF NOT EXISTS airport_feedback (
  id SERIAL PRIMARY KEY,
  airport_code VARCHAR(10) NOT NULL,
  email VARCHAR(255),
  comment TEXT,
  photos JSONB, -- Массив URL фотографий
  created_at TIMESTAMP DEFAULT NOW(),
  status VARCHAR(20) DEFAULT 'pending' -- pending, reviewed, resolved
);

CREATE INDEX IF NOT EXISTS idx_airport_feedback_airport_code ON airport_feedback(airport_code);
CREATE INDEX IF NOT EXISTS idx_airport_feedback_status ON airport_feedback(status);
CREATE INDEX IF NOT EXISTS idx_airport_feedback_created_at ON airport_feedback(created_at);


