-- Миграция: Создание таблицы настроек публикации для разных типов товаров
-- Дата: 2026-01-13

BEGIN;

-- Создаем таблицу настроек публикации
CREATE TABLE IF NOT EXISTS publication_settings (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL UNIQUE, -- название таблицы: 'aircraft_market', 'parts_market', 'services_market' и т.д.
    publication_duration_months INTEGER NOT NULL DEFAULT 1, -- количество месяцев для публикации
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создаем индекс для быстрого поиска по названию таблицы
CREATE INDEX IF NOT EXISTS idx_publication_settings_table_name 
ON publication_settings(table_name);

-- Вставляем дефолтное значение для aircraft_market (1 месяц)
INSERT INTO publication_settings (table_name, publication_duration_months)
VALUES ('aircraft_market', 1)
ON CONFLICT (table_name) DO NOTHING;

-- Комментарии к таблице
COMMENT ON TABLE publication_settings IS 'Настройки периода публикации для разных типов товаров';
COMMENT ON COLUMN publication_settings.table_name IS 'Название таблицы товаров (aircraft_market, parts_market, services_market и т.д.)';
COMMENT ON COLUMN publication_settings.publication_duration_months IS 'Количество месяцев, на которое публикуется объявление';

COMMIT;
