-- Создание таблицы для хранения FCM токенов по платформам
-- Это позволяет пользователям получать push-уведомления одновременно на веб и мобильные устройства
BEGIN;

-- Создаем таблицу user_fcm_tokens
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    fcm_token VARCHAR(512) NOT NULL,
    platform VARCHAR(20) NOT NULL DEFAULT 'mobile', -- 'mobile', 'web', 'ios', 'android'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, fcm_token) -- Один токен может быть привязан только к одному пользователю
);

-- Создаем индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_platform ON user_fcm_tokens(platform);
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_token ON user_fcm_tokens(fcm_token) WHERE fcm_token IS NOT NULL;

-- Функция для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_user_fcm_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для автоматического обновления updated_at
CREATE TRIGGER trigger_update_user_fcm_tokens_updated_at
    BEFORE UPDATE ON user_fcm_tokens
    FOR EACH ROW
    EXECUTE FUNCTION update_user_fcm_tokens_updated_at();

-- Миграция существующих данных из profiles.fcm_token в user_fcm_tokens
-- Определяем платформу как 'mobile' (по умолчанию для существующих токенов)
INSERT INTO user_fcm_tokens (user_id, fcm_token, platform, created_at, updated_at)
SELECT 
    id as user_id,
    fcm_token,
    'mobile' as platform,
    NOW() as created_at,
    NOW() as updated_at
FROM profiles
WHERE fcm_token IS NOT NULL 
    AND fcm_token != ''
    AND NOT EXISTS (
        SELECT 1 FROM user_fcm_tokens uft 
        WHERE uft.user_id = profiles.id AND uft.fcm_token = profiles.fcm_token
    )
ON CONFLICT (user_id, fcm_token) DO NOTHING;

COMMIT;
