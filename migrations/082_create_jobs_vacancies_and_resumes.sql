-- Миграция 082: Вакансии и резюме (jobs)
-- Создает структуру для разделов "Вакансии" и "Резюме"

-- ============================================
-- 1. ВАКАНСИИ
-- ============================================

CREATE TABLE IF NOT EXISTS jobs_vacancies (
    id SERIAL PRIMARY KEY,

    -- Связи
    employer_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Основная информация
    title VARCHAR(255) NOT NULL,              -- Название вакансии
    description TEXT,                         -- О компании / общее описание
    responsibilities TEXT,                    -- Обязанности
    requirements TEXT,                        -- Требования
    conditions TEXT,                          -- Условия работы

    -- Зарплата
    salary_from INTEGER,
    salary_to INTEGER,
    currency VARCHAR(3) DEFAULT 'RUB',
    is_gross BOOLEAN DEFAULT TRUE,            -- true = до вычета налогов
    show_salary BOOLEAN DEFAULT TRUE,         -- показывать ли вилку в интерфейсе

    -- Формат работы
    employment_type VARCHAR(32),              -- full_time, part_time, project, internship
    schedule VARCHAR(32),                     -- office, remote, hybrid, shift, fly_in_fly_out
    experience_level VARCHAR(32),             -- no_experience, 1_3, 3_6, 6_plus
    education_level VARCHAR(32),              -- secondary, college, higher, postgraduate

    -- Локация
    city VARCHAR(255),
    region VARCHAR(255),
    airport_code VARCHAR(10),                 -- при необходимости привязки к аэропорту
    is_remote BOOLEAN DEFAULT FALSE,
    relocation_allowed BOOLEAN DEFAULT FALSE,
    business_trips VARCHAR(32),               -- never, rarely, often

    -- Авиаспецифика
    aircraft_category VARCHAR(64),            -- GA, commercial, helicopter и т.п.
    required_license VARCHAR(64),             -- PPL, CPL, ATPL, AML и т.п.
    min_flight_hours INTEGER,                 -- минимальный налёт (для летных вакансий)
    required_type_rating TEXT,                -- список типов ВС

    -- Статусы
    is_published BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    status VARCHAR(32) DEFAULT 'draft',       -- draft, published, closed, archived, moderation, rejected
    published_until TIMESTAMP WITH TIME ZONE,

    -- Статистика
    views_count INTEGER DEFAULT 0,
    responses_count INTEGER DEFAULT 0,

    -- Временные метки
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closed_at TIMESTAMP WITH TIME ZONE
);

-- Навыки вакансии (ключевые слова)
CREATE TABLE IF NOT EXISTS jobs_vacancy_skills (
    vacancy_id INTEGER NOT NULL REFERENCES jobs_vacancies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (vacancy_id, name)
);

-- Избранные вакансии пользователя
CREATE TABLE IF NOT EXISTS user_favorite_vacancies (
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    vacancy_id INTEGER NOT NULL REFERENCES jobs_vacancies(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, vacancy_id)
);

-- Индексы для вакансий
CREATE INDEX IF NOT EXISTS idx_jobs_vacancies_employer_id ON jobs_vacancies(employer_id);
CREATE INDEX IF NOT EXISTS idx_jobs_vacancies_city ON jobs_vacancies(city);
CREATE INDEX IF NOT EXISTS idx_jobs_vacancies_status ON jobs_vacancies(status);
CREATE INDEX IF NOT EXISTS idx_jobs_vacancies_is_published ON jobs_vacancies(is_published) WHERE is_published = TRUE;
CREATE INDEX IF NOT EXISTS idx_jobs_vacancies_published_until ON jobs_vacancies(published_until);
CREATE INDEX IF NOT EXISTS idx_jobs_vacancies_created_at ON jobs_vacancies(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_jobs_vacancies_salary ON jobs_vacancies(salary_from, salary_to);

-- ============================================
-- 2. РЕЗЮМЕ
-- ============================================

CREATE TABLE IF NOT EXISTS jobs_resumes (
    id SERIAL PRIMARY KEY,

    -- Связи
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Основная информация
    title VARCHAR(255) NOT NULL,              -- Желаемая должность
    about TEXT,                               -- О себе / summary
    status VARCHAR(32) DEFAULT 'active',      -- active, hidden, archived
    is_visible_for_employers BOOLEAN DEFAULT TRUE,

    -- Ожидания
    desired_salary INTEGER,
    currency VARCHAR(3) DEFAULT 'RUB',
    employment_types TEXT,                    -- JSON/CSV с типами занятости
    schedules TEXT,                           -- JSON/CSV с графиками работы
    ready_to_relocate BOOLEAN DEFAULT FALSE,
    ready_for_business_trips BOOLEAN DEFAULT FALSE,

    -- Локация
    city VARCHAR(255),
    preferred_locations TEXT,                 -- желаемые города/регионы

    -- Авиаспецифика
    current_position VARCHAR(255),
    current_company VARCHAR(255),
    total_experience_months INTEGER,
    flight_hours_total INTEGER,
    flight_hours_pic INTEGER,
    licenses TEXT,                            -- перечень лицензий (PPL/CPL/ATPL/AML...)
    type_ratings TEXT,                        -- перечень типов ВС
    medical_class VARCHAR(32),                -- класс ВЛЭК и т.п.

    -- Контактная видимость (контакты сами хранятся в profiles)
    allow_show_contacts_to_all BOOLEAN DEFAULT TRUE,

    -- Временные метки
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Отклики на вакансию (создаём после jobs_resumes, чтобы FK был валиден)
CREATE TABLE IF NOT EXISTS jobs_vacancy_responses (
    id SERIAL PRIMARY KEY,
    vacancy_id INTEGER NOT NULL REFERENCES jobs_vacancies(id) ON DELETE CASCADE,
    resume_id INTEGER REFERENCES jobs_resumes(id) ON DELETE SET NULL,
    candidate_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status VARCHAR(32) DEFAULT 'new',         -- new, viewed, invited, rejected, hired
    cover_letter TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Опыт работы в резюме
CREATE TABLE IF NOT EXISTS jobs_resume_experiences (
    id SERIAL PRIMARY KEY,
    resume_id INTEGER NOT NULL REFERENCES jobs_resumes(id) ON DELETE CASCADE,
    company_name VARCHAR(255) NOT NULL,
    position VARCHAR(255) NOT NULL,
    industry VARCHAR(255),
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT FALSE,
    responsibilities TEXT,
    achievements TEXT
);

-- Образование
CREATE TABLE IF NOT EXISTS jobs_resume_educations (
    id SERIAL PRIMARY KEY,
    resume_id INTEGER NOT NULL REFERENCES jobs_resumes(id) ON DELETE CASCADE,
    institution VARCHAR(255) NOT NULL,
    faculty VARCHAR(255),
    speciality VARCHAR(255),
    degree VARCHAR(64),                       -- bachelor, master, engineer и т.п.
    graduation_year INTEGER
);

-- Навыки резюме
CREATE TABLE IF NOT EXISTS jobs_resume_skills (
    resume_id INTEGER NOT NULL REFERENCES jobs_resumes(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    level VARCHAR(32),                        -- optional: beginner, middle, senior
    PRIMARY KEY (resume_id, name)
);

-- Языки в резюме
CREATE TABLE IF NOT EXISTS jobs_resume_languages (
    resume_id INTEGER NOT NULL REFERENCES jobs_resumes(id) ON DELETE CASCADE,
    language VARCHAR(64) NOT NULL,
    level VARCHAR(64) NOT NULL,               -- native, fluent, B2, ICAO4 и т.п.
    PRIMARY KEY (resume_id, language)
);

-- Избранные резюме пользователя (для работодателей)
CREATE TABLE IF NOT EXISTS user_favorite_resumes (
    user_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    resume_id INTEGER NOT NULL REFERENCES jobs_resumes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, resume_id)
);

-- Индексы для резюме
CREATE INDEX IF NOT EXISTS idx_jobs_resumes_user_id ON jobs_resumes(user_id);
CREATE INDEX IF NOT EXISTS idx_jobs_resumes_city ON jobs_resumes(city);
CREATE INDEX IF NOT EXISTS idx_jobs_resumes_status ON jobs_resumes(status);
CREATE INDEX IF NOT EXISTS idx_jobs_resumes_created_at ON jobs_resumes(created_at DESC);

-- ============================================
-- 3. НАСТРОЙКИ ПУБЛИКАЦИИ
-- ============================================

-- Предполагается, что таблица publication_settings уже создана предыдущими миграциями.
-- Добавляем настройки срока публикации для вакансий и резюме.

INSERT INTO publication_settings (table_name, publication_duration_months)
VALUES ('jobs_vacancies', 1)
ON CONFLICT (table_name) DO NOTHING;

INSERT INTO publication_settings (table_name, publication_duration_months)
VALUES ('jobs_resumes', 6)
ON CONFLICT (table_name) DO NOTHING;

