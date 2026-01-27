-- Миграция: Удаление и пересоздание таблицы blog_categories
-- Версия: 045
-- Описание: Полностью удаляет таблицу blog_categories и создает заново с новыми данными

BEGIN;

-- Удаляем таблицу со всеми зависимостями (CASCADE удалит внешние ключи)
DROP TABLE IF EXISTS blog_categories CASCADE;

-- Создаем таблицу заново
CREATE TABLE blog_categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  icon_url VARCHAR(512),
  color VARCHAR(7) DEFAULT '#0A6EFA',
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Восстанавливаем внешний ключ в blog_articles (если таблица существует)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'blog_articles') THEN
    ALTER TABLE blog_articles 
    ADD CONSTRAINT blog_articles_category_id_fkey 
    FOREIGN KEY (category_id) 
    REFERENCES blog_categories(id) 
    ON DELETE SET NULL;
  END IF;
END $$;

-- Вставляем новые категории
INSERT INTO blog_categories (name, color, order_index, is_active) VALUES
('Обучение и сертификация', '#0A6EFA', 1, true),
('Безопасность полетов', '#EF4444', 2, true),
('Обзоры самолетов', '#10B981', 3, true),
('Маршруты и путешествия', '#3B82F6', 4, true),
('Техника и оборудование', '#8B5CF6', 5, true),
('Советы пилотам', '#F59E0B', 6, true),
('Истории из практики', '#06B6D4', 7, true),
('Навигация и планирование', '#14B8A6', 8, true),
('Правила и регламенты', '#64748B', 9, true),
('Новости авиации', '#EC4899', 10, true);

-- Создаем триггер для автоматического обновления updated_at
CREATE TRIGGER tr_blog_categories_updated_at 
BEFORE UPDATE ON blog_categories 
FOR EACH ROW 
EXECUTE FUNCTION update_updated_at_column();

COMMIT;

