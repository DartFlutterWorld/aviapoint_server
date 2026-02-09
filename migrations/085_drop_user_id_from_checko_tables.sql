-- 085_drop_user_id_from_checko_tables.sql
-- Убираем связь с пользователем из таблиц Checko и делаем кэш глобальным по ИНН.

-- Удаляем внешние ключи и уникальные ограничения, завязанные на user_id
DO $$
DECLARE
    cons RECORD;
BEGIN
    -- Для checko_companies
    FOR cons IN
        SELECT conname
        FROM   pg_constraint
        WHERE  conrelid = 'checko_companies'::regclass
           AND conname IN ('checko_companies_user_inn_kpp_key')
    LOOP
        EXECUTE format('ALTER TABLE checko_companies DROP CONSTRAINT %I', cons.conname);
    END LOOP;

    -- Для checko_entrepreneurs
    FOR cons IN
        SELECT conname
        FROM   pg_constraint
        WHERE  conrelid = 'checko_entrepreneurs'::regclass
           AND conname IN ('checko_entrepreneurs_user_inn_key')
    LOOP
        EXECUTE format('ALTER TABLE checko_entrepreneurs DROP CONSTRAINT %I', cons.conname);
    END LOOP;
END
$$;

-- Удаляем столбец user_id из обеих таблиц, если он существует
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM   information_schema.columns
        WHERE  table_name = 'checko_companies'
          AND  column_name = 'user_id'
    ) THEN
        ALTER TABLE checko_companies DROP COLUMN user_id;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM   information_schema.columns
        WHERE  table_name = 'checko_entrepreneurs'
          AND  column_name = 'user_id'
    ) THEN
        ALTER TABLE checko_entrepreneurs DROP COLUMN user_id;
    END IF;
END
$$;

-- Добавляем новые уникальные ограничения без user_id
DO $$
BEGIN
    -- Для компаний: уникальность по (inn, kpp)
    IF NOT EXISTS (
        SELECT 1
        FROM   pg_constraint
        WHERE  conname = 'checko_companies_inn_kpp_key'
    ) THEN
        ALTER TABLE checko_companies
        ADD CONSTRAINT checko_companies_inn_kpp_key
        UNIQUE (inn, kpp);
    END IF;

    -- Для ИП: уникальность по inn
    IF NOT EXISTS (
        SELECT 1
        FROM   pg_constraint
        WHERE  conname = 'checko_entrepreneurs_inn_key'
    ) THEN
        ALTER TABLE checko_entrepreneurs
        ADD CONSTRAINT checko_entrepreneurs_inn_key
        UNIQUE (inn);
    END IF;
END
$$;

