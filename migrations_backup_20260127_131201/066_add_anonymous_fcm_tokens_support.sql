-- Добавление поддержки анонимных FCM токенов
-- Изменяем таблицу user_fcm_tokens чтобы user_id мог быть NULL (для анонимных токенов)
-- Также переименовываем таблицу в fcm_tokens для единообразия

BEGIN;

-- Переименовываем таблицу
ALTER TABLE user_fcm_tokens RENAME TO fcm_tokens;

-- Делаем user_id nullable для поддержки анонимных токенов
ALTER TABLE fcm_tokens ALTER COLUMN user_id DROP NOT NULL;

-- Удаляем старый уникальный constraint (user_id, fcm_token)
-- В PostgreSQL уникальный constraint создается автоматически при UNIQUE(user_id, fcm_token)
-- После переименования таблицы имя constraint может остаться прежним или измениться
DO $$
DECLARE
  constraint_name text;
BEGIN
  -- Ищем constraint по колонкам (user_id, fcm_token)
  -- Сначала пробуем найти по старому имени
  SELECT conname INTO constraint_name
  FROM pg_constraint
  WHERE conrelid = 'fcm_tokens'::regclass
    AND contype = 'u'
    AND (conname = 'user_fcm_tokens_user_id_fcm_token_key' OR conname LIKE '%user_id%fcm_token%');
  
  -- Если не нашли по имени, ищем по колонкам
  IF constraint_name IS NULL THEN
    SELECT conname INTO constraint_name
    FROM pg_constraint
    WHERE conrelid = 'fcm_tokens'::regclass
      AND contype = 'u'
      AND array_length(conkey, 1) = 2
      AND conkey[1] = (SELECT attnum FROM pg_attribute WHERE attrelid = 'fcm_tokens'::regclass AND attname = 'user_id')
      AND conkey[2] = (SELECT attnum FROM pg_attribute WHERE attrelid = 'fcm_tokens'::regclass AND attname = 'fcm_token');
  END IF;
  
  -- Удаляем constraint если найден
  IF constraint_name IS NOT NULL THEN
    EXECUTE 'ALTER TABLE fcm_tokens DROP CONSTRAINT ' || quote_ident(constraint_name);
    RAISE NOTICE 'Удален constraint: %', constraint_name;
  ELSE
    RAISE NOTICE 'Constraint не найден, возможно уже удален';
  END IF;
END $$;

-- Создаем новый уникальный индекс только на fcm_token (токен должен быть уникальным)
CREATE UNIQUE INDEX IF NOT EXISTS idx_fcm_tokens_token_unique ON fcm_tokens(fcm_token);

-- Создаем индекс для быстрого поиска анонимных токенов
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_anonymous ON fcm_tokens(fcm_token) WHERE user_id IS NULL;

-- Обновляем имя индекса user_id (если он существует)
DROP INDEX IF EXISTS idx_user_fcm_tokens_user_id;
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user_id ON fcm_tokens(user_id) WHERE user_id IS NOT NULL;

-- Обновляем имя индекса platform (если он существует)
DROP INDEX IF EXISTS idx_user_fcm_tokens_platform;
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_platform ON fcm_tokens(platform);

-- Обновляем имя индекса token (если он существует)
DROP INDEX IF EXISTS idx_user_fcm_tokens_token;
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_token ON fcm_tokens(fcm_token) WHERE fcm_token IS NOT NULL;

-- Обновляем имя триггера
DROP TRIGGER IF EXISTS trigger_update_user_fcm_tokens_updated_at ON fcm_tokens;
CREATE TRIGGER trigger_update_fcm_tokens_updated_at
  BEFORE UPDATE ON fcm_tokens
  FOR EACH ROW
  EXECUTE FUNCTION update_user_fcm_tokens_updated_at();

-- Обновляем внешний ключ (если user_id не NULL, он должен ссылаться на profiles)
-- Сначала удаляем старый constraint
ALTER TABLE fcm_tokens DROP CONSTRAINT IF EXISTS user_fcm_tokens_user_id_fkey;
-- Создаем новый constraint с условием
ALTER TABLE fcm_tokens 
  ADD CONSTRAINT fcm_tokens_user_id_fkey 
  FOREIGN KEY (user_id) 
  REFERENCES profiles(id) 
  ON DELETE CASCADE;

COMMENT ON TABLE fcm_tokens IS 'FCM токены для push-уведомлений. user_id = NULL означает анонимный токен для массовых рассылок';
COMMENT ON COLUMN fcm_tokens.user_id IS 'ID пользователя. NULL для анонимных токенов';
COMMENT ON COLUMN fcm_tokens.fcm_token IS 'FCM токен устройства (уникальный)';
COMMENT ON COLUMN fcm_tokens.platform IS 'Платформа: ios, android, web';

COMMIT;
