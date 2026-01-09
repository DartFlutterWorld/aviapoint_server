-- Миграция: Удаление неиспользуемого представления aircraft_catalog_view
-- Версия: 051
-- Причина: Представление не используется в коде, фронтенд работает напрямую с таблицами через JOIN

BEGIN;

-- Удаляем представление aircraft_catalog_view
DROP VIEW IF EXISTS aircraft_catalog_view;

COMMIT;
