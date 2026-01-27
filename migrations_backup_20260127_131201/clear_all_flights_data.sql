-- Миграция для полной очистки всех данных о полетах и удаления ненужных полей
-- Удаляет все полеты и все связанные данные:
-- - Отзывы (reviews)
-- - Бронирования (bookings)
-- - Фотографии полетов (flight_photos)
-- - Точки маршрута (flight_waypoints)
-- - Полеты (flights)
-- 
-- Также удаляет ненужные поля из таблицы flights:
-- - departure_airport (теперь все точки в flight_waypoints)
-- - arrival_airport (теперь все точки в flight_waypoints)
-- - Индексы на эти поля

-- ВАЖНО: Эта миграция удаляет ВСЕ данные без возможности восстановления!

BEGIN;

-- 1. Удаляем все отзывы, связанные с бронированиями полетов
DELETE FROM reviews 
WHERE booking_id IN (
  SELECT id FROM bookings WHERE flight_id IN (SELECT id FROM flights)
);

-- 2. Удаляем все бронирования полетов
DELETE FROM bookings 
WHERE flight_id IN (SELECT id FROM flights);

-- 3. Удаляем все фотографии полетов
DELETE FROM flight_photos 
WHERE flight_id IN (SELECT id FROM flights);

-- 4. Удаляем все точки маршрута полетов
DELETE FROM flight_waypoints 
WHERE flight_id IN (SELECT id FROM flights);

-- 5. Удаляем все полеты
DELETE FROM flights;

-- 6. Удаляем индексы на поля departure_airport и arrival_airport
DROP INDEX IF EXISTS idx_flights_departure_airport;
DROP INDEX IF EXISTS idx_flights_arrival_airport;

-- 7. Удаляем поля departure_airport и arrival_airport из таблицы flights
-- (теперь все точки маршрута хранятся в flight_waypoints)
ALTER TABLE flights DROP COLUMN IF EXISTS departure_airport;
ALTER TABLE flights DROP COLUMN IF EXISTS arrival_airport;

-- 8. Сбрасываем последовательности (начинаем ID с 1)
ALTER SEQUENCE IF EXISTS flights_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS bookings_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS reviews_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS flight_photos_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS flight_waypoints_id_seq RESTART WITH 1;

COMMIT;

-- Проверка: выводим количество оставшихся записей (должно быть 0)
DO $$
DECLARE
  flights_count INTEGER;
  bookings_count INTEGER;
  reviews_count INTEGER;
  photos_count INTEGER;
  waypoints_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO flights_count FROM flights;
  SELECT COUNT(*) INTO bookings_count FROM bookings;
  SELECT COUNT(*) INTO reviews_count FROM reviews;
  SELECT COUNT(*) INTO photos_count FROM flight_photos;
  SELECT COUNT(*) INTO waypoints_count FROM flight_waypoints;
  
  RAISE NOTICE 'Осталось записей: flights=%, bookings=%, reviews=%, photos=%, waypoints=%', 
    flights_count, bookings_count, reviews_count, photos_count, waypoints_count;
END $$;

