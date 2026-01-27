-- Миграция для создания таблицы настроек приложения (feature flags)
-- Позволяет управлять видимостью контента в приложении через бэкенд

BEGIN;

-- Создание таблицы настроек приложения
CREATE TABLE IF NOT EXISTS app_settings (
  id SERIAL PRIMARY KEY,
  key VARCHAR(100) NOT NULL UNIQUE, -- Название настройки (например: 'showPaidContent')
  value BOOLEAN NOT NULL DEFAULT true, -- Значение настройки (true/false)
  description TEXT, -- Описание настройки для админов
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индекс для быстрого поиска по ключу
CREATE INDEX IF NOT EXISTS idx_app_settings_key ON app_settings(key);

-- Триггер для автоматического обновления updated_at
CREATE TRIGGER tr_app_settings_updated_at 
  BEFORE UPDATE ON app_settings 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Вставка начальных настроек
INSERT INTO app_settings (key, value, description) VALUES
  ('showPaidContent', true, 'Показывать платный контент в приложении (раздел Тренировочный режим, виджет подписки в Профиле)')
ON CONFLICT (key) DO NOTHING;

COMMIT;
