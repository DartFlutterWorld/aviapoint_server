-- 084_create_checko_entities.sql
-- Таблицы для хранения данных из Checko (организации и ИП),
-- связанных с пользователями (profiles).

-- Таблица для юридических лиц (организации, ЕГРЮЛ)
CREATE TABLE IF NOT EXISTS checko_companies (
    id              BIGSERIAL PRIMARY KEY,

    -- Связь с пользователем AviaPoint
    user_id         BIGINT NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Идентификаторы организации
    inn             VARCHAR(20) NOT NULL,
    ogrn            VARCHAR(20),
    kpp             VARCHAR(20),
    okpo            VARCHAR(20),

    -- Сырой ответ от Checko (data + meta + при необходимости source_data)
    raw_data        JSONB NOT NULL,

    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL
);

-- Уникальность организации для пользователя по ИНН + КПП (если КПП есть)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM   pg_constraint
        WHERE  conname = 'checko_companies_user_inn_kpp_key'
    ) THEN
        ALTER TABLE checko_companies
        ADD CONSTRAINT checko_companies_user_inn_kpp_key
        UNIQUE (user_id, inn, kpp);
    END IF;
END
$$;

-- Индексы по основным идентификаторам
CREATE INDEX IF NOT EXISTS idx_checko_companies_inn
    ON checko_companies (inn);

CREATE INDEX IF NOT EXISTS idx_checko_companies_ogrn
    ON checko_companies (ogrn);

CREATE INDEX IF NOT EXISTS idx_checko_companies_user_id
    ON checko_companies (user_id);


-- Таблица для индивидуальных предпринимателей (физические лица как ИП, ЕГРИП)
CREATE TABLE IF NOT EXISTS checko_entrepreneurs (
    id              BIGSERIAL PRIMARY KEY,

    -- Связь с пользователем AviaPoint
    user_id         BIGINT NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Идентификаторы ИП
    inn             VARCHAR(20) NOT NULL,
    ogrn            VARCHAR(20),
    okpo            VARCHAR(20),

    -- Сырой ответ от Checko
    raw_data        JSONB NOT NULL,

    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL
);

-- Уникальность ИП для пользователя по ИНН
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM   pg_constraint
        WHERE  conname = 'checko_entrepreneurs_user_inn_key'
    ) THEN
        ALTER TABLE checko_entrepreneurs
        ADD CONSTRAINT checko_entrepreneurs_user_inn_key
        UNIQUE (user_id, inn);
    END IF;
END
$$;

-- Индексы по основным идентификаторам
CREATE INDEX IF NOT EXISTS idx_checko_entrepreneurs_inn
    ON checko_entrepreneurs (inn);

CREATE INDEX IF NOT EXISTS idx_checko_entrepreneurs_ogrn
    ON checko_entrepreneurs (ogrn);

CREATE INDEX IF NOT EXISTS idx_checko_entrepreneurs_user_id
    ON checko_entrepreneurs (user_id);

