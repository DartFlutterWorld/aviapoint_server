-- Создание таблицы для хранения платежей
CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(255) PRIMARY KEY,
    status VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'RUB',
    description TEXT,
    payment_url TEXT,
    created_at TIMESTAMP NOT NULL,
    paid BOOLEAN NOT NULL DEFAULT false,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индекс для быстрого поиска по статусу
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- Индекс для поиска по дате создания
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);

