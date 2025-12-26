-- Таблица для заявок на владение аэродромом

CREATE TABLE IF NOT EXISTS airport_ownership_requests (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  airport_id INTEGER NOT NULL REFERENCES airports(id) ON DELETE CASCADE,
  airport_code VARCHAR(10), -- Код ICAO аэропорта
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20), -- Телефон пользователя из профиля
  phone_from_request VARCHAR(20), -- Телефон из формы заявки
  full_name VARCHAR(255), -- ФИО пользователя из формы заявки
  comment TEXT, -- Комментарий пользователя
  documents JSONB DEFAULT '[]'::jsonb, -- Массив URL документов
  status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
  admin_notes TEXT, -- Заметки администратора
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  reviewed_at TIMESTAMP, -- Дата рассмотрения заявки
  reviewed_by INTEGER REFERENCES profiles(id) ON DELETE SET NULL -- Кто рассмотрел заявку
);

-- Индексы для производительности
CREATE INDEX IF NOT EXISTS idx_airport_ownership_requests_user_id ON airport_ownership_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_airport_ownership_requests_airport_id ON airport_ownership_requests(airport_id);
CREATE INDEX IF NOT EXISTS idx_airport_ownership_requests_status ON airport_ownership_requests(status);
CREATE INDEX IF NOT EXISTS idx_airport_ownership_requests_created_at ON airport_ownership_requests(created_at);

-- Уникальный индекс: один пользователь может подать только одну заявку на один аэропорт
CREATE UNIQUE INDEX IF NOT EXISTS idx_airport_ownership_requests_user_airport ON airport_ownership_requests(user_id, airport_id) WHERE status = 'pending';

COMMENT ON TABLE airport_ownership_requests IS 'Заявки пользователей на владение аэродромами';
COMMENT ON COLUMN airport_ownership_requests.airport_code IS 'Код ICAO аэропорта';
COMMENT ON COLUMN airport_ownership_requests.phone IS 'Телефон пользователя из профиля';
COMMENT ON COLUMN airport_ownership_requests.phone_from_request IS 'Телефон из формы заявки';
COMMENT ON COLUMN airport_ownership_requests.full_name IS 'ФИО пользователя из формы заявки';
COMMENT ON COLUMN airport_ownership_requests.documents IS 'Массив URL документов, подтверждающих право собственности';
COMMENT ON COLUMN airport_ownership_requests.status IS 'Статус заявки: pending (на рассмотрении), approved (одобрена), rejected (отклонена)';

