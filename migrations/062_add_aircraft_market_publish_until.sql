BEGIN;

ALTER TABLE IF EXISTS aircraft_market
  ADD COLUMN IF NOT EXISTS published_until TIMESTAMP WITH TIME ZONE;

ALTER TABLE IF EXISTS aircraft_market
  ALTER COLUMN published_until SET DEFAULT (NOW() + INTERVAL '1 month');

UPDATE aircraft_market
SET published_until = COALESCE(published_until, created_at + INTERVAL '1 month');

UPDATE aircraft_market
SET is_active = false
WHERE is_active = true
  AND published_until IS NOT NULL
  AND published_until < NOW();

COMMIT;
