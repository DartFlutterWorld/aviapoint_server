-- Добавление полей подписки в профиль для быстрого доступа (денормализация)
-- Это позволяет быстро проверять подписку без JOIN с таблицей subscriptions

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS has_active_subscription BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS subscription_updated_at TIMESTAMP;

-- Индекс для быстрого поиска пользователей с активной подпиской
CREATE INDEX IF NOT EXISTS idx_profiles_has_active_subscription 
ON profiles(has_active_subscription) 
WHERE has_active_subscription = true;

-- Индекс для поиска истекших подписок
CREATE INDEX IF NOT EXISTS idx_profiles_subscription_end_date 
ON profiles(subscription_end_date) 
WHERE has_active_subscription = true;

-- Функция для обновления полей подписки в профиле
-- Создается только если таблица subscriptions существует
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
        -- Функция для обновления полей подписки в профиле
        CREATE OR REPLACE FUNCTION update_profile_subscription()
        RETURNS TRIGGER AS $func$
        BEGIN
            -- Обновляем поля подписки в профиле при изменении подписки
            IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
                UPDATE profiles
                SET 
                    subscription_end_date = NEW.end_date,
                    has_active_subscription = NEW.is_active AND NEW.end_date > CURRENT_TIMESTAMP,
                    subscription_updated_at = CURRENT_TIMESTAMP
                WHERE id = NEW.user_id;
            ELSIF TG_OP = 'DELETE' THEN
                -- При удалении подписки проверяем, есть ли другие активные подписки
                UPDATE profiles
                SET 
                    subscription_end_date = (
                        SELECT MAX(end_date) 
                        FROM subscriptions 
                        WHERE user_id = OLD.user_id AND is_active = true
                    ),
                    has_active_subscription = EXISTS(
                        SELECT 1 
                        FROM subscriptions 
                        WHERE user_id = OLD.user_id 
                          AND is_active = true 
                          AND end_date > CURRENT_TIMESTAMP
                    ),
                    subscription_updated_at = CURRENT_TIMESTAMP
                WHERE id = OLD.user_id;
            END IF;
            
            RETURN COALESCE(NEW, OLD);
        END;
        $func$ LANGUAGE plpgsql;

        -- Триггер для автоматического обновления профиля при изменении подписки
        DROP TRIGGER IF EXISTS trigger_update_profile_subscription ON subscriptions;
        CREATE TRIGGER trigger_update_profile_subscription
            AFTER INSERT OR UPDATE OR DELETE ON subscriptions
            FOR EACH ROW
            EXECUTE FUNCTION update_profile_subscription();

        -- Обновляем существующие профили на основе текущих подписок
        UPDATE profiles p
        SET 
            subscription_end_date = (
                SELECT MAX(s.end_date)
                FROM subscriptions s
                WHERE s.user_id = p.id 
                  AND s.is_active = true
            ),
            has_active_subscription = EXISTS(
                SELECT 1
                FROM subscriptions s
                WHERE s.user_id = p.id
                  AND s.is_active = true
                  AND s.end_date > CURRENT_TIMESTAMP
            ),
            subscription_updated_at = CURRENT_TIMESTAMP
        WHERE EXISTS(
            SELECT 1 FROM subscriptions WHERE user_id = p.id
        );
    END IF;
END $$;

