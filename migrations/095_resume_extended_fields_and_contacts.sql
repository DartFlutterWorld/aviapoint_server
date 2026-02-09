-- Миграция 095: расширение резюме — адрес, дата рождения, гражданство, разрешение на работу,
-- фото, контакт-профиль; удаление города, желаемой локации, allow_show_contacts_to_all.
-- Опыт работы: одно поле "обязанности и достижения", без position/industry/achievements.
-- Образование: year_start, year_end, is_current; упрощение полей.

-- ============================================
-- 1. РЕЗЮМЕ: новые поля
-- ============================================

ALTER TABLE jobs_resumes
  ADD COLUMN IF NOT EXISTS address TEXT,
  ADD COLUMN IF NOT EXISTS date_of_birth DATE,
  ADD COLUMN IF NOT EXISTS citizenship TEXT[] DEFAULT ARRAY['RU'],
  ADD COLUMN IF NOT EXISTS work_permit BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS photo_url TEXT,
  ADD COLUMN IF NOT EXISTS additional_photo_urls JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS contact_profile_id INTEGER REFERENCES jobs_contact_profiles(id) ON DELETE SET NULL;

-- Удаление полей (после добавления новых, чтобы не ломать существующие данные при откате)
ALTER TABLE jobs_resumes DROP COLUMN IF EXISTS city;
ALTER TABLE jobs_resumes DROP COLUMN IF EXISTS preferred_locations;
ALTER TABLE jobs_resumes DROP COLUMN IF EXISTS allow_show_contacts_to_all;

CREATE INDEX IF NOT EXISTS idx_jobs_resumes_contact_profile_id ON jobs_resumes(contact_profile_id);
CREATE INDEX IF NOT EXISTS idx_jobs_resumes_address ON jobs_resumes(address) WHERE address IS NOT NULL;

-- ============================================
-- 2. ОПЫТ РАБОТЫ: одно поле "обязанности и достижения"
-- ============================================

-- Добавляем новое поле, переносим данные, удаляем старые
ALTER TABLE jobs_resume_experiences
  ADD COLUMN IF NOT EXISTS responsibilities_and_achievements TEXT;

UPDATE jobs_resume_experiences
SET responsibilities_and_achievements = TRIM(CONCAT(COALESCE(responsibilities, ''), E'\n', COALESCE(achievements, '')))
WHERE responsibilities_and_achievements IS NULL AND (responsibilities IS NOT NULL OR achievements IS NOT NULL);

ALTER TABLE jobs_resume_experiences DROP COLUMN IF EXISTS position;
ALTER TABLE jobs_resume_experiences DROP COLUMN IF EXISTS industry;
ALTER TABLE jobs_resume_experiences DROP COLUMN IF EXISTS responsibilities;
ALTER TABLE jobs_resume_experiences DROP COLUMN IF EXISTS achievements;

-- ============================================
-- 3. ОБРАЗОВАНИЕ: year_start, year_end, is_current
-- ============================================

ALTER TABLE jobs_resume_educations
  ADD COLUMN IF NOT EXISTS year_start INTEGER,
  ADD COLUMN IF NOT EXISTS year_end INTEGER,
  ADD COLUMN IF NOT EXISTS is_current BOOLEAN DEFAULT FALSE;

-- Перенос graduation_year -> year_end где есть
UPDATE jobs_resume_educations
SET year_end = graduation_year
WHERE year_end IS NULL AND graduation_year IS NOT NULL;

ALTER TABLE jobs_resume_educations DROP COLUMN IF EXISTS faculty;
ALTER TABLE jobs_resume_educations DROP COLUMN IF EXISTS degree;
ALTER TABLE jobs_resume_educations DROP COLUMN IF EXISTS graduation_year;

-- speciality оставляем как специализация
