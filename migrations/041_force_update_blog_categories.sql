-- Миграция: Принудительное обновление категорий авиаблога
-- Версия: 041
-- Дата создания: 2025-01-XX
-- Описание: Принудительно удаляет старые категории и создает новые
-- Эта миграция выполнится даже если 040 уже была выполнена

BEGIN;

-- Убеждаемся, что колонки slug и description удалены (если они еще есть)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'blog_categories' AND column_name = 'slug') THEN
    ALTER TABLE blog_categories DROP COLUMN slug;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'blog_categories' AND column_name = 'description') THEN
    ALTER TABLE blog_categories DROP COLUMN description;
  END IF;
END $$;

-- Удаляем ВСЕ существующие категории
DELETE FROM blog_categories;

-- Сбрасываем счетчик автоинкремента (чтобы новые категории начинались с id=1)
ALTER SEQUENCE blog_categories_id_seq RESTART WITH 1;

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

COMMIT;

