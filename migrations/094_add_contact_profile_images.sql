-- Миграция 094: логотип и дополнительные фото для профилей контактов
ALTER TABLE jobs_contact_profiles
  ADD COLUMN IF NOT EXISTS logo_url TEXT,
  ADD COLUMN IF NOT EXISTS additional_image_urls JSONB;
