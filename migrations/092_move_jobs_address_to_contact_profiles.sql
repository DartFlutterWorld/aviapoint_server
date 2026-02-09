-- Миграция 092: перенос адреса в профили контактов
ALTER TABLE jobs_contact_profiles
  ADD COLUMN IF NOT EXISTS address TEXT;

ALTER TABLE jobs_vacancies
  DROP COLUMN IF EXISTS address;
