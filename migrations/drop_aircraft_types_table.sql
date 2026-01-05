-- Удаление устаревшей таблицы aircraft_types
-- Эта таблица заменена на нормализованную структуру: manufacturers + aircraft_models

-- Удаляем таблицу (CASCADE автоматически удалит зависимости, если есть)
DROP TABLE IF EXISTS aircraft_types CASCADE;

-- Комментарий для истории миграций
-- Таблица aircraft_types была заменена на нормализованную структуру:
-- - manufacturers (производители)
-- - aircraft_models (модели самолётов)
-- - aircraft_model_specs (расширенные характеристики)

