-- Миграция для создания таблиц Авиаблога

BEGIN;

-- 1. Таблица категорий статей
CREATE TABLE IF NOT EXISTS blog_categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  slug VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  icon_url VARCHAR(512),
  color VARCHAR(7) DEFAULT '#0A6EFA', -- HEX цвет для UI
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Таблица статей блога
CREATE TABLE IF NOT EXISTS blog_articles (
  id SERIAL PRIMARY KEY,
  author_id INTEGER NOT NULL REFERENCES profiles(id),
  category_id INTEGER REFERENCES blog_categories(id) ON DELETE SET NULL,
  aircraft_model_id INTEGER REFERENCES aircraft_models(id) ON DELETE SET NULL, -- Связь с каталогом самолётов
  title VARCHAR(500) NOT NULL,
  slug VARCHAR(500) NOT NULL UNIQUE,
  excerpt TEXT, -- Краткое описание для превью
  content TEXT NOT NULL, -- HTML/Markdown контент
  cover_image_url VARCHAR(512), -- Обложка статьи
  meta_title VARCHAR(255), -- SEO заголовок
  meta_description TEXT, -- SEO описание
  status VARCHAR(50) DEFAULT 'draft', -- draft, published, archived
  is_featured BOOLEAN DEFAULT FALSE, -- Рекомендуемая статья
  view_count INTEGER DEFAULT 0,
  published_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Таблица тегов
CREATE TABLE IF NOT EXISTS blog_tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  slug VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Связь статьи и тегов (многие-ко-многим)
CREATE TABLE IF NOT EXISTS blog_article_tags (
  article_id INTEGER NOT NULL REFERENCES blog_articles(id) ON DELETE CASCADE,
  tag_id INTEGER NOT NULL REFERENCES blog_tags(id) ON DELETE CASCADE,
  PRIMARY KEY (article_id, tag_id)
);

-- 5. Таблица комментариев
CREATE TABLE IF NOT EXISTS blog_comments (
  id SERIAL PRIMARY KEY,
  article_id INTEGER NOT NULL REFERENCES blog_articles(id) ON DELETE CASCADE,
  author_id INTEGER NOT NULL REFERENCES profiles(id),
  parent_comment_id INTEGER REFERENCES blog_comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_approved BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Индексы для ускорения поиска
CREATE INDEX IF NOT EXISTS idx_blog_articles_category ON blog_articles(category_id);
CREATE INDEX IF NOT EXISTS idx_blog_articles_aircraft ON blog_articles(aircraft_model_id);
CREATE INDEX IF NOT EXISTS idx_blog_articles_status ON blog_articles(status);
CREATE INDEX IF NOT EXISTS idx_blog_articles_published ON blog_articles(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_blog_comments_article ON blog_comments(article_id);

-- Триггеры для автоматического обновления updated_at
-- Используем существующую функцию update_updated_at_column()
CREATE TRIGGER tr_blog_categories_updated_at BEFORE UPDATE ON blog_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_blog_articles_updated_at BEFORE UPDATE ON blog_articles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_blog_comments_updated_at BEFORE UPDATE ON blog_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Наполнение базовыми категориями
INSERT INTO blog_categories (name, slug, color, order_index) VALUES
('Обучение', 'training', '#0A6EFA', 1),
('Безопасность', 'safety', '#EF4444', 2),
('Обзоры', 'reviews', '#10B981', 3),
('Маршруты', 'destinations', '#3B82F6', 4),
('Технологии', 'tech', '#8B5CF6', 5)
ON CONFLICT (slug) DO NOTHING;

COMMIT;
