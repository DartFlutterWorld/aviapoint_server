-- Добавление поля avatar_url в таблицу profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(255);

