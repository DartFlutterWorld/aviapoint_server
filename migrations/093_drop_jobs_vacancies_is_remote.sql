-- Миграция 093: удаление флага удалённой работы из вакансий
ALTER TABLE jobs_vacancies
  DROP COLUMN IF EXISTS is_remote;
