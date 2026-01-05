-- Заполнение таблицы aircraft_types данными с PlaneCheck.com
-- Данные собраны с https://www.planecheck.com/
-- Полный список производителей и моделей

BEGIN;

-- ============================================
-- ОСНОВНЫЕ ПРОИЗВОДИТЕЛИ
-- ============================================

-- Cirrus
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Cirrus', 'SR20', 'Cirrus SR20', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cirrus', 'SRV', 'Cirrus SR20 / SRV', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cirrus', 'SR22', 'Cirrus SR22', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Cirrus', 'SF50', 'Cirrus SF50 Vision Jet', 'single_engine', 'jet', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Diamond
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Diamond', 'DA20', 'Diamond DA20 / DV20', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
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
('Piper', 'PA-28D', 'Piper PA-28 Cherokee / Dakota', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-28R', 'Piper PA-28 Arrow Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-28RT', 'Piper PA-28 Arrow Series (turbo)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-30', 'Piper Twin Comanche Series', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-31', 'Piper PA-31 Navajo / Chieftain', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-31T', 'Piper PA-31T-500 Cheyenne', 'twin_engine', 'turboprop', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-31T2', 'Piper PA-31 Cheyenne II', 'twin_engine', 'turboprop', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-32', 'Piper PA-32 Cherokee 6 / Saratoga', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-32R', 'Piper PA-32 Lance / Saratoga (retractable)', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-32RT', 'Piper PA-32 Lance II', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-34', 'Piper PA-34 Seneca', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-38', 'Piper PA-38 Tomahawk', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-44', 'Piper PA-44 Seminole', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Piper', 'PA-46', 'Piper PA-46 Malibu / Mirage', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-46M', 'Piper PA-46 Meridian / JetPROP DLX', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Piper', 'PA-46-701TP', 'Piper PA-46-701TP M700', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Piper', 'Aerostar', 'Piper Aerostar', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true)
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
('Socata', 'Rallye', 'Socata Rallye', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'ST-10', 'Socata ST-10', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TB-9', 'Socata TB-9 Tampico', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TB-10', 'Socata TB-10 / 200 Tobago', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TB-20', 'Socata TB-20 / 21 Trinidad', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TB-30', 'Socata TB-30 Epsilon', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Socata', 'TBM-700', 'Socata TBM-700', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Socata', 'TBM-850', 'Socata TBM-850', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Socata', 'TBM-900', 'Socata TBM-900 Series', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Cessna
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

-- Robinson
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Robinson', 'R22', 'Robinson R-22', 'helicopter', 'piston', 1, 'https://www.planecheck.com/', true),
('Robinson', 'R44', 'Robinson R-44', 'helicopter', 'piston', 1, 'https://www.planecheck.com/', true),
('Robinson', 'R66', 'Robinson R-66', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Robinson', 'R22T', 'Robinson R22 CL02 Turbine', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Beechcraft
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Beechcraft', 'Bonanza', 'Beechcraft Bonanza', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Beechcraft', 'Baron', 'Beechcraft Baron', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Beechcraft', 'King Air', 'Beechcraft King Air', 'twin_engine', 'turboprop', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Yakovlev
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Yakovlev', 'Yak-3', 'Yakovlev Yak-3', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-9', 'Yakovlev Yak-9', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-11', 'Yakovlev Yak-11', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-18', 'Yakovlev Yak-18', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-18T', 'Yakovlev Yak-18T', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-50', 'Yakovlev Yak-50', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Yakovlev', 'Yak-52', 'Yakovlev Yak-52', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Antonov
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Antonov', 'An-2', 'Antonov An-2 Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- ============================================
-- ДРУГИЕ ПРОИЗВОДИТЕЛИ
-- ============================================

-- Aermacchi
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aermacchi', 'MB-326', 'Aermacchi MB-326', 'single_engine', 'jet', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aero
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aero', '45', 'Aero 45', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Aero', 'AT-3', 'Aero AT-3', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aero Designs
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aero Designs', 'Pulsar', 'Aero Designs Pulsar', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aero East Europe
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aero East Europe', 'Sila 450 C', 'Aero East Europe Sila 450 C', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aerokopter
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aerokopter', 'ZA-6', 'Aerokopter ZA-6', 'helicopter', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aeropilot
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aeropilot', 'Legend 540', 'Aeropilot Legend 540', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Aeropilot', 'Legend 600', 'Aeropilot Legend 600', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aeroprakt
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aeroprakt', 'A-22', 'Aeroprakt A-22', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Aeroprakt', 'A-22L', 'Aeroprakt A-22 L', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Aeroprakt', 'A-22LS', 'Aeroprakt A-22 LS', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Aeroprakt', 'A-22LS600', 'Aeroprakt A-22 LS 600 kg', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Aeroprakt', 'A-32', 'Aeroprakt A-32', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Aeroprakt', 'A-32L', 'Aeroprakt A-32 L', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aeropro
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aeropro', 'A220', 'Aeropro A220', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aeros-Piuma Trike
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aeros-Piuma Trike', 'Discus T 13', 'Aeros-Piuma Trike Discus T 13', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aerosette
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aerosette', 'MH-46 Eclipse', 'Aerosette MH-46 Eclipse', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aerospatiale
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aerospatiale', 'Alouette 2', 'Aerospatiale Alouette 2', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Aerospatiale', 'Gazelle', 'Aerospatiale Gazelle', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aerospool
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aerospool', 'WT-9 Dynamic', 'Aerospool WT-9 Dynamic', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Aerospool', 'WT-9 Dynamic UL', 'Aerospool WT-9 Dynamic UL', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Aerospool', 'WT-9 Dynamic RG', 'Aerospool WT-9 Dynamic RG', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aerosport
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aerosport', 'CH-7 Kompress', 'Aerosport CH-7 Kompress 2', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Aerosport', 'Woody Pusher', 'Aerosport Woody Pusher', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Agusta
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Agusta', 'A-109', 'Agusta A-109', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true),
('Agusta', 'A-119', 'Agusta A-119 Koala', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Agusta-Bell
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Agusta-Bell', 'Bell 47G', 'Agusta-Bell Bell 47G', 'helicopter', 'piston', 1, 'https://www.planecheck.com/', true),
('Agusta-Bell', 'Bell 206', 'Agusta-Bell Bell 206', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Airbus Helicopters
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Airbus Helicopters', 'Colibri', 'Airbus Helicopters Eurocopter Colibri', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Airbus Helicopters', 'Ecureuil', 'Airbus Helicopters Ecureuil Series', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Airbus Helicopters', 'AS-355', 'Airbus Helicopters AS-355 Ecureuil 2', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true),
('Airbus Helicopters', 'EC-130', 'Airbus Helicopters EC-130', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Airbus Helicopters', 'EC-135', 'Airbus Helicopters EC-135', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Bell
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Bell', '206', 'Bell Bell 206', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Bell', '407', 'Bell 407', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Bell', '427', 'Bell 427', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true),
('Bell', '430', 'Bell 430', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true),
('Bell', '505', 'Bell 505 Jet Ranger X', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Bell', 'AH-1', 'Bell AH-1 HueyCobra', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Bellanca
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Bellanca', '7 Champion', 'Bellanca Aeronca 7 Champion Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Bellanca', '7 Citabria', 'Bellanca 7 Citabria Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Bombardier
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Bombardier', 'CL-600', 'Bombardier Canadair CL-600 Challenger', 'twin_engine', 'jet', 2, 'https://www.planecheck.com/', true),
('Bombardier', 'Learjet 45', 'Bombardier Learjet 45', 'twin_engine', 'jet', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- BRM Aero
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('BRM Aero', 'Bristell B23', 'BRM Aero Bristell B23', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('BRM Aero', 'Bristell NG-5', 'BRM Aero Bristell NG-5', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('BRM Aero', 'Bristell UL', 'BRM Aero Bristell UL', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('BRM Aero', 'Bristell UL RG', 'BRM Aero Bristell UL RG', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Bücker
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Bücker', 'Bü-131', 'Bücker Bü-131 Jungmann', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Bücker', 'Bü-133', 'Bücker Bü-133 Jungmeister', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Bücker', 'Bü-181', 'Bücker Bü-181 Bestmann', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- CASA
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('CASA', 'C-212', 'CASA C-212 Aviocar', 'twin_engine', 'turboprop', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Columbia
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Columbia', 'Cessna 400', 'Columbia Cessna 400', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Comco Ikarus
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Comco Ikarus', 'C42B', 'Comco Ikarus C42B', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Comco Ikarus', 'C42C', 'Comco Ikarus C42C', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Comco Ikarus', 'C42CS', 'Comco Ikarus C42CS', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Commander
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Commander', '112', 'Commander Commander 112', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Commander', '114', 'Commander Commander 114', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Commander', '115', 'Commander Commander 115', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- CSA / CZAW
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('CZAW', 'SportCruiser', 'CZAW SportCruiser / PiperSport Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('CZAW', 'SportCruiser 915iS', 'CZAW SportCruiser 915iS', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Daher
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Daher', 'TBM-900', 'Daher Socata TBM-900 Series', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Dallach
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Dallach', 'D-4 Fascination', 'Dallach D-4 Fascination', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Dallach', 'D-4 Fascination BK', 'Dallach D-4 Fascination BK', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Dassault
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Dassault', 'Falcon 50', 'Dassault Falcon 50', 'twin_engine', 'jet', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- De Havilland
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('De Havilland', 'DH-60', 'De Havilland DH-60 Moth', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('De Havilland', 'DH-82', 'De Havilland DH-82 Tiger Moth', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('De Havilland', 'DH-104', 'De Havilland DH-104 Dove', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('De Havilland', 'Vampire', 'De Havilland Vampire', 'single_engine', 'jet', 1, 'https://www.planecheck.com/', true),
('De Havilland', 'DHC-1', 'De Havilland DHC-1 Chipmunk', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Douglas
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Douglas', 'AD Skyraider', 'Douglas AD Skyraider', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Douglas', 'DC-3', 'Douglas DC-3 / C-47', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Eclipse
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Eclipse', '500', 'Eclipse 500/550', 'twin_engine', 'jet', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Embraer
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Embraer', 'EMB-500', 'Embraer EMB-500 Phenom 100', 'twin_engine', 'jet', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Enstrom
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Enstrom', 'F-28', 'Enstrom F-28 / 280', 'helicopter', 'piston', 1, 'https://www.planecheck.com/', true),
('Enstrom', '480', 'Enstrom 480(B)', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Eurocopter
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Eurocopter', 'Ecureuil', 'Eurocopter Ecureuil Series', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Eurocopter', 'AS-355', 'Eurocopter AS-355 Ecureuil 2', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true),
('Eurocopter', 'Colibri', 'Eurocopter Colibri', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Eurocopter', 'EC-130', 'Eurocopter EC-130', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true),
('Eurocopter', 'EC-135', 'Eurocopter EC-135', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Evektor
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Evektor', 'EV-97', 'Evektor EV-97 Eurostar', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Evektor', 'EV-97R', 'Evektor EV-97R Eurostar', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Evektor', 'SportStar', 'Evektor SportStar', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Extra
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Extra', '200', 'Extra 200', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Extra', '300', 'Extra 300', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Extra', '400', 'Extra 400', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Extra', '500', 'Extra 500', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Extra', 'NG', 'Extra NG', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Flight Design
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Flight Design', 'CT', 'Flight Design CT', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Flight Design', 'CTLS', 'Flight Design CTLS', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Flight Design', 'CTSW', 'Flight Design CTSW', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Flight Design', 'MC', 'Flight Design MC', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- ICP
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('ICP', 'Amigo', 'ICP Amigo', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('ICP', 'Bingo', 'ICP Bingo 4S', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('ICP', 'Savannah', 'ICP Savannah', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- JMB Aircraft
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('JMB Aircraft', 'VL-3', 'JMB Aircraft VL-3', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('JMB Aircraft', 'VL-3 Evolution', 'JMB Aircraft VL-3 Evolution', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('JMB Aircraft', 'VL-3 RG', 'JMB Aircraft VL-3 RG', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Jodel
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Jodel', 'D-9', 'Jodel D-9 Bébé ULM', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Jodel', 'D-11', 'Jodel D-11 / 110 / 120 Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Jodel', 'D-18', 'Jodel D-18 / D-19 / D-20', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Jodel', 'D-140', 'Jodel D-140', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Kamov
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Kamov', 'Ka-26', 'Kamov Ka-26', 'helicopter', 'piston', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Kitfox
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Kitfox', 'Mk IV', 'Kitfox Mk IV 912 speedster', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Lancair
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Lancair', '200', 'Lancair 200 / 235 / 320 / 360', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Lancair', '4', 'Lancair 4', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Lancair', 'Legacy', 'Lancair Legacy', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Maule
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Maule', 'M-4', 'Maule M-4', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Maule', 'M-5', 'Maule M-5', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Maule', 'M-7', 'Maule M-7 Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Mil
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Mil', 'Mi-2', 'Mil Mi-2 Series', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true),
('Mil', 'Mi-26', 'Mil Mi-26', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Partenavia
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Partenavia', 'P-64', 'Partenavia P-64 / 66', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('Partenavia', 'P-68', 'Partenavia P-68', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Pilatus
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Pilatus', 'P-2', 'Pilatus P-2', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Pilatus', 'P-3', 'Pilatus P-3', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Pilatus', 'PC-6', 'Pilatus PC-6 Turbo-Porter', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Pilatus', 'PC-9', 'Pilatus PC-9', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true),
('Pilatus', 'PC-12', 'Pilatus PC-12', 'single_engine', 'turboprop', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Pipistrel
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Pipistrel', 'Alpha Electro', 'Pipistrel Alpha Electro', 'ultralight', 'electric', 1, 'https://www.planecheck.com/', true),
('Pipistrel', 'Alpha Trainer', 'Pipistrel Alpha Trainer', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Pipistrel', 'Virus', 'Pipistrel Virus LSA Series', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Pipistrel', 'Panthera', 'Pipistrel Panthera', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Pipistrel', 'Sinus', 'Pipistrel Sinus', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Pipistrel', 'Taurus', 'Pipistrel Taurus', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Pipistrel', 'Velis Electro', 'Pipistrel Velis Electro', 'ultralight', 'electric', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Pitts
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Pitts', 'Model 12', 'Pitts Model 12 Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Pitts', 'S-1', 'Pitts S-1', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Pitts', 'S-2', 'Pitts S-2', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- PZL-Mielec
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('PZL-Mielec', 'An-2', 'PZL-Mielec An-2 Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- PZL-Okecie
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('PZL-Okecie', 'PZL-101', 'PZL-Okecie PZL-101 Gawron', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('PZL-Okecie', 'PZL-104', 'PZL-Okecie PZL-104 Wilga', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('PZL-Okecie', 'PZL-104M', 'PZL-Okecie PZL-104M Wilga 2000', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Remos
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Remos', 'GX', 'Remos GX', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Sikorsky
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Sikorsky', 'H-60', 'Sikorsky H-60 Black Hawk Series', 'helicopter', 'turbine', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Tecnam
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Tecnam', 'P-92', 'Tecnam P-92 Eaglet', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Tecnam', 'P-2002', 'Tecnam P-2002 Sierra', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Tecnam', 'P-2008', 'Tecnam P-2008', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Tecnam', 'P-2010', 'Tecnam P-2010', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Tecnam', 'P-2006T', 'Tecnam P-2006T', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Vans
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Vans', 'RV-4', 'Vans RV-4', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Vans', 'RV-6', 'Vans RV-6', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Vans', 'RV-7', 'Vans RV-7', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Vans', 'RV-8', 'Vans RV-8', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Vans', 'RV-9', 'Vans RV-9', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Vans', 'RV-10', 'Vans RV-10', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Vans', 'RV-12', 'Vans RV-12', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Vans', 'RV-14', 'Vans RV-14', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Vulcanair
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Vulcanair', 'P-68', 'Vulcanair P-68', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Zlin
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Zlin', 'Norden', 'Zlin Norden', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Zlin', 'Savage', 'Zlin Savage', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Zlin', 'Savage Cruiser', 'Zlin Savage Cruiser', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Zlin', 'Z-37', 'Zlin LET Z-37 Agro Turbo', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Zlin', 'Z-50', 'Zlin Z-50', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Zlin', 'Z-42', 'Zlin Z-42 / 142 / 242', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Zlin', 'Z-43', 'Zlin Z-43 / 143', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Zlin', 'Z-26', 'Zlin Z-26 Trener Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Alpi
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Alpi', 'Pioneer 200', 'Alpi Pioneer 200', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Alpi', 'Pioneer 300', 'Alpi Pioneer 300', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('Alpi', 'Pioneer 400', 'Alpi Pioneer 400', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- AutoGyro
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('AutoGyro', 'Calidus', 'AutoGyro Calidus', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('AutoGyro', 'Cavalon', 'AutoGyro Cavalon', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('AutoGyro', 'MTO', 'AutoGyro MTO', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true),
('AutoGyro', 'MTOSport', 'AutoGyro MTOSport Classic', 'ultralight', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Aviat
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Aviat', 'A-1', 'Aviat A-1 Husky', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Aviat', 'S-2', 'Aviat S-2', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Grumman American
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Grumman American', 'Yankee', 'Grumman American Yankee Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Grumman American', 'AA-5', 'Grumman American AA-5 Series', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Guimbal
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Guimbal', 'G-2', 'Guimbal G-2 Cabri', 'helicopter', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Lake
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Lake', 'LA-4', 'Lake LA-4 / 200 Renegade', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Lockheed
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Lockheed', 'C-130', 'Lockheed C-130 Hercules', 'twin_engine', 'turboprop', 4, 'https://www.planecheck.com/', true),
('Lockheed', 'L-12', 'Lockheed L-12 Electra Junior', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Luscombe
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Luscombe', '8', 'Luscombe 8 / Silvaire', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- North American
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('North American', 'B-25', 'North American B-25 Mitchell', 'twin_engine', 'piston', 2, 'https://www.planecheck.com/', true),
('North American', 'P-51', 'North American P-51 Mustang', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('North American', 'Texan', 'North American Texan / Harvard', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('North American', 'T-28', 'North American T-28 Trojan', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Raytheon
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Raytheon', '390', 'Raytheon 390 Premier 1', 'twin_engine', 'jet', 2, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Rotorway
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Rotorway', 'Exec', 'Rotorway Exec', 'helicopter', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Schweizer
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Schweizer', '200', 'Schweizer 200 - 300 Series', 'helicopter', 'turbine', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Stemme
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Stemme', 'S-10', 'Stemme S-10', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Stemme', 'S-12', 'Stemme S-12', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Stinson
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Stinson', 'SM-8A', 'Stinson SM-8A Detroiter', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Stinson', 'SR', 'Stinson SR Reliant', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- Sukhoi
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('Sukhoi', 'Su-26', 'Sukhoi Su-26', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('Sukhoi', 'Su-29', 'Sukhoi Su-29', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

-- XtremeAir
INSERT INTO aircraft_types (manufacturer, model, full_name, category, engine_type, engine_count, source_url, is_active) VALUES
('XtremeAir', 'XA42', 'XtremeAir XA42 / Sbach 342', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true),
('XtremeAir', 'XA41', 'XtremeAir XA41 / Sbach 300', 'single_engine', 'piston', 1, 'https://www.planecheck.com/', true)
ON CONFLICT (manufacturer, model) DO NOTHING;

COMMIT;

-- Статистика
SELECT 
    manufacturer,
    COUNT(*) as models_count
FROM aircraft_types
GROUP BY manufacturer
ORDER BY models_count DESC, manufacturer;

