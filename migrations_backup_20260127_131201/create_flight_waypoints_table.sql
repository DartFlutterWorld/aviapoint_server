-- Создание таблицы для точек маршрута полета
-- Все точки маршрута хранятся в этой таблице, включая первую и последнюю

CREATE TABLE IF NOT EXISTS flight_waypoints (
  id SERIAL PRIMARY KEY,
  flight_id INTEGER NOT NULL REFERENCES flights(id) ON DELETE CASCADE,
  airport_code VARCHAR(255) NOT NULL,
  sequence_order INTEGER NOT NULL CHECK (sequence_order > 0),
  arrival_time TIMESTAMP, -- Время прибытия в эту точку
  departure_time TIMESTAMP, -- Время отправления из этой точки
  comment TEXT, -- Комментарий к точке маршрута
  created_at TIMESTAMP DEFAULT NOW(),
  
  -- Уникальность: порядок точек в маршруте должен быть уникальным
  CONSTRAINT uq_flight_waypoints_sequence UNIQUE(flight_id, sequence_order)
);

-- Индексы для производительности
CREATE INDEX IF NOT EXISTS idx_flight_waypoints_flight_id ON flight_waypoints(flight_id);
CREATE INDEX IF NOT EXISTS idx_flight_waypoints_sequence ON flight_waypoints(flight_id, sequence_order);
CREATE INDEX IF NOT EXISTS idx_flight_waypoints_airport_code ON flight_waypoints(airport_code);

-- Комментарии к таблице и полям
COMMENT ON TABLE flight_waypoints IS 'Точки маршрута полета, включая первую и последнюю';
COMMENT ON COLUMN flight_waypoints.flight_id IS 'ID полета';
COMMENT ON COLUMN flight_waypoints.airport_code IS 'Код аэропорта (ICAO)';
COMMENT ON COLUMN flight_waypoints.sequence_order IS 'Порядок точки в маршруте (1, 2, 3...)';
COMMENT ON COLUMN flight_waypoints.arrival_time IS 'Время прибытия в эту точку';
COMMENT ON COLUMN flight_waypoints.departure_time IS 'Время отправления из этой точки';
COMMENT ON COLUMN flight_waypoints.comment IS 'Комментарий к точке маршрута';

