-- Заполнение нормализованного каталога самолётов данными с PlaneCheck.com
-- Данные собраны с https://www.planecheck.com/
-- ПРИМЕЧАНИЕ: Для полного списка данных используйте insert_aircraft_catalog_data_full.sql

BEGIN;

-- ============================================
-- Вставка производителей
-- ============================================

INSERT INTO manufacturers (name, country, is_active) VALUES
('Cirrus', 'United States', true),
('Diamond', 'Austria', true),
('Mooney', 'United States', true),
('Piper', 'United States', true),
('Robin', 'France', true),
('Socata', 'France', true),
('Cessna', 'United States', true),
('Robinson', 'United States', true),
('Beechcraft', 'United States', true),
('Yakovlev', 'Russia', true),
('Antonov', 'Ukraine', true),
('Aermacchi', 'Italy', true),
('Aero', 'Czech Republic', true),
('Aero Designs', 'United States', true),
('Aero East Europe', 'Czech Republic', true),
('Aerokopter', 'Ukraine', true),
('Aeropilot', 'United States', true),
('Aeroprakt', 'Ukraine', true),
('Aeropro', 'Czech Republic', true),
('Aerospatiale', 'France', true),
('Aerospool', 'Slovakia', true),
('Aerosport', 'United States', true),
('Agusta', 'Italy', true),
('Agusta-Bell', 'Italy', true),
('Airbus Helicopters', 'France', true),
('Bell', 'United States', true),
('Bellanca', 'United States', true),
('Bombardier', 'Canada', true),
('BRM Aero', 'Czech Republic', true),
('Bücker', 'Germany', true),
('CASA', 'Spain', true),
('Columbia', 'United States', true),
('Comco Ikarus', 'Germany', true),
('Commander', 'United States', true),
('CZAW', 'Czech Republic', true),
('Daher', 'France', true),
('Dallach', 'Germany', true),
('Dassault', 'France', true),
('De Havilland', 'United Kingdom', true),
('Douglas', 'United States', true),
('Eclipse', 'United States', true),
('Embraer', 'Brazil', true),
('Enstrom', 'United States', true),
('Eurocopter', 'France', true),
('Evektor', 'Czech Republic', true),
('Extra', 'Germany', true),
('Flight Design', 'Germany', true),
('ICP', 'Italy', true),
('JMB Aircraft', 'Czech Republic', true),
('Jodel', 'France', true),
('Kamov', 'Russia', true),
('Kitfox', 'United States', true),
('Lancair', 'United States', true),
('Maule', 'United States', true),
('Mil', 'Russia', true),
('Partenavia', 'Italy', true),
('Pilatus', 'Switzerland', true),
('Pipistrel', 'Slovenia', true),
('Pitts', 'United States', true),
('PZL-Mielec', 'Poland', true),
('PZL-Okecie', 'Poland', true),
('Remos', 'Germany', true),
('Sikorsky', 'United States', true),
('Tecnam', 'Italy', true),
('Vans', 'United States', true),
('Vulcanair', 'Italy', true),
('Zlin', 'Czech Republic', true),
('Alpi', 'Italy', true),
('AutoGyro', 'Germany', true),
('Aviat', 'United States', true),
('Grumman American', 'United States', true),
('Guimbal', 'France', true),
('Lake', 'United States', true),
('Lockheed', 'United States', true),
('Luscombe', 'United States', true),
('North American', 'United States', true),
('Raytheon', 'United States', true),
('Rotorway', 'United States', true),
('Schweizer', 'United States', true),
('Stemme', 'Germany', true),
('Stinson', 'United States', true),
('Sukhoi', 'Russia', true),
('XtremeAir', 'Germany', true)
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- Вставка моделей самолётов
-- ============================================

-- Cirrus
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, 'SR20', 'Cirrus SR20', 'single_engine', 'piston', 1, true FROM manufacturers WHERE name = 'Cirrus'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, 'SR22', 'Cirrus SR22', 'single_engine', 'piston', 1, true FROM manufacturers WHERE name = 'Cirrus'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, 'SF50', 'Cirrus SF50 Vision Jet', 'single_engine', 'jet', 1, true FROM manufacturers WHERE name = 'Cirrus'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Diamond
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('DA20', 'Diamond DA20', 'single_engine', 'piston', 1),
    ('DA40', 'Diamond DA40 Star', 'single_engine', 'piston', 1),
    ('DA42', 'Diamond DA42 Twin Star', 'twin_engine', 'piston', 2),
    ('DA50', 'Diamond DA50 RG', 'single_engine', 'piston', 1),
    ('DA62', 'Diamond DA62', 'twin_engine', 'piston', 2)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Diamond'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Mooney
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('M20', 'Mooney M20 Series', 'single_engine', 'piston', 1),
    ('M20T', 'Mooney M20 Series (turbo)', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Mooney'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Piper (основные модели)
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('J-3', 'Piper J-3 Cub', 'single_engine', 'piston', 1),
    ('PA-18', 'Piper PA-18 Super Cub', 'single_engine', 'piston', 1),
    ('PA-28', 'Piper PA-28 Cherokee / Warrior / Archer', 'single_engine', 'piston', 1),
    ('PA-28R', 'Piper PA-28 Arrow', 'single_engine', 'piston', 1),
    ('PA-32', 'Piper PA-32 Cherokee 6 / Saratoga', 'single_engine', 'piston', 1),
    ('PA-34', 'Piper PA-34 Seneca', 'twin_engine', 'piston', 2),
    ('PA-38', 'Piper PA-38 Tomahawk', 'single_engine', 'piston', 1),
    ('PA-44', 'Piper PA-44 Seminole', 'twin_engine', 'piston', 2),
    ('PA-46', 'Piper PA-46 Malibu / Mirage', 'single_engine', 'piston', 1),
    ('PA-46M', 'Piper PA-46 Meridian', 'single_engine', 'turboprop', 1),
    ('PA-31', 'Piper PA-31 Navajo / Chieftain', 'twin_engine', 'piston', 2),
    ('PA-31T', 'Piper PA-31T Cheyenne', 'twin_engine', 'turboprop', 2)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Piper'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Cessna (основные модели)
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('172', 'Cessna 172 Skyhawk', 'single_engine', 'piston', 1),
    ('182', 'Cessna 182 Skylane', 'single_engine', 'piston', 1),
    ('206', 'Cessna 206 Stationair', 'single_engine', 'piston', 1),
    ('210', 'Cessna 210 Centurion', 'single_engine', 'piston', 1),
    ('310', 'Cessna 310', 'twin_engine', 'piston', 2),
    ('337', 'Cessna 337 Skymaster', 'twin_engine', 'piston', 2),
    ('402', 'Cessna 402', 'twin_engine', 'piston', 2),
    ('414', 'Cessna 414 Chancellor', 'twin_engine', 'piston', 2),
    ('421', 'Cessna 421 Golden Eagle', 'twin_engine', 'piston', 2),
    ('208', 'Cessna 208 Caravan', 'single_engine', 'turboprop', 1),
    ('Citation', 'Cessna Citation', 'twin_engine', 'jet', 2)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Cessna'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Robinson
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('R22', 'Robinson R-22', 'helicopter', 'piston', 1),
    ('R44', 'Robinson R-44', 'helicopter', 'piston', 1),
    ('R66', 'Robinson R-66', 'helicopter', 'turbine', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Robinson'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Beechcraft
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Bonanza', 'Beechcraft Bonanza', 'single_engine', 'piston', 1),
    ('Baron', 'Beechcraft Baron', 'twin_engine', 'piston', 2),
    ('King Air', 'Beechcraft King Air', 'twin_engine', 'turboprop', 2)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Beechcraft'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Yakovlev
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Yak-52', 'Yakovlev Yak-52', 'single_engine', 'piston', 1),
    ('Yak-18T', 'Yakovlev Yak-18T', 'single_engine', 'piston', 1),
    ('Yak-18', 'Yakovlev Yak-18', 'single_engine', 'piston', 1),
    ('Yak-50', 'Yakovlev Yak-50', 'single_engine', 'piston', 1),
    ('Yak-11', 'Yakovlev Yak-11', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Yakovlev'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Antonov
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, 'An-2', 'Antonov An-2', 'single_engine', 'piston', 1, true 
FROM manufacturers WHERE name = 'Antonov'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Socata
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('TB-9', 'Socata TB-9 Tampico', 'single_engine', 'piston', 1),
    ('TB-10', 'Socata TB-10 Tobago', 'single_engine', 'piston', 1),
    ('TB-20', 'Socata TB-20 Trinidad', 'single_engine', 'piston', 1),
    ('TBM-700', 'Socata TBM-700', 'single_engine', 'turboprop', 1),
    ('TBM-850', 'Socata TBM-850', 'single_engine', 'turboprop', 1),
    ('TBM-900', 'Socata TBM-900', 'single_engine', 'turboprop', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Socata'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Tecnam
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('P-92', 'Tecnam P-92 Eaglet', 'ultralight', 'piston', 1),
    ('P-2002', 'Tecnam P-2002 Sierra', 'ultralight', 'piston', 1),
    ('P-2008', 'Tecnam P-2008', 'ultralight', 'piston', 1),
    ('P-2010', 'Tecnam P-2010', 'single_engine', 'piston', 1),
    ('P-2006T', 'Tecnam P-2006T', 'twin_engine', 'piston', 2)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Tecnam'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Vans
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('RV-4', 'Vans RV-4', 'single_engine', 'piston', 1),
    ('RV-6', 'Vans RV-6', 'single_engine', 'piston', 1),
    ('RV-7', 'Vans RV-7', 'single_engine', 'piston', 1),
    ('RV-8', 'Vans RV-8', 'single_engine', 'piston', 1),
    ('RV-9', 'Vans RV-9', 'single_engine', 'piston', 1),
    ('RV-10', 'Vans RV-10', 'single_engine', 'piston', 1),
    ('RV-12', 'Vans RV-12', 'ultralight', 'piston', 1),
    ('RV-14', 'Vans RV-14', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Vans'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Pipistrel
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Alpha Electro', 'Pipistrel Alpha Electro', 'ultralight', 'electric', 1),
    ('Alpha Trainer', 'Pipistrel Alpha Trainer', 'ultralight', 'piston', 1),
    ('Virus', 'Pipistrel Virus LSA', 'ultralight', 'piston', 1),
    ('Panthera', 'Pipistrel Panthera', 'single_engine', 'piston', 1),
    ('Sinus', 'Pipistrel Sinus', 'ultralight', 'piston', 1),
    ('Taurus', 'Pipistrel Taurus', 'ultralight', 'piston', 1),
    ('Velis Electro', 'Pipistrel Velis Electro', 'ultralight', 'electric', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Pipistrel'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Flight Design
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('CT', 'Flight Design CT', 'ultralight', 'piston', 1),
    ('CTLS', 'Flight Design CTLS', 'ultralight', 'piston', 1),
    ('CTSW', 'Flight Design CTSW', 'ultralight', 'piston', 1),
    ('MC', 'Flight Design MC', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Flight Design'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Evektor
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('EV-97', 'Evektor EV-97 Eurostar', 'ultralight', 'piston', 1),
    ('EV-97R', 'Evektor EV-97R Eurostar', 'ultralight', 'piston', 1),
    ('SportStar', 'Evektor SportStar', 'ultralight', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Evektor'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- ICP
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Amigo', 'ICP Amigo', 'ultralight', 'piston', 1),
    ('Bingo', 'ICP Bingo 4S', 'ultralight', 'piston', 1),
    ('Savannah', 'ICP Savannah', 'ultralight', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'ICP'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- JMB Aircraft
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('VL-3', 'JMB Aircraft VL-3', 'ultralight', 'piston', 1),
    ('VL-3 Evolution', 'JMB Aircraft VL-3 Evolution', 'ultralight', 'piston', 1),
    ('VL-3 RG', 'JMB Aircraft VL-3 RG', 'ultralight', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'JMB Aircraft'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Jodel
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('D-9', 'Jodel D-9 Bébé ULM', 'ultralight', 'piston', 1),
    ('D-11', 'Jodel D-11 / 110 / 120', 'single_engine', 'piston', 1),
    ('D-18', 'Jodel D-18 / D-19 / D-20', 'single_engine', 'piston', 1),
    ('D-140', 'Jodel D-140', 'single_engine', 'piston', 1),
    ('DR-100', 'Jodel DR-100 / 1050', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Jodel'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Zlin
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Norden', 'Zlin Norden', 'ultralight', 'piston', 1),
    ('Savage', 'Zlin Savage', 'ultralight', 'piston', 1),
    ('Savage Cruiser', 'Zlin Savage Cruiser', 'ultralight', 'piston', 1),
    ('Z-37', 'Zlin LET Z-37 Agro Turbo', 'single_engine', 'piston', 1),
    ('Z-50', 'Zlin Z-50', 'single_engine', 'piston', 1),
    ('Z-42', 'Zlin Z-42 / 142 / 242', 'single_engine', 'piston', 1),
    ('Z-43', 'Zlin Z-43 / 143', 'single_engine', 'piston', 1),
    ('Z-26', 'Zlin Z-26 Trener', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Zlin'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Aeroprakt
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('A-22', 'Aeroprakt A-22', 'ultralight', 'piston', 1),
    ('A-22L', 'Aeroprakt A-22 L', 'ultralight', 'piston', 1),
    ('A-22LS', 'Aeroprakt A-22 LS', 'ultralight', 'piston', 1),
    ('A-32', 'Aeroprakt A-32', 'ultralight', 'piston', 1),
    ('A-32L', 'Aeroprakt A-32 L', 'ultralight', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Aeroprakt'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- PZL-Okecie
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('PZL-101', 'PZL-Okecie PZL-101 Gawron', 'single_engine', 'piston', 1),
    ('PZL-104', 'PZL-Okecie PZL-104 Wilga', 'single_engine', 'piston', 1),
    ('PZL-104M', 'PZL-Okecie PZL-104M Wilga 2000', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'PZL-Okecie'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Pilatus
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('P-2', 'Pilatus P-2', 'single_engine', 'piston', 1),
    ('P-3', 'Pilatus P-3', 'single_engine', 'piston', 1),
    ('PC-6', 'Pilatus PC-6 Turbo-Porter', 'single_engine', 'turboprop', 1),
    ('PC-9', 'Pilatus PC-9', 'single_engine', 'turboprop', 1),
    ('PC-12', 'Pilatus PC-12', 'single_engine', 'turboprop', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Pilatus'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Alpi
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Pioneer 200', 'Alpi Pioneer 200', 'ultralight', 'piston', 1),
    ('Pioneer 300', 'Alpi Pioneer 300', 'ultralight', 'piston', 1),
    ('Pioneer 400', 'Alpi Pioneer 400', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Alpi'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- AutoGyro
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Calidus', 'AutoGyro Calidus', 'ultralight', 'piston', 1),
    ('Cavalon', 'AutoGyro Cavalon', 'ultralight', 'piston', 1),
    ('MTO', 'AutoGyro MTO', 'ultralight', 'piston', 1),
    ('MTOSport', 'AutoGyro MTOSport Classic', 'ultralight', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'AutoGyro'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Aviat
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('A-1', 'Aviat A-1 Husky', 'single_engine', 'piston', 1),
    ('S-2', 'Aviat S-2', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Aviat'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Grumman American
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Yankee', 'Grumman American Yankee', 'single_engine', 'piston', 1),
    ('AA-5', 'Grumman American AA-5', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Grumman American'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Guimbal
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, 'G-2', 'Guimbal G-2 Cabri', 'helicopter', 'piston', 1, true 
FROM manufacturers WHERE name = 'Guimbal'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Lake
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, 'LA-4', 'Lake LA-4 / 200 Renegade', 'single_engine', 'piston', 1, true 
FROM manufacturers WHERE name = 'Lake'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Lockheed
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('C-130', 'Lockheed C-130 Hercules', 'twin_engine', 'turboprop', 4),
    ('L-12', 'Lockheed L-12 Electra Junior', 'twin_engine', 'piston', 2)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Lockheed'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Luscombe
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, '8', 'Luscombe 8 / Silvaire', 'single_engine', 'piston', 1, true 
FROM manufacturers WHERE name = 'Luscombe'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- North American
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('B-25', 'North American B-25 Mitchell', 'twin_engine', 'piston', 2),
    ('P-51', 'North American P-51 Mustang', 'single_engine', 'piston', 1),
    ('Texan', 'North American Texan / Harvard', 'single_engine', 'piston', 1),
    ('T-28', 'North American T-28 Trojan', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'North American'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Raytheon
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, '390', 'Raytheon 390 Premier 1', 'twin_engine', 'jet', 2, true 
FROM manufacturers WHERE name = 'Raytheon'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Rotorway
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, 'Exec', 'Rotorway Exec', 'helicopter', 'piston', 1, true 
FROM manufacturers WHERE name = 'Rotorway'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Schweizer
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, '200', 'Schweizer 200 - 300 Series', 'helicopter', 'turbine', 1, true 
FROM manufacturers WHERE name = 'Schweizer'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Stemme
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('S-10', 'Stemme S-10', 'single_engine', 'piston', 1),
    ('S-12', 'Stemme S-12', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Stemme'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Stinson
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('SM-8A', 'Stinson SM-8A Detroiter', 'single_engine', 'piston', 1),
    ('SR', 'Stinson SR Reliant', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Stinson'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Sukhoi
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Su-26', 'Sukhoi Su-26', 'single_engine', 'piston', 1),
    ('Su-29', 'Sukhoi Su-29', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Sukhoi'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- XtremeAir
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('XA42', 'XtremeAir XA42 / Sbach 342', 'single_engine', 'piston', 1),
    ('XA41', 'XtremeAir XA41 / Sbach 300', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'XtremeAir'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Bell
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('206', 'Bell Bell 206', 'helicopter', 'turbine', 1),
    ('407', 'Bell 407', 'helicopter', 'turbine', 1),
    ('427', 'Bell 427', 'helicopter', 'turbine', 2),
    ('430', 'Bell 430', 'helicopter', 'turbine', 2),
    ('505', 'Bell 505 Jet Ranger X', 'helicopter', 'turbine', 1),
    ('AH-1', 'Bell AH-1 HueyCobra', 'helicopter', 'turbine', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Bell'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Extra
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('200', 'Extra 200', 'single_engine', 'piston', 1),
    ('300', 'Extra 300', 'single_engine', 'piston', 1),
    ('400', 'Extra 400', 'single_engine', 'piston', 1),
    ('500', 'Extra 500', 'single_engine', 'piston', 1),
    ('NG', 'Extra NG', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Extra'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Pitts
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Model 12', 'Pitts Model 12 Series', 'single_engine', 'piston', 1),
    ('S-1', 'Pitts S-1', 'single_engine', 'piston', 1),
    ('S-2', 'Pitts S-2', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Pitts'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

COMMIT;

-- Статистика
SELECT 
    m.name as manufacturer,
    COUNT(am.id) as models_count
FROM manufacturers m
LEFT JOIN aircraft_models am ON m.id = am.manufacturer_id AND am.is_active = true
WHERE m.is_active = true
GROUP BY m.id, m.name
ORDER BY models_count DESC, m.name;

