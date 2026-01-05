-- Заполнение нормализованного каталога самолётов полными данными с PlaneCheck.com
-- Данные собраны с https://www.planecheck.com/
-- ВНИМАНИЕ: Этот файл содержит ОГРОМНОЕ количество данных. Запуск может занять время.

BEGIN;

-- ============================================
-- Вставка всех производителей
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
('Aerosviluppi', 'Italy', true),
('Aerotechnik', 'Czech Republic', true),
('Agusta', 'Italy', true),
('Agusta-Bell', 'Italy', true),
('Airbus Helicopters', 'France', true),
('Airdrome', 'United States', true),
('Airlony', 'United States', true),
('Airplane Factory', 'South Africa', true),
('Albastar', 'France', true),
('Alpi', 'Italy', true),
('Altitude', 'United States', true),
('Altus', 'United States', true),
('AMC', 'United States', true),
('American Champion', 'United States', true),
('Antonov', 'Ukraine', true),
('Apollo', 'United Kingdom', true),
('Aquila', 'Germany', true),
('ATEC', 'Czech Republic', true),
('Auster', 'United Kingdom', true),
('AutoGyro', 'Germany', true),
('Aviat', 'United States', true),
('Aviation Scotland', 'United Kingdom', true),
('AVIO-SMA', 'United States', true),
('AVRO', 'United Kingdom', true),
('Beagle', 'United Kingdom', true),
('Bell', 'United States', true),
('Bellanca', 'United States', true),
('Belmont', 'United States', true),
('Blackshape', 'Italy', true),
('Blackwing', 'United States', true),
('Boeing Stearman', 'United States', true),
('Bölkow', 'Germany', true),
('Boisavia', 'France', true),
('Bombardier', 'Canada', true),
('Brandli', 'Switzerland', true),
('Breezer', 'Germany', true),
('British Aerospace', 'United Kingdom', true),
('Britten-Norman', 'United Kingdom', true),
('BRM', 'United States', true),
('BRM Aero', 'Czech Republic', true),
('Bücker', 'Germany', true),
('Campavia', 'France', true),
('CASA', 'Spain', true),
('Cassutt', 'United States', true),
('Celier', 'Poland', true),
('CFM', 'United States', true),
('Coavio', 'Italy', true),
('Columbia', 'United States', true),
('Comco', 'Germany', true),
('Comco Ikarus', 'Germany', true),
('Commander', 'United States', true),
('CSA', 'Czech Republic', true),
('CZAW', 'Czech Republic', true),
('CzechMade', 'Czech Republic', true),
('Daher', 'France', true),
('Dallach', 'Germany', true),
('Dassault', 'France', true),
('Dassault-Breguet', 'France', true),
('De Havilland', 'United Kingdom', true),
('Deperdussin', 'France', true),
('Direct Fly', 'Slovakia', true),
('Dornier', 'Germany', true),
('Douglas', 'United States', true),
('Dova', 'Czech Republic', true),
('DTA', 'France', true),
('DynAero', 'France', true),
('Dynali', 'Belgium', true),
('EAA', 'United States', true),
('Eclipse', 'United States', true),
('EDM Aerotec', 'Germany', true),
('EDRA', 'Brazil', true),
('Ekolot', 'Poland', true),
('Ellipse', 'France', true),
('Embraer', 'Brazil', true),
('Enstrom', 'United States', true),
('Erco', 'United States', true),
('Eurocopter', 'France', true),
('Evektor', 'Czech Republic', true),
('Extra', 'Germany', true),
('Fairchild', 'United States', true),
('FAJ Jastreb', 'Serbia', true),
('FAMA', 'Argentina', true),
('Fantasy Air', 'Italy', true),
('FD-Composites', 'Austria', true),
('FFA', 'Switzerland', true),
('FIAT', 'Italy', true),
('Fieseler', 'Germany', true),
('Fisher', 'United States', true),
('FK', 'Germany', true),
('FK-Lightplanes', 'Germany', true),
('Fletcher', 'New Zealand', true),
('Flight Constructive', 'United Kingdom', true),
('Flight Design', 'Germany', true),
('Fly Synthesis', 'Italy', true),
('Fly-Fan', 'United States', true),
('Focke-Wulf', 'Germany', true),
('Fokker', 'Netherlands', true),
('Folland', 'United Kingdom', true),
('Fouga', 'France', true),
('Fournier', 'France', true),
('FVA', 'Germany', true),
('G1 Aviation', 'United Kingdom', true),
('Gardan', 'France', true),
('General Avia', 'Italy', true),
('Gippsland', 'Australia', true),
('Glasair', 'United States', true),
('Glaser-Dirks', 'Germany', true),
('Globe', 'United States', true),
('Gogetair', 'France', true),
('Golden Avio', 'Italy', true),
('Grob', 'Germany', true),
('Groppo', 'Italy', true),
('Grumman American', 'United States', true),
('Guimbal', 'France', true),
('Gyroflug', 'Germany', true),
('Halley', 'United Kingdom', true),
('Harmon', 'United States', true),
('Hawker', 'United Kingdom', true),
('Heli-Sport', 'Italy', true),
('Hirth', 'Germany', true),
('Hoffmann', 'Austria', true),
('IAR', 'Romania', true),
('ICA', 'Romania', true),
('ICP', 'Italy', true),
('Jabiru', 'Australia', true),
('JMB Aircraft', 'Czech Republic', true),
('Jodel', 'France', true),
('Jurca', 'France', true),
('Just', 'United States', true),
('Kamov', 'Russia', true),
('Kappa 77', 'Czech Republic', true),
('KFA', 'United States', true),
('Kitfox', 'United States', true),
('Klemm', 'Germany', true),
('Kubicek', 'Czech Republic', true),
('LAK', 'Latvia', true),
('Lake', 'United States', true),
('Lancair', 'United States', true),
('Laser', 'United States', true),
('LET', 'Czech Republic', true),
('Lockheed', 'United States', true),
('Luscombe', 'United States', true),
('Magnaghi', 'Italy', true),
('Magni', 'Italy', true),
('Manuf. Aeron.', 'Italy', true),
('Maule', 'United States', true),
('Max Holste', 'France', true),
('MBB Eurocopter', 'Germany', true),
('McDonnell Douglas', 'United States', true),
('Messerschmitt', 'Germany', true),
('Mil', 'Russia', true),
('Miles', 'United Kingdom', true),
('Mitsubishi', 'Japan', true),
('Monocoupe', 'United States', true),
('Morane', 'France', true),
('Motodelta', 'Italy', true),
('Mudry', 'France', true),
('Murphy', 'Canada', true),
('Mylius', 'France', true),
('Nando Groppo', 'Italy', true),
('Naval Aircraft Factory', 'United States', true),
('Neukom', 'Switzerland', true),
('NEW AVIO C205', 'Italy', true),
('Nicollier', 'Switzerland', true),
('Nord', 'France', true),
('Norman', 'United Kingdom', true),
('North American', 'United States', true),
('Oberlerchner', 'Austria', true),
('OMF', 'Germany', true),
('Orlican', 'Czech Republic', true),
('Partenavia', 'Italy', true),
('Pavel Míšek', 'Czech Republic', true),
('Pelegrin', 'France', true),
('Piaggio', 'Italy', true),
('Piel', 'France', true),
('Pietenpol', 'United States', true),
('Pilatus', 'Switzerland', true),
('Pipistrel', 'Slovenia', true),
('Pitts', 'United States', true),
('Polaris Motor', 'Italy', true),
('Porto', 'Italy', true),
('Promecc', 'Italy', true),
('PZL-Mielec', 'Poland', true),
('PZL-Okecie', 'Poland', true),
('Quicksilver', 'United States', true),
('Rans', 'United States', true),
('Raytheon', 'United States', true),
('Remos', 'Germany', true),
('Renaissance', 'United States', true),
('Republic', 'United States', true),
('Robinson', 'United States', true),
('Rockwell', 'United States', true),
('Roko', 'Czech Republic', true),
('Rotary Air Force', 'Canada', true),
('Rotorsport', 'United Kingdom', true),
('Rotorway', 'United States', true),
('Ruschmeyer', 'Germany', true),
('Rutan', 'United States', true),
('SAAB', 'Sweden', true),
('SAI', 'Denmark', true),
('Scheibe', 'Germany', true),
('Schempp-Hirth', 'Germany', true),
('Schleicher', 'Germany', true),
('Schweizer', 'United States', true),
('Sequoia', 'Italy', true),
('SG', 'Germany', true),
('Shark Aero', 'Czech Republic', true),
('Sherwood Ranger', 'United Kingdom', true),
('Short', 'United Kingdom', true),
('SIAI-Marchetti', 'Italy', true),
('Sikorsky', 'United States', true),
('SkyCruiser', 'United States', true),
('Skyleader', 'Czech Republic', true),
('Slingsby', 'United Kingdom', true),
('Sonaca', 'Belgium', true),
('Sonex', 'United States', true),
('Sopwith', 'United Kingdom', true),
('Spacek', 'Czech Republic', true),
('Stampe', 'Belgium', true),
('Steen', 'United States', true),
('Stemme', 'Germany', true),
('Stern', 'Germany', true),
('Stinson', 'United States', true),
('Stolp', 'United States', true),
('Storm', 'United States', true),
('Sukhoi', 'Russia', true),
('Supermarine Aircraft', 'United Kingdom', true),
('SZD', 'Poland', true),
('TEAM', 'United States', true),
('Technoavia', 'Russia', true),
('Tecnam', 'Italy', true),
('Ted Smith', 'United States', true),
('Titan', 'United States', true),
('TL Ultralight', 'Czech Republic', true),
('Tomark', 'Slovakia', true),
('Travel Air', 'United States', true),
('Trixy', 'Germany', true),
('UL-JIH Sedlacek', 'Czech Republic', true),
('ULBI', 'United States', true),
('Ultravia', 'Canada', true),
('Uniplanes-Dornier', 'Germany', true),
('Urban', 'Germany', true),
('Urban Air', 'Germany', true),
('Vans', 'United States', true),
('Velocity', 'United States', true),
('Vogt', 'Germany', true),
('Vought', 'United States', true),
('Vulcanair', 'Italy', true),
('WACO', 'United States', true),
('WAR', 'Germany', true),
('Wassmer', 'France', true),
('Wheeler', 'United States', true),
('XtremeAir', 'Germany', true),
('Yakovlev', 'Russia', true),
('Zenair', 'Canada', true),
('Zenith', 'United States', true),
('Zlin', 'Czech Republic', true)
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- Вставка моделей самолётов
-- ============================================

-- Cirrus
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('SR20', 'Cirrus SR20', 'single_engine', 'piston', 1),
    ('SRV', 'Cirrus SR20 / SRV', 'single_engine', 'piston', 1),
    ('SR22', 'Cirrus SR22', 'single_engine', 'piston', 1),
    ('SF50', 'Cirrus SF50 Vision Jet', 'single_engine', 'jet', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Cirrus'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Diamond
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('DA20', 'Diamond DA20 / DV20', 'single_engine', 'piston', 1),
    ('DV20', 'Diamond DA20 / DV20', 'single_engine', 'piston', 1),
    ('Dimona', 'Diamond Super Dimona', 'single_engine', 'piston', 1),
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
    ('M20', 'Mooney M20 Series (normally-aspirated)', 'single_engine', 'piston', 1),
    ('M20T', 'Mooney M20 Series (turbo)', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Mooney'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Piper (полный список моделей)
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('J-3', 'Piper J-3 Cub Series', 'single_engine', 'piston', 1),
    ('J-5', 'Piper J-5 Cub Cruiser', 'single_engine', 'piston', 1),
    ('PA-18', 'Piper PA-18 Super Cub', 'single_engine', 'piston', 1),
    ('PA-22', 'Piper PA-22 Colt / Tri-Pacer', 'single_engine', 'piston', 1),
    ('PA-23', 'Piper PA-23 Apache', 'twin_engine', 'piston', 2),
    ('PA-23A', 'Piper PA-23 Aztec', 'twin_engine', 'piston', 2),
    ('PA-24', 'Piper PA-24 Comanche', 'single_engine', 'piston', 1),
    ('PA-25', 'Piper PA-25 Pawnee', 'single_engine', 'piston', 1),
    ('PA-28', 'Piper PA-28 Cherokee / Warrior / Archer', 'single_engine', 'piston', 1),
    ('PA-28D', 'Piper PA-28 Cherokee / Dakota', 'single_engine', 'piston', 1),
    ('PA-28R', 'Piper PA-28 Arrow Series', 'single_engine', 'piston', 1),
    ('PA-28RT', 'Piper PA-28 Arrow Series (turbo)', 'single_engine', 'piston', 1),
    ('PA-30', 'Piper Twin Comanche', 'twin_engine', 'piston', 2),
    ('PA-31', 'Piper PA-31 Navajo / Chieftain', 'twin_engine', 'piston', 2),
    ('PA-31T', 'Piper PA-31T-500 Cheyenne', 'twin_engine', 'turboprop', 2),
    ('PA-31T2', 'Piper PA-31 Cheyenne II', 'twin_engine', 'turboprop', 2),
    ('PA-32', 'Piper PA-32 Cherokee 6 / Saratoga', 'single_engine', 'piston', 1),
    ('PA-32R', 'Piper PA-32 Lance / Saratoga (retractable)', 'single_engine', 'piston', 1),
    ('PA-32RT', 'Piper PA-32 Lance II', 'single_engine', 'piston', 1),
    ('PA-34', 'Piper PA-34 Seneca', 'twin_engine', 'piston', 2),
    ('PA-38', 'Piper PA-38 Tomahawk', 'single_engine', 'piston', 1),
    ('PA-44', 'Piper PA-44 Seminole', 'twin_engine', 'piston', 2),
    ('PA-46', 'Piper PA-46 Malibu / Mirage', 'single_engine', 'piston', 1),
    ('PA-46M', 'Piper PA-46 Meridian / JetPROP DLX', 'single_engine', 'turboprop', 1),
    ('PA-46-701TP', 'Piper PA-46-701TP M700', 'single_engine', 'turboprop', 1),
    ('Aerostar', 'Piper Aerostar', 'twin_engine', 'piston', 2)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Piper'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Robin
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('DR-220', 'Robin DR-220 / 221', 'single_engine', 'piston', 1),
    ('DR-200', 'Robin DR-200 / 250', 'single_engine', 'piston', 1),
    ('DR-253', 'Robin DR-253 Régent', 'single_engine', 'piston', 1),
    ('DR-300', 'Robin DR-300 Series', 'single_engine', 'piston', 1),
    ('DR-400', 'Robin DR-400 / 500', 'single_engine', 'piston', 1),
    ('HR-100', 'Robin HR-100', 'single_engine', 'piston', 1),
    ('HR-200', 'Robin HR-200', 'single_engine', 'piston', 1),
    ('R-1180', 'Robin R-1180 Aiglon', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Robin'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Socata
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Rallye', 'Socata Rallye', 'single_engine', 'piston', 1),
    ('ST-10', 'Socata ST-10', 'single_engine', 'piston', 1),
    ('TB-9', 'Socata TB-9 Tampico', 'single_engine', 'piston', 1),
    ('TB-10', 'Socata TB-10 / 200 Tobago', 'single_engine', 'piston', 1),
    ('TB-20', 'Socata TB-20 / 21 Trinidad', 'single_engine', 'piston', 1),
    ('TB-30', 'Socata TB-30 Epsilon', 'single_engine', 'piston', 1),
    ('TBM-700', 'Socata TBM-700', 'single_engine', 'turboprop', 1),
    ('TBM-850', 'Socata TBM-850', 'single_engine', 'turboprop', 1),
    ('TBM-900', 'Socata TBM-900 Series', 'single_engine', 'turboprop', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Socata'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Cessna (расширенный список)
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('150', 'Cessna 150', 'single_engine', 'piston', 1),
    ('152', 'Cessna 152', 'single_engine', 'piston', 1),
    ('172', 'Cessna 172 Skyhawk', 'single_engine', 'piston', 1),
    ('175', 'Cessna 175 Skylark', 'single_engine', 'piston', 1),
    ('177', 'Cessna 177 Cardinal', 'single_engine', 'piston', 1),
    ('180', 'Cessna 180 Skywagon', 'single_engine', 'piston', 1),
    ('182', 'Cessna 182 Skylane', 'single_engine', 'piston', 1),
    ('185', 'Cessna 185 Skywagon', 'single_engine', 'piston', 1),
    ('188', 'Cessna 188 Agwagon', 'single_engine', 'piston', 1),
    ('190', 'Cessna 190', 'single_engine', 'piston', 1),
    ('195', 'Cessna 195', 'single_engine', 'piston', 1),
    ('206', 'Cessna 206 Stationair', 'single_engine', 'piston', 1),
    ('207', 'Cessna 207 Skywagon', 'single_engine', 'piston', 1),
    ('210', 'Cessna 210 Centurion', 'single_engine', 'piston', 1),
    ('305', 'Cessna 305 Bird Dog', 'single_engine', 'piston', 1),
    ('310', 'Cessna 310', 'twin_engine', 'piston', 2),
    ('320', 'Cessna 320 Skyknight', 'twin_engine', 'piston', 2),
    ('335', 'Cessna 335', 'twin_engine', 'piston', 2),
    ('336', 'Cessna 336 Skymaster', 'twin_engine', 'piston', 2),
    ('337', 'Cessna 337 Skymaster', 'twin_engine', 'piston', 2),
    ('340', 'Cessna 340', 'twin_engine', 'piston', 2),
    ('402', 'Cessna 402', 'twin_engine', 'piston', 2),
    ('404', 'Cessna 404 Titan', 'twin_engine', 'piston', 2),
    ('411', 'Cessna 411', 'twin_engine', 'piston', 2),
    ('414', 'Cessna 414 Chancellor', 'twin_engine', 'piston', 2),
    ('421', 'Cessna 421 Golden Eagle', 'twin_engine', 'piston', 2),
    ('425', 'Cessna 425 Corsair', 'twin_engine', 'turboprop', 2),
    ('441', 'Cessna 441 Conquest', 'twin_engine', 'turboprop', 2),
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
    ('R66', 'Robinson R-66', 'helicopter', 'turbine', 1),
    ('R22T', 'Robinson R22 CL02 Turbine', 'helicopter', 'turbine', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Robinson'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Beechcraft (расширенный список)
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Bonanza', 'Beechcraft Bonanza', 'single_engine', 'piston', 1),
    ('Baron', 'Beechcraft Baron', 'twin_engine', 'piston', 2),
    ('King Air', 'Beechcraft King Air', 'twin_engine', 'turboprop', 2),
    ('Travel Air', 'Beechcraft Travel Air', 'twin_engine', 'piston', 2),
    ('Twin Beech', 'Beechcraft Twin Beech', 'twin_engine', 'piston', 2),
    ('Model 18', 'Beechcraft Model 18', 'twin_engine', 'piston', 2),
    ('Staggerwing', 'Beechcraft Staggerwing', 'single_engine', 'piston', 1),
    ('Musketeer', 'Beechcraft Musketeer', 'single_engine', 'piston', 1),
    ('Sundowner', 'Beechcraft Sundowner', 'single_engine', 'piston', 1),
    ('Sierra', 'Beechcraft Sierra', 'single_engine', 'piston', 1),
    ('Debonair', 'Beechcraft Debonair', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Beechcraft'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Yakovlev
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('Yak-3', 'Yakovlev Yak-3', 'single_engine', 'piston', 1),
    ('Yak-9', 'Yakovlev Yak-9', 'single_engine', 'piston', 1),
    ('Yak-11', 'Yakovlev Yak-11', 'single_engine', 'piston', 1),
    ('Yak-18', 'Yakovlev Yak-18', 'single_engine', 'piston', 1),
    ('Yak-18T', 'Yakovlev Yak-18T', 'single_engine', 'piston', 1),
    ('Yak-50', 'Yakovlev Yak-50', 'single_engine', 'piston', 1),
    ('Yak-52', 'Yakovlev Yak-52', 'single_engine', 'piston', 1),
    ('Yak-55', 'Yakovlev Yak-55', 'single_engine', 'piston', 1),
    ('Yak-54', 'Yakovlev Yak-54', 'single_engine', 'piston', 1)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Yakovlev'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Antonov
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, 'An-2', 'Antonov An-2', 'single_engine', 'piston', 1, true 
FROM manufacturers WHERE name = 'Antonov'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Tecnam (полный список)
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('P-92', 'Tecnam P-92 Eaglet', 'ultralight', 'piston', 1),
    ('P-92 Echo', 'Tecnam P-92 Echo', 'ultralight', 'piston', 1),
    ('P-92 S', 'Tecnam P-92 S', 'ultralight', 'piston', 1),
    ('P-96 Golf', 'Tecnam P-96 Golf', 'ultralight', 'piston', 1),
    ('P-2002', 'Tecnam P-2002 Sierra', 'ultralight', 'piston', 1),
    ('P-2008', 'Tecnam P-2008', 'ultralight', 'piston', 1),
    ('P-2010', 'Tecnam P-2010', 'single_engine', 'piston', 1),
    ('P-2006T', 'Tecnam P-2006T', 'twin_engine', 'piston', 2)
) AS v(model_code, full_name, category, engine_type, engine_count)
CROSS JOIN manufacturers WHERE manufacturers.name = 'Tecnam'
ON CONFLICT (manufacturer_id, model_code) DO NOTHING;

-- Vans (полный список)
INSERT INTO aircraft_models (manufacturer_id, model_code, full_name, category, engine_type, engine_count, is_active)
SELECT id, model_code, full_name, category, engine_type, engine_count, true 
FROM (VALUES
    ('RV-3', 'Vans RV-3', 'single_engine', 'piston', 1),
    ('RV-4', 'Vans RV-4', 'single_engine', 'piston', 1),
    ('RV-6', 'Vans RV-6', 'single_engine', 'piston', 1),
    ('RV-7', 'Vans RV-7', 'single_engine', 'piston', 1),
    ('RV-8', 'Vans RV-8', 'single_engine', 'piston', 1),
    ('RV-9', 'Vans RV-9', 'single_engine', 'piston', 1),
    ('RV-10', 'Vans RV-10', 'single_engine', 'piston', 1),
    ('RV-12', 'Vans RV-12', 'ultralight', 'piston', 1),
    ('RV-14', 'Vans RV-14', 'single_engine', 'piston', 1),
    ('RV-15', 'Vans RV-15', 'single_engine', 'piston', 1)
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

-- Aeroprakt (важные модели для России/Украины)
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
ORDER BY models_count DESC, m.name
LIMIT 50;

