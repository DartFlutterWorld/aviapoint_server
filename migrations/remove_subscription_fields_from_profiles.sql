-- Удаление полей подписки из таблицы profiles
-- Эти поля были денормализованы для быстрого доступа, но теперь используем прямые запросы к subscriptions

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN
        -- Удаляем триггер, если существует
        DROP TRIGGER IF EXISTS trigger_update_profile_subscription ON subscriptions;
        
        -- Удаляем функцию, если существует
        DROP FUNCTION IF EXISTS update_profile_subscription();
        
        -- Удаляем индексы
        DROP INDEX IF EXISTS idx_profiles_has_active_subscription;
        DROP INDEX IF EXISTS idx_profiles_subscription_end_date;
        
        -- Удаляем колонки
        ALTER TABLE profiles 
        DROP COLUMN IF EXISTS subscription_end_date,
        DROP COLUMN IF EXISTS has_active_subscription,
        DROP COLUMN IF EXISTS subscription_updated_at;
        
        RAISE NOTICE 'Subscription fields removed from profiles table';
    ELSE
        RAISE NOTICE 'Таблица profiles не существует';
    END IF;
END $$;

