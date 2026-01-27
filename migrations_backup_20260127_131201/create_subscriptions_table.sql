-- Проверяем существование таблицы payments перед обновлением
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN
        -- Обновление таблицы payments: добавление связи с пользователем
        ALTER TABLE payments 
        ADD COLUMN IF NOT EXISTS user_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL;

        -- Создание индекса для быстрого поиска платежей по пользователю
        CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
    ELSE
        RAISE NOTICE 'Таблица payments не существует. Создайте её сначала через migrations/create_payments_table.sql';
    END IF;
END $$;

-- Создание таблицы типов подписок (справочник)
CREATE TABLE IF NOT EXISTS subscription_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL, -- 'monthly', 'quarterly', 'yearly', 'custom'
    name VARCHAR(100) NOT NULL, -- 'Месячная', 'Квартальная', 'Годовая', 'Произвольная'
    period_days INTEGER NOT NULL, -- Количество дней подписки
    price DECIMAL(10, 2) NOT NULL, -- Цена подписки
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Вставка стандартных типов подписок
INSERT INTO subscription_types (code, name, period_days, price) VALUES
    ('monthly', 'Месячная подписка', 30, 0.00),
    ('quarterly', 'Квартальная подписка', 90, 0.00),
    ('yearly', 'Годовая подписка', 365, 0.00)
ON CONFLICT (code) DO NOTHING;

-- Создание таблицы подписок
CREATE TABLE IF NOT EXISTS subscriptions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    payment_id VARCHAR(255) REFERENCES payments(id) ON DELETE SET NULL,
    subscription_type_id INTEGER REFERENCES subscription_types(id),
    period_days INTEGER NOT NULL, -- Количество дней подписки
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true,
    auto_renew BOOLEAN DEFAULT false, -- Автопродление подписки
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_payment_id ON subscriptions(payment_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_end_date ON subscriptions(end_date);
CREATE INDEX IF NOT EXISTS idx_subscriptions_is_active ON subscriptions(is_active);

-- Частичный уникальный индекс: один пользователь может иметь только одну активную подписку
CREATE UNIQUE INDEX IF NOT EXISTS idx_subscriptions_unique_active 
ON subscriptions(user_id) 
WHERE is_active = true;

-- Функция для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_subscriptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для автоматического обновления updated_at
CREATE TRIGGER update_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_subscriptions_updated_at();

-- Функция для деактивации истекших подписок (можно запускать по расписанию)
CREATE OR REPLACE FUNCTION deactivate_expired_subscriptions()
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    UPDATE subscriptions
    SET is_active = false
    WHERE is_active = true 
      AND end_date < CURRENT_TIMESTAMP;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

