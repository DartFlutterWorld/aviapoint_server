-- 087_add_employer_inn_to_jobs_vacancies.sql
-- Добавляем ИНН работодателя к вакансиям для связи с кэшем Checko.

ALTER TABLE jobs_vacancies
  ADD COLUMN IF NOT EXISTS employer_inn VARCHAR(12);

CREATE INDEX IF NOT EXISTS idx_jobs_vacancies_employer_inn
  ON jobs_vacancies (employer_inn);

