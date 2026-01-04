-- Добавление поля fcm_token в таблицу profiles для хранения Firebase Cloud Messaging токенов
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS fcm_token VARCHAR(512);

-- Создание индекса для быстрого поиска по fcm_token
CREATE INDEX IF NOT EXISTS idx_profiles_fcm_token ON profiles(fcm_token) WHERE fcm_token IS NOT NULL;

