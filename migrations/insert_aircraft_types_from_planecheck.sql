-- Заполнение таблицы aircraft_types данными с PlaneCheck.com
-- Данные собраны с https://www.planecheck.com/

-- Начало транзакции
BEGIN;

-- Cirrus
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Cirrus', 'SR20', 'Cirrus SR20', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cirrus', 'SRV', 'Cirrus SR20 / SRV', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cirrus', 'SR22', 'Cirrus SR22', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cirrus', 'SF50', 'Cirrus SF50 Vision Jet', 'single_engine', 'jet', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Diamond
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Diamond', 'DA20', 'Diamond DA20', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Diamond', 'DV20', 'Diamond DA20 / DV20', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Diamond', 'Dimona', 'Diamond Super Dimona', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Diamond', 'DA40', 'Diamond DA40 Star', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Diamond', 'DA42', 'Diamond DA42 Twin Star', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Diamond', 'DA50', 'Diamond DA50 RG', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Diamond', 'DA62', 'Diamond DA62', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Mooney
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Mooney', 'M20', 'Mooney M20 Series (normally-aspirated)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Mooney', 'M20T', 'Mooney M20 Series (turbo)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Piper
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Piper', 'J-3', 'Piper J-3 Cub Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'J-5', 'Piper J-5 Cub Cruiser', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-18', 'Piper PA-18 Super Cub', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-22', 'Piper PA-22 Colt / Tri-Pacer', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-23', 'Piper PA-23 Apache', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-23A', 'Piper PA-23 Aztec', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-24', 'Piper PA-24 Comanche', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-25', 'Piper PA-25 Pawnee', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-28', 'Piper PA-28 Cherokee / Warrior / Archer', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-28D', 'Piper PA-28 Cherokee / Dakota (6 cylinder)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-28R', 'Piper PA-28 Arrow Series (normally-aspirated)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-28RT', 'Piper PA-28 Arrow Series (turbo)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-30', 'Piper Twin Comanche Series', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-31', 'Piper PA-31 Navajo / Chieftain', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-31T', 'Piper PA-31T-500 Cheyenne', 'twin_engine', 'turboprop', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-31T2', 'Piper PA-31 Cheyenne II', 'twin_engine', 'turboprop', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-32', 'Piper PA-32 Cherokee 6 / Saratoga / 6X', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-32R', 'Piper PA-32 Lance / Saratoga (retractable)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-32RT', 'Piper PA-32 Lance II (T-tail)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-34', 'Piper PA-34 Seneca', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-38', 'Piper PA-38 Tomahawk', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-44', 'Piper PA-44 Seminole', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-46', 'Piper PA-46 Malibu / Mirage', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-46M', 'Piper PA-46 Meridian / JetPROP DLX', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-46-701TP', 'Piper PA-46-701TP M700', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Piper', 'Aerostar', 'Piper Aerostar (Ted Smith / Piper) Series', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Robin
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Robin', 'DR-220', 'Robin DR-220 / 221', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Robin', 'DR-200', 'Robin DR-200 / 250', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Robin', 'DR-253', 'Robin DR-253 Régent', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Robin', 'DR-300', 'Robin DR-300 Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Robin', 'DR-400', 'Robin DR-400 / 500', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Robin', 'HR-100', 'Robin HR-100', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Robin', 'HR-200', 'Robin HR-200', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Robin', 'R-1180', 'Robin R-1180 Aiglon', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Socata
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Socata', 'Rallye', 'Socata Rallye (Morane / Socata / PZL) Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'ST-10', 'Socata ST-10', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TB-9', 'Socata TB-9 Tampico', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TB-10', 'Socata TB-10 / 200 Tobago', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TB-20', 'Socata TB-20 / 21 Trinidad', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TB-30', 'Socata TB-30 Epsilon', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TBM-700', 'Socata TBM-700', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Socata', 'TBM-850', 'Socata TBM-850', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Socata', 'TBM-900', 'Socata TBM-900 Series', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Cessna (добавляем самые популярные модели, которых нет в списке, но они широко используются)
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Cessna', '172', 'Cessna 172 Skyhawk', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cessna', '182', 'Cessna 182 Skylane', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cessna', '206', 'Cessna 206 Stationair', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cessna', '210', 'Cessna 210 Centurion', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cessna', '310', 'Cessna 310', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Cessna', '337', 'Cessna 337 Skymaster', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Cessna', '402', 'Cessna 402', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Cessna', '414', 'Cessna 414 Chancellor', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Cessna', '421', 'Cessna 421 Golden Eagle', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Cessna', '208', 'Cessna 208 Caravan', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Cessna', 'Citation', 'Cessna Citation Series', 'twin_engine', 'jet', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Robinson (вертолёты)
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Robinson', 'R22', 'Robinson R-22', 'helicopter', 'piston', 1, 'https://www.planecheck.com/', true),
('Robinson', 'R44', 'Robinson R-44', 'helicopter', 'piston', 1, 'https://www.planecheck.com/', true),
('Robinson', 'R66', 'Robinson R-66', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Robinson', 'R22T', 'Robinson R22 CL02 Turbine', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Beechcraft (популярные модели)
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Beechcraft', 'Bonanza', 'Beechcraft Bonanza', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Beechcraft', 'Baron', 'Beechcraft Baron', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Beechcraft', 'King Air', 'Beechcraft King Air', 'twin_engine', 'turboprop', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Yakovlev (советские/российские самолёты)
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Yakovlev', 'Yak-3', 'Yakovlev Yak-3', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-9', 'Yakovlev Yak-9', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-11', 'Yakovlev Yak-11', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-18', 'Yakovlev Yak-18 (2-seat)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-18T', 'Yakovlev Yak-18T (4-seat)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-50', 'Yakovlev Yak-50', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-52', 'Yakovlev Yak-52', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Antonov
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Antonov', 'An-2', 'Antonov An-2 Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Коммит транзакции
COMMIT;

-- Статистика
SELECT 
    manufacturer,
    COUNT(*) as models_count
FROM aircraft_types
GROUP BY manufacturer
ORDER BY models_count DESC, manufacturer;

