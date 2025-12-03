-- Удаление уникального индекса, ограничивающего одну активную подписку на пользователя
-- Теперь пользователь может иметь несколько активных подписок одновременно

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE indexname = 'idx_subscriptions_unique_active'
    ) THEN
        DROP INDEX IF EXISTS idx_subscriptions_unique_active;
        RAISE NOTICE 'Unique index idx_subscriptions_unique_active removed';
    ELSE
        RAISE NOTICE 'Index idx_subscriptions_unique_active does not exist';
    END IF;
END $$;

