-- Миграция: Добавление полей для продажи доли самолета
-- Дата: 2026-01-13

BEGIN;

-- Добавляем поля для продажи доли
ALTER TABLE aircraft_market 
ADD COLUMN IF NOT EXISTS is_share_sale BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS share_numerator INTEGER,
ADD COLUMN IF NOT EXISTS share_denominator INTEGER;

COMMIT;