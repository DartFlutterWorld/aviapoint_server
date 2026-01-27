-- Добавление полей telegram и max в таблицу profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS telegram VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS max VARCHAR(255);

