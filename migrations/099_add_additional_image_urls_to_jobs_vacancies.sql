-- Файлы вакансии хранятся у вакансии (как у резюме), не в контактном профиле.
ALTER TABLE jobs_vacancies
  ADD COLUMN IF NOT EXISTS additional_image_urls JSONB DEFAULT '[]'::jsonb;
