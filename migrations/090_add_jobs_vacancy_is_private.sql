-- Миграция 090: флаг частного лица для вакансий
ALTER TABLE jobs_vacancies
  ADD COLUMN IF NOT EXISTS is_private BOOLEAN DEFAULT FALSE;
