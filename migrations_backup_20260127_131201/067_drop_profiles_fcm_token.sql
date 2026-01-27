-- Удаление устаревшего поля fcm_token из таблицы profiles
-- Теперь все FCM токены хранятся только в таблице fcm_tokens

BEGIN;

-- Удаляем индекс, если он существует
DROP INDEX IF EXISTS idx_profiles_fcm_token;

-- Удаляем столбец fcm_token, если он существует
ALTER TABLE profiles DROP COLUMN IF EXISTS fcm_token;

COMMIT;

