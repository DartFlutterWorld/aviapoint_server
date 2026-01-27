-- Добавление поля owner_id в таблицу airports
-- Связывает аэропорт с владельцем (пользователем)

ALTER TABLE airports ADD COLUMN IF NOT EXISTS owner_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL;

-- Индекс для поиска аэропортов по владельцу
CREATE INDEX IF NOT EXISTS idx_airports_owner_id ON airports(owner_id) WHERE owner_id IS NOT NULL;

COMMENT ON COLUMN airports.owner_id IS 'ID пользователя-владельца аэропорта';


