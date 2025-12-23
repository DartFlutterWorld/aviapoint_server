-- Добавление поля reply_to_review_id для ответов на отзывы
ALTER TABLE reviews 
ADD COLUMN IF NOT EXISTS reply_to_review_id INTEGER REFERENCES reviews(id) ON DELETE CASCADE;

-- Индекс для быстрого поиска ответов на отзыв
CREATE INDEX IF NOT EXISTS idx_reviews_reply_to_review_id ON reviews(reply_to_review_id) WHERE reply_to_review_id IS NOT NULL;

-- Комментарий к полю
COMMENT ON COLUMN reviews.reply_to_review_id IS 'ID отзыва, на который дан ответ (для двусторонних отзывов)';

