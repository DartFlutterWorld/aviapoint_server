-- Создание тестового пользователя с номером +79000000000
-- Этот пользователь используется для тестирования без SMS-подтверждения

DO $$
BEGIN
    -- Проверяем, существует ли уже тестовый пользователь
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE phone = '+79000000000' OR phone = '79000000000' OR phone = '9000000000') THEN
        INSERT INTO profiles (phone)
        VALUES ('+79000000000')
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Test user with phone +79000000000 created';
    ELSE
        RAISE NOTICE 'Test user already exists';
    END IF;
END $$;

