-- Добавление недостающих полей в таблицу airport_ownership_requests
-- Эта миграция добавляет поля, которые могли отсутствовать, если таблица была создана до их добавления

-- Добавляем airport_code (добавляем первым, так как это критичное поле)
ALTER TABLE airport_ownership_requests ADD COLUMN IF NOT EXISTS airport_code VARCHAR(10);
CREATE INDEX IF NOT EXISTS idx_airport_ownership_requests_airport_code ON airport_ownership_requests(airport_code) WHERE airport_code IS NOT NULL;
COMMENT ON COLUMN airport_ownership_requests.airport_code IS 'Код ICAO аэропорта';

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'airport_ownership_requests') THEN
        -- Добавляем phone, если его нет
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'airport_ownership_requests' AND column_name = 'phone'
        ) THEN
            ALTER TABLE airport_ownership_requests
            ADD COLUMN phone VARCHAR(20);
            
            COMMENT ON COLUMN airport_ownership_requests.phone IS 'Телефон пользователя из профиля';
            RAISE NOTICE 'Added phone column to airport_ownership_requests table';
        END IF;

        -- Добавляем phone_from_request, если его нет
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'airport_ownership_requests' AND column_name = 'phone_from_request'
        ) THEN
            ALTER TABLE airport_ownership_requests
            ADD COLUMN phone_from_request VARCHAR(20);
            
            COMMENT ON COLUMN airport_ownership_requests.phone_from_request IS 'Телефон из формы заявки';
            RAISE NOTICE 'Added phone_from_request column to airport_ownership_requests table';
        END IF;

        -- Добавляем full_name, если его нет
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'airport_ownership_requests' AND column_name = 'full_name'
        ) THEN
            ALTER TABLE airport_ownership_requests
            ADD COLUMN full_name VARCHAR(255);
            
            COMMENT ON COLUMN airport_ownership_requests.full_name IS 'ФИО пользователя из формы заявки';
            RAISE NOTICE 'Added full_name column to airport_ownership_requests table';
        END IF;

        -- Добавляем comment, если его нет
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'airport_ownership_requests' AND column_name = 'comment'
        ) THEN
            ALTER TABLE airport_ownership_requests
            ADD COLUMN comment TEXT;
            
            COMMENT ON COLUMN airport_ownership_requests.comment IS 'Комментарий пользователя';
            RAISE NOTICE 'Added comment column to airport_ownership_requests table';
        END IF;

        RAISE NOTICE 'Migration completed: all missing fields checked';
    ELSE
        RAISE NOTICE 'Таблица airport_ownership_requests не существует. Создайте её сначала через migrations/create_airport_ownership_requests_table.sql';
    END IF;
END $$;

