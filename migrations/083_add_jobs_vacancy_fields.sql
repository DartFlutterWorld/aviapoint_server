-- Миграция 083: дополнительные поля вакансии
-- Добавляет адрес, оформление и рабочие часы

ALTER TABLE jobs_vacancies
  ADD COLUMN IF NOT EXISTS address TEXT,
  ADD COLUMN IF NOT EXISTS employment_form VARCHAR(64),
  ADD COLUMN IF NOT EXISTS work_hours VARCHAR(64);
