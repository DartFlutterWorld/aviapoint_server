-- Миграция 089: добавление контактных данных для вакансий
ALTER TABLE jobs_vacancies
  ADD COLUMN IF NOT EXISTS contact_name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS contact_phone VARCHAR(50),
  ADD COLUMN IF NOT EXISTS contact_phone_alt VARCHAR(50),
  ADD COLUMN IF NOT EXISTS contact_telegram VARCHAR(255),
  ADD COLUMN IF NOT EXISTS contact_whatsapp VARCHAR(255),
  ADD COLUMN IF NOT EXISTS contact_max VARCHAR(255),
  ADD COLUMN IF NOT EXISTS contact_email VARCHAR(255),
  ADD COLUMN IF NOT EXISTS contact_site VARCHAR(255);
