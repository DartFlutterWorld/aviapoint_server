-- 086_change_checko_company_unique_to_inn_only.sql
-- Делаем уникальность компаний только по ИНН (КПП игнорируем для кэша).

DO $$
DECLARE
    cons RECORD;
BEGIN
    -- Удаляем старый уникальный ключ по (inn, kpp), если он есть
    FOR cons IN
        SELECT conname
        FROM   pg_constraint
        WHERE  conrelid = 'checko_companies'::regclass
           AND conname = 'checko_companies_inn_kpp_key'
    LOOP
        EXECUTE format('ALTER TABLE checko_companies DROP CONSTRAINT %I', cons.conname);
    END LOOP;

    -- Добавляем уникальность только по inn
    IF NOT EXISTS (
        SELECT 1
        FROM   pg_constraint
        WHERE  conrelid = 'checko_companies'::regclass
           AND conname = 'checko_companies_inn_key'
    ) THEN
        ALTER TABLE checko_companies
        ADD CONSTRAINT checko_companies_inn_key
        UNIQUE (inn);
    END IF;
END
$$;

