-- Добавление поля owned_airports в таблицу profiles
-- Хранит массив ID аэропортов, которыми владеет пользователь

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS owned_airports JSONB DEFAULT '[]'::jsonb;

-- Индекс для поиска владельцев аэропортов
CREATE INDEX IF NOT EXISTS idx_profiles_owned_airports ON profiles USING GIN (owned_airports) WHERE owned_airports IS NOT NULL AND jsonb_array_length(owned_airports) > 0;

COMMENT ON COLUMN profiles.owned_airports IS 'Массив ID аэропортов, которыми владеет пользователь';


