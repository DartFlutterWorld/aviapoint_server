-- Добавление поля phone в таблицу airport_ownership_requests

ALTER TABLE airport_ownership_requests ADD COLUMN IF NOT EXISTS phone VARCHAR(20);

COMMENT ON COLUMN airport_ownership_requests.phone IS 'Телефон пользователя из профиля';


