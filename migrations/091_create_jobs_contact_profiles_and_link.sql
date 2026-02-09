-- Миграция 091: профили контактов для вакансий
CREATE TABLE IF NOT EXISTS jobs_contact_profiles (
  id SERIAL PRIMARY KEY,
  owner_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  is_private BOOLEAN DEFAULT FALSE,
  company_name VARCHAR(255),
  inn VARCHAR(20),
  contact_name VARCHAR(255) NOT NULL,
  contact_position VARCHAR(255) NOT NULL,
  contact_phone VARCHAR(50) NOT NULL,
  contact_phone_alt VARCHAR(50),
  contact_telegram VARCHAR(255),
  contact_whatsapp VARCHAR(255),
  contact_max VARCHAR(255),
  contact_email VARCHAR(255),
  contact_site VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_jobs_contact_profiles_owner_id ON jobs_contact_profiles(owner_id);
CREATE INDEX IF NOT EXISTS idx_jobs_contact_profiles_created_at ON jobs_contact_profiles(created_at DESC);

ALTER TABLE jobs_vacancies
  ADD COLUMN IF NOT EXISTS contact_profile_id INTEGER REFERENCES jobs_contact_profiles(id) ON DELETE SET NULL,
  DROP COLUMN IF EXISTS contact_name,
  DROP COLUMN IF EXISTS contact_phone,
  DROP COLUMN IF EXISTS contact_phone_alt,
  DROP COLUMN IF EXISTS contact_telegram,
  DROP COLUMN IF EXISTS contact_whatsapp,
  DROP COLUMN IF EXISTS contact_max,
  DROP COLUMN IF EXISTS contact_email,
  DROP COLUMN IF EXISTS contact_site,
  DROP COLUMN IF EXISTS is_private,
  DROP COLUMN IF EXISTS employer_inn;

CREATE INDEX IF NOT EXISTS idx_jobs_vacancies_contact_profile_id ON jobs_vacancies(contact_profile_id);
