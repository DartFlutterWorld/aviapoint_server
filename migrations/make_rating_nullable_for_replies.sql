-- Делаем rating nullable для ответов на отзывы
-- Для основных отзывов rating обязателен (1-5), для ответов может быть NULL

-- Шаг 1: Удаляем старый CHECK constraint (если есть)
ALTER TABLE reviews 
  DROP CONSTRAINT IF EXISTS reviews_rating_check;

-- Шаг 2: Сначала изменяем колонку, чтобы разрешить NULL
ALTER TABLE reviews 
  ALTER COLUMN rating DROP NOT NULL;

-- Шаг 3: Обновляем существующие ответы (если есть), устанавливая rating = NULL
-- Ответы определяются по наличию reply_to_review_id
UPDATE reviews 
SET rating = NULL 
WHERE reply_to_review_id IS NOT NULL;

-- Шаг 4: Добавляем новый CHECK constraint, который разрешает NULL или значение от 1 до 5
ALTER TABLE reviews 
  ADD CONSTRAINT reviews_rating_check 
  CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5));

