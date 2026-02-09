-- Миграция 088: удаление старых полей локации в вакансиях
-- Убираем city/region/airport_code, так как используем address

ALTER TABLE jobs_vacancies
  DROP COLUMN IF EXISTS city,
  DROP COLUMN IF EXISTS region,
  DROP COLUMN IF EXISTS airport_code;

DROP INDEX IF EXISTS idx_jobs_vacancies_city;
