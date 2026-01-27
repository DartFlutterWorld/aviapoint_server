-- Добавление поля is_admin в таблицу profiles для определения администраторов
BEGIN;

-- Добавляем поле is_admin
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE NOT NULL;

-- Устанавливаем is_admin = true для пользователя с user_id = 5 (телефон +79990697289)
UPDATE profiles 
SET is_admin = true 
WHERE id = 5 AND phone = '+79990697289';

-- Создаем индекс для быстрого поиска администраторов
CREATE INDEX IF NOT EXISTS idx_profiles_is_admin ON profiles(is_admin) WHERE is_admin = true;

COMMIT;
