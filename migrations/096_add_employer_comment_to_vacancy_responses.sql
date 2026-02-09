-- Комментарий работодателя к отклику на вакансию (при смене статуса)
ALTER TABLE jobs_vacancy_responses
  ADD COLUMN IF NOT EXISTS employer_comment TEXT;
