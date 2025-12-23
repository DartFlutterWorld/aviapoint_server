-- SQL запрос для получения списка аэропортов из РФ
-- Использование: psql -h localhost -U postgres -d aviapoint -f scripts/list_airports_sql.sql

SELECT 
  ident AS "ICAO",
  COALESCE(iata_code, '-') AS "IATA",
  name AS "Название",
  COALESCE(municipality, '-') AS "Город",
  type AS "Тип",
  latitude_deg AS "Широта",
  longitude_deg AS "Долгота"
FROM airports 
WHERE iso_country = 'RU' AND is_active = true
ORDER BY name ASC
LIMIT 10;

