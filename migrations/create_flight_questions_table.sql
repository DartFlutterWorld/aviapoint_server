-- Создание таблицы для вопросов пилоту о полёте

CREATE TABLE IF NOT EXISTS flight_questions (
  id SERIAL PRIMARY KEY,
  flight_id INTEGER NOT NULL REFERENCES flights(id) ON DELETE CASCADE,
  author_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL, -- NULL для неавторизованных пользователей
  question_text TEXT NOT NULL,
  answer_text TEXT, -- Ответ пилота
  answered_by_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL, -- ID пилота, который ответил
  answered_at TIMESTAMP, -- Когда был дан ответ
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Индексы для производительности
CREATE INDEX IF NOT EXISTS idx_flight_questions_flight_id ON flight_questions(flight_id);
CREATE INDEX IF NOT EXISTS idx_flight_questions_author_id ON flight_questions(author_id);
CREATE INDEX IF NOT EXISTS idx_flight_questions_answered_by_id ON flight_questions(answered_by_id);
CREATE INDEX IF NOT EXISTS idx_flight_questions_created_at ON flight_questions(created_at);

-- Триггер для обновления updated_at
DROP TRIGGER IF EXISTS update_flight_questions_updated_at ON flight_questions;
CREATE TRIGGER update_flight_questions_updated_at BEFORE UPDATE ON flight_questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

