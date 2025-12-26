-- Создание тестовых пользователей с номерами +79000000000 и +79000000001
-- Эти пользователи используются для тестирования без SMS-подтверждения

DO $$
BEGIN
    -- Проверяем, существует ли уже тестовый пользователь с номером +79000000000
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE phone = '+79000000000' OR phone = '79000000000' OR phone = '9000000000') THEN
        INSERT INTO profiles (phone)
        VALUES ('+79000000000')
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Test user with phone +79000000000 created';
    ELSE
        RAISE NOTICE 'Test user with phone +79000000000 already exists';
    END IF;

    -- Проверяем, существует ли уже тестовый пользователь с номером +79000000001
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE phone = '+79000000001' OR phone = '79000000001' OR phone = '9000000001') THEN
        INSERT INTO profiles (phone)
        VALUES ('+79000000001')
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Test user with phone +79000000001 created';
    ELSE
        RAISE NOTICE 'Test user with phone +79000000001 already exists';
    END IF;

    -- Проверяем, существует ли уже тестовый пользователь с номером +79000000002
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE phone = '+79000000002' OR phone = '79000000002' OR phone = '9000000002') THEN
        INSERT INTO profiles (phone)
        VALUES ('+79000000002')
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Test user with phone +79000000002 created';
    ELSE
        RAISE NOTICE 'Test user with phone +79000000002 already exists';
    END IF;
END $$;

