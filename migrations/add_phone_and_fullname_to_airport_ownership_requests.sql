-- Добавление полей phone_from_request и full_name в таблицу airport_ownership_requests

ALTER TABLE airport_ownership_requests ADD COLUMN IF NOT EXISTS phone_from_request VARCHAR(20);
ALTER TABLE airport_ownership_requests ADD COLUMN IF NOT EXISTS full_name VARCHAR(255);

COMMENT ON COLUMN airport_ownership_requests.phone IS 'Телефон пользователя из профиля';
COMMENT ON COLUMN airport_ownership_requests.phone_from_request IS 'Телефон из формы заявки';
COMMENT ON COLUMN airport_ownership_requests.full_name IS 'ФИО пользователя из формы заявки';


