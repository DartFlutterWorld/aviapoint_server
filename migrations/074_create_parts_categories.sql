-- Миграция 074: Создание полного каталога категорий запчастей
-- Структура: parts_main_categories (типы техники) -> parts_subcategories (категории и подкатегории)

-- ============================================
-- 1. СОЗДАНИЕ ТАБЛИЦ
-- ============================================

-- Таблица основных категорий (типы техники)
CREATE TABLE IF NOT EXISTS parts_main_categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT NOT NULL
);

-- Таблица подкатегорий (категории и подкатегории запчастей)
CREATE TABLE IF NOT EXISTS parts_subcategories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT NOT NULL,
    main_categories_id INTEGER NOT NULL REFERENCES parts_main_categories(id) ON DELETE CASCADE,
    parent_id INTEGER REFERENCES parts_subcategories(id) ON DELETE CASCADE,
    icon TEXT,
    display_order INTEGER DEFAULT 0
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_parts_subcategories_main_categories_id 
ON parts_subcategories(main_categories_id);
CREATE INDEX IF NOT EXISTS idx_parts_subcategories_parent_id 
ON parts_subcategories(parent_id);
CREATE INDEX IF NOT EXISTS idx_parts_subcategories_display_order 
ON parts_subcategories(display_order);

-- ============================================
-- 2. ЗАПОЛНЕНИЕ: ТИПЫ ТЕХНИКИ
-- ============================================

INSERT INTO parts_main_categories (name, name_en) VALUES
    ('Самолёты', 'Aircraft'),
    ('Вертолёты', 'Helicopters'),
    ('Планёры', 'Gliders'),
    ('Сверхлёгкие', 'Ultralights'),
    ('Дроны и БПЛА', 'Drones & UAVs'),
    ('Гидросамолёты и амфибии', 'Seaplanes & Amphibians'),
    ('Винтокрылы', 'Gyrocopters'),
    ('Экспериментальные', 'Experimental Aircraft'),
    ('Аэростаты и дирижабли', 'Balloons & Airships'),
    ('Военная техника', 'Military Aircraft'),
    ('Спортивная авиация', 'Sport Aviation'),
    ('Универсальные запчасти', 'Universal Parts')
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. ЗАПОЛНЕНИЕ: КАТЕГОРИИ ДЛЯ САМОЛЁТОВ
-- ============================================

WITH aircraft_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Самолёты'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    am.id,
    NULL,
    cat.display_order
FROM aircraft_main am
CROSS JOIN (VALUES
    ('Двигатель', 'Engine', 1),
    ('Шасси', 'Landing Gear', 2),
    ('Авионика', 'Avionics', 3),
    ('Фюзеляж и остекление', 'Fuselage & Windows', 4),
    ('Крылья и оперение', 'Wings & Empennage', 5),
    ('Электрооборудование', 'Electrical System', 6),
    ('Топливная система', 'Fuel System', 7),
    ('Гидравлическая система', 'Hydraulic System', 8),
    ('Система кондиционирования', 'Environmental System', 9),
    ('Системы освещения', 'Lighting Systems', 10),
    ('Системы жизнеобеспечения', 'Life Support Systems', 11),
    ('Системы пожаротушения', 'Fire Suppression Systems', 12),
    ('Системы защиты от обледенения', 'Anti-Ice & De-Ice Systems', 13),
    ('Системы записи полёта', 'Flight Recording Systems', 14),
    ('Инструменты и оборудование', 'Tools & Equipment', 15),
    ('Расходные материалы', 'Consumables', 16),
    ('Безопасность и спасательное оборудование', 'Safety & Survival Equipment', 17)
) AS cat(name, name_en, display_order);

-- ============================================
-- 4. ЗАПОЛНЕНИЕ: ПОДКАТЕГОРИИ ДЛЯ САМОЛЁТОВ
-- ============================================

-- Подкатегории для Двигатель (Самолёты)
WITH aircraft_engine AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Двигатель' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    ae.id,
    subcat.display_order
FROM aircraft_engine ae
CROSS JOIN (VALUES
    ('Поршневые двигатели', 'Piston Engines', 1),
    ('Турбовинтовые двигатели', 'Turboprop Engines', 2),
    ('Реактивные двигатели', 'Jet Engines', 3),
    ('Компоненты двигателя', 'Engine Components', 4),
    ('Система зажигания', 'Ignition System', 5),
    ('Система охлаждения', 'Cooling System', 6),
    ('Система смазки', 'Lubrication System', 7),
    ('Выхлопная система', 'Exhaust System', 8),
    ('Пропеллеры и винты', 'Propellers & Blades', 9),
    ('Двигатели б/у', 'Used Engines', 10)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Компоненты двигателя (Самолёты)
WITH engine_components AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Компоненты двигателя' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    ec.id,
    subcat.display_order
FROM engine_components ec
CROSS JOIN (VALUES
    ('Свечи зажигания', 'Spark Plugs', 1),
    ('Масляные фильтры', 'Oil Filters', 2),
    ('Топливные фильтры', 'Fuel Filters', 3),
    ('Топливные насосы', 'Fuel Pumps', 4),
    ('Масляные насосы', 'Oil Pumps', 5),
    ('Карбюраторы', 'Carburetors', 6),
    ('Инжекторы', 'Fuel Injectors', 7),
    ('Турбокомпрессоры', 'Turbochargers', 8),
    ('Магнето', 'Magnetos', 9),
    ('Генераторы двигателя', 'Engine Generators', 10),
    ('Стартеры', 'Starters', 11),
    ('Клапаны', 'Valves', 12),
    ('Поршни и кольца', 'Pistons & Rings', 13),
    ('Коленчатые валы', 'Crankshafts', 14),
    ('Головки цилиндров', 'Cylinder Heads', 15),
    ('Блоки цилиндров', 'Cylinder Blocks', 16),
    ('Подшипники', 'Bearings', 17),
    ('Прокладки и уплотнения', 'Gaskets & Seals', 18)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Шасси (Самолёты)
WITH aircraft_landing_gear AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Шасси' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    alg.id,
    subcat.display_order
FROM aircraft_landing_gear alg
CROSS JOIN (VALUES
    ('Стойки шасси', 'Landing Gear Struts', 1),
    ('Колеса', 'Wheels', 2),
    ('Шины', 'Tires', 3),
    ('Тормозные системы', 'Brake Systems', 4),
    ('Тормозные колодки', 'Brake Pads', 5),
    ('Тормозные диски', 'Brake Discs', 6),
    ('Тормозные суппорты', 'Brake Calipers', 7),
    ('Амортизаторы', 'Shock Absorbers', 8),
    ('Подшипники шасси', 'Landing Gear Bearings', 9),
    ('Узлы крепления', 'Mounting Hardware', 10),
    ('Двери шасси', 'Gear Doors', 11),
    ('Гидроцилиндры шасси', 'Landing Gear Actuators', 12)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Авионика (Самолёты)
WITH aircraft_avionics AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Авионика' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    aav.id,
    subcat.display_order
FROM aircraft_avionics aav
CROSS JOIN (VALUES
    ('Радиостанции', 'Radios', 1),
    ('Транспондеры', 'Transponders', 2),
    ('GPS и навигация', 'GPS & Navigation', 3),
    ('Автопилоты', 'Autopilots', 4),
    ('Системы предупреждения', 'Warning Systems', 5),
    ('Дисплеи и индикаторы', 'Displays & Indicators', 6),
    ('Антенны', 'Antennas', 7),
    ('Акселерометры и гироскопы', 'Accelerometers & Gyros', 8),
    ('Высотомеры', 'Altimeters', 9),
    ('Скоростемеры', 'Airspeed Indicators', 10),
    ('Компасы', 'Compasses', 11),
    ('Системы связи', 'Communication Systems', 12),
    ('Системы посадки', 'Landing Systems', 13),
    ('Метеорадары', 'Weather Radars', 14),
    ('Системы управления полётом', 'Flight Management Systems', 15),
    ('Блоки управления', 'Control Units', 16),
    ('Датчики', 'Sensors', 17),
    ('Кабели и разъёмы', 'Cables & Connectors', 18)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Фюзеляж и остекление (Самолёты)
WITH aircraft_fuselage AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Фюзеляж и остекление' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    af.id,
    subcat.display_order
FROM aircraft_fuselage af
CROSS JOIN (VALUES
    ('Окна и иллюминаторы', 'Windows & Windshields', 1),
    ('Двери', 'Doors', 2),
    ('Панели обшивки', 'Skin Panels', 3),
    ('Рамки и крепления', 'Frames & Mounts', 4),
    ('Уплотнители', 'Seals', 5),
    ('Люки', 'Hatches', 6),
    ('Купола', 'Domes', 7),
    ('Стекла', 'Glass Panels', 8),
    ('Поликарбонатные панели', 'Polycarbonate Panels', 9)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Крылья и оперение (Самолёты)
WITH aircraft_wings AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Крылья и оперение' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    aw.id,
    subcat.display_order
FROM aircraft_wings aw
CROSS JOIN (VALUES
    ('Элероны', 'Ailerons', 1),
    ('Закрылки', 'Flaps', 2),
    ('Руль высоты', 'Elevators', 3),
    ('Руль направления', 'Rudders', 4),
    ('Триммеры', 'Trimmers', 5),
    ('Спойлеры', 'Spoilers', 6),
    ('Крылья', 'Wings', 7),
    ('Хвостовое оперение', 'Empennage', 8),
    ('Приводы поверхностей управления', 'Control Surface Actuators', 9),
    ('Тросы управления', 'Control Cables', 10),
    ('Рычаги управления', 'Control Rods', 11),
    ('Шкивы и блоки', 'Pulleys & Blocks', 12),
    ('Обшивка крыльев', 'Wing Skins', 13),
    ('Нервюры', 'Ribs', 14),
    ('Лонжероны', 'Spars', 15)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Электрооборудование (Самолёты)
WITH aircraft_electrical AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Электрооборудование' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    ae.id,
    subcat.display_order
FROM aircraft_electrical ae
CROSS JOIN (VALUES
    ('Аккумуляторы', 'Batteries', 1),
    ('Генераторы', 'Generators', 2),
    ('Альтернаторы', 'Alternators', 3),
    ('Регуляторы напряжения', 'Voltage Regulators', 4),
    ('Предохранители', 'Fuses', 5),
    ('Реле', 'Relays', 6),
    ('Выключатели', 'Switches', 7),
    ('Проводка', 'Wiring', 8),
    ('Разъёмы', 'Connectors', 9),
    ('Освещение', 'Lighting', 10),
    ('Инверторы', 'Inverters', 11),
    ('Блоки питания', 'Power Supplies', 12),
    ('Заземляющие устройства', 'Grounding Equipment', 13)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Топливная система (Самолёты)
WITH aircraft_fuel AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Топливная система' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    af.id,
    subcat.display_order
FROM aircraft_fuel af
CROSS JOIN (VALUES
    ('Топливные баки', 'Fuel Tanks', 1),
    ('Топливные насосы', 'Fuel Pumps', 2),
    ('Топливные фильтры', 'Fuel Filters', 3),
    ('Топливные краны', 'Fuel Valves', 4),
    ('Топливные магистрали', 'Fuel Lines', 5),
    ('Топливомеры', 'Fuel Gauges', 6),
    ('Дренажные системы', 'Drain Systems', 7),
    ('Топливные форсунки', 'Fuel Injectors', 8),
    ('Топливные подогреватели', 'Fuel Heaters', 9),
    ('Системы впрыска', 'Injection Systems', 10)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Гидравлическая система (Самолёты)
WITH aircraft_hydraulic AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Гидравлическая система' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    ah.id,
    subcat.display_order
FROM aircraft_hydraulic ah
CROSS JOIN (VALUES
    ('Гидронасосы', 'Hydraulic Pumps', 1),
    ('Гидроцилиндры', 'Hydraulic Actuators', 2),
    ('Гидрораспределители', 'Hydraulic Valves', 3),
    ('Гидроаккумуляторы', 'Hydraulic Accumulators', 4),
    ('Гидравлические фильтры', 'Hydraulic Filters', 5),
    ('Гидравлические шланги', 'Hydraulic Hoses', 6),
    ('Гидравлическая жидкость', 'Hydraulic Fluid', 7),
    ('Уплотнения гидравлики', 'Hydraulic Seals', 8)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Система кондиционирования (Самолёты)
WITH aircraft_environmental AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Система кондиционирования' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    aenv.id,
    subcat.display_order
FROM aircraft_environmental aenv
CROSS JOIN (VALUES
    ('Компрессоры', 'Compressors', 1),
    ('Конденсаторы', 'Condensers', 2),
    ('Испарители', 'Evaporators', 3),
    ('Вентиляторы', 'Fans', 4),
    ('Воздуховоды', 'Ducts', 5),
    ('Клапаны давления', 'Pressure Valves', 6),
    ('Фильтры воздуха', 'Air Filters', 7),
    ('Системы обогрева', 'Heating Systems', 8)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Системы освещения (Самолёты)
WITH aircraft_lighting AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Системы освещения' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    al.id,
    subcat.display_order
FROM aircraft_lighting al
CROSS JOIN (VALUES
    ('Навигационные огни', 'Navigation Lights', 1),
    ('Посадочные фары', 'Landing Lights', 2),
    ('Внутреннее освещение', 'Interior Lighting', 3),
    ('Аварийное освещение', 'Emergency Lighting', 4),
    ('Освещение приборной панели', 'Panel Lighting', 5)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Системы жизнеобеспечения (Самолёты)
WITH aircraft_life_support AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Системы жизнеобеспечения' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    als.id,
    subcat.display_order
FROM aircraft_life_support als
CROSS JOIN (VALUES
    ('Кислородные системы', 'Oxygen Systems', 1),
    ('Системы давления кабины', 'Cabin Pressure Systems', 2),
    ('Системы вентиляции', 'Ventilation Systems', 3),
    ('Системы отопления кабины', 'Cabin Heating Systems', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Системы пожаротушения (Самолёты)
WITH aircraft_fire AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Системы пожаротушения' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    af.id,
    subcat.display_order
FROM aircraft_fire af
CROSS JOIN (VALUES
    ('Огнетушители', 'Fire Extinguishers', 1),
    ('Системы обнаружения пожара', 'Fire Detection Systems', 2),
    ('Системы тушения пожара', 'Fire Suppression Systems', 3),
    ('Датчики дыма и огня', 'Smoke & Fire Sensors', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Системы защиты от обледенения (Самолёты)
WITH aircraft_anti_ice AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Системы защиты от обледенения' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    aai.id,
    subcat.display_order
FROM aircraft_anti_ice aai
CROSS JOIN (VALUES
    ('Обогрев передней кромки', 'Leading Edge Heating', 1),
    ('Обогрев двигателя', 'Engine Heating', 2),
    ('Обогрев остекления', 'Windshield Heating', 3),
    ('Обогрев датчиков', 'Sensor Heating', 4),
    ('Химические системы', 'Chemical Systems', 5)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Системы записи полёта (Самолёты)
WITH aircraft_recording AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Системы записи полёта' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    ar.id,
    subcat.display_order
FROM aircraft_recording ar
CROSS JOIN (VALUES
    ('Бортовые самописцы', 'Flight Data Recorders', 1),
    ('Регистраторы полётных данных', 'Flight Data Loggers', 2),
    ('Камеры видеонаблюдения', 'Surveillance Cameras', 3),
    ('Системы мониторинга', 'Monitoring Systems', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Инструменты и оборудование (Самолёты)
WITH aircraft_tools AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Инструменты и оборудование' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    at.id,
    subcat.display_order
FROM aircraft_tools at
CROSS JOIN (VALUES
    ('Ручной инструмент', 'Hand Tools', 1),
    ('Электроинструмент', 'Power Tools', 2),
    ('Специализированный инструмент', 'Specialty Tools', 3),
    ('Оборудование для ангара', 'Hangar Equipment', 4),
    ('Подъёмное оборудование', 'Lifting Equipment', 5),
    ('Измерительные приборы', 'Measuring Instruments', 6),
    ('Оборудование для диагностики', 'Diagnostic Equipment', 7)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Расходные материалы (Самолёты)
WITH aircraft_consumables AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Расходные материалы' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    ac.id,
    subcat.display_order
FROM aircraft_consumables ac
CROSS JOIN (VALUES
    ('Масла и жидкости', 'Oils & Fluids', 1),
    ('Фильтры', 'Filters', 2),
    ('Прокладки', 'Gaskets', 3),
    ('Уплотнители', 'Seals', 4),
    ('Болты и крепеж', 'Bolts & Fasteners', 5),
    ('Химические средства', 'Chemicals', 6),
    ('Смазочные материалы', 'Lubricants', 7),
    ('Краски и покрытия', 'Paints & Coatings', 8)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Безопасность и спасательное оборудование (Самолёты)
WITH aircraft_safety AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Безопасность и спасательное оборудование' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Самолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Самолёты'),
    asafe.id,
    subcat.display_order
FROM aircraft_safety asafe
CROSS JOIN (VALUES
    ('Парашюты', 'Parachutes', 1),
    ('Спасательные жилеты', 'Life Vests', 2),
    ('Сигнальные устройства', 'Signaling Devices', 3),
    ('Аптечки', 'First Aid Kits', 4),
    ('Огнетушители', 'Fire Extinguishers', 5),
    ('Системы аварийного покидания', 'Emergency Egress Systems', 6),
    ('Аварийные радиомаяки', 'Emergency Locator Transmitters', 7),
    ('Системы обнаружения пожара', 'Fire Detection Systems', 8)
) AS subcat(name, name_en, display_order);

-- ============================================
-- 5. ЗАПОЛНЕНИЕ: КАТЕГОРИИ ДЛЯ ВЕРТОЛЁТОВ
-- ============================================

WITH helicopter_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    hm.id,
    NULL,
    cat.display_order
FROM helicopter_main hm
CROSS JOIN (VALUES
    ('Несущий винт', 'Main Rotor System', 1),
    ('Рулевой винт', 'Tail Rotor System', 2),
    ('Система трансмиссии', 'Transmission System', 3),
    ('Система управления', 'Flight Controls', 4),
    ('Хвостовая балка', 'Tail Boom', 5),
    ('Система привода', 'Drive System', 6),
    ('Двигатель', 'Engine', 7),
    ('Шасси', 'Landing Gear', 8),
    ('Авионика', 'Avionics', 9),
    ('Электрооборудование', 'Electrical System', 10),
    ('Топливная система', 'Fuel System', 11),
    ('Гидравлическая система', 'Hydraulic System', 12),
    ('Система кондиционирования', 'Environmental System', 13),
    ('Системы освещения', 'Lighting Systems', 14),
    ('Системы жизнеобеспечения', 'Life Support Systems', 15),
    ('Системы пожаротушения', 'Fire Suppression Systems', 16),
    ('Системы защиты от обледенения', 'Anti-Ice & De-Ice Systems', 17),
    ('Системы записи полёта', 'Flight Recording Systems', 18),
    ('Инструменты и оборудование', 'Tools & Equipment', 19),
    ('Расходные материалы', 'Consumables', 20),
    ('Безопасность и спасательное оборудование', 'Safety & Survival Equipment', 21)
) AS cat(name, name_en, display_order);

-- ============================================
-- 6. ЗАПОЛНЕНИЕ: ПОДКАТЕГОРИИ ДЛЯ ВЕРТОЛЁТОВ
-- ============================================

-- Подкатегории для Несущий винт (Вертолёты)
WITH helicopter_main_rotor AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Несущий винт' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'),
    hmr.id,
    subcat.display_order
FROM helicopter_main_rotor hmr
CROSS JOIN (VALUES
    ('Лопасти несущего винта', 'Main Rotor Blades', 1),
    ('Втулка несущего винта', 'Main Rotor Hub', 2),
    ('Мачта несущего винта', 'Main Rotor Mast', 3),
    ('Подшипники несущего винта', 'Main Rotor Bearings', 4),
    ('Демпферы', 'Dampers', 5),
    ('Шарниры', 'Swashplates', 6),
    ('Система управления шагом', 'Pitch Control System', 7),
    ('Головка несущего винта', 'Rotor Head', 8)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Рулевой винт (Вертолёты)
WITH helicopter_tail_rotor AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Рулевой винт' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'),
    htr.id,
    subcat.display_order
FROM helicopter_tail_rotor htr
CROSS JOIN (VALUES
    ('Лопасти рулевого винта', 'Tail Rotor Blades', 1),
    ('Втулка рулевого винта', 'Tail Rotor Hub', 2),
    ('Вал рулевого винта', 'Tail Rotor Shaft', 3),
    ('Редуктор рулевого винта', 'Tail Rotor Gearbox', 4),
    ('Система управления рулевым винтом', 'Tail Rotor Control', 5)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Система трансмиссии (Вертолёты)
WITH helicopter_transmission AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Система трансмиссии' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'),
    ht.id,
    subcat.display_order
FROM helicopter_transmission ht
CROSS JOIN (VALUES
    ('Главный редуктор', 'Main Gearbox', 1),
    ('Промежуточный редуктор', 'Intermediate Gearbox', 2),
    ('Редуктор рулевого винта', 'Tail Rotor Gearbox', 3),
    ('Валы трансмиссии', 'Transmission Shafts', 4),
    ('Муфты', 'Clutches', 5),
    ('Подшипники трансмиссии', 'Transmission Bearings', 6),
    ('Масляные системы трансмиссии', 'Transmission Oil Systems', 7)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Система управления (Вертолёты)
WITH helicopter_controls AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Система управления' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'),
    hc.id,
    subcat.display_order
FROM helicopter_controls hc
CROSS JOIN (VALUES
    ('Циклическое управление', 'Cyclic Control', 1),
    ('Общее управление шагом', 'Collective Control', 2),
    ('Педали управления', 'Pedals', 3),
    ('Гидроусилители', 'Hydraulic Boosters', 4),
    ('Сервоприводы', 'Servos', 5),
    ('Тросы управления', 'Control Cables', 6)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Хвостовая балка (Вертолёты)
WITH helicopter_tail_boom AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Хвостовая балка' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'),
    htb.id,
    subcat.display_order
FROM helicopter_tail_boom htb
CROSS JOIN (VALUES
    ('Хвостовая балка', 'Tail Boom Assembly', 1),
    ('Стабилизатор', 'Horizontal Stabilizer', 2),
    ('Вертикальный стабилизатор', 'Vertical Fin', 3),
    ('Обшивка хвостовой балки', 'Tail Boom Skins', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Система привода (Вертолёты)
WITH helicopter_drive AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Система привода' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'),
    hd.id,
    subcat.display_order
FROM helicopter_drive hd
CROSS JOIN (VALUES
    ('Муфта свободного хода', 'Freewheeling Unit', 1),
    ('Главный вал', 'Main Drive Shaft', 2),
    ('Промежуточные валы', 'Intermediate Shafts', 3),
    ('Вал рулевого винта', 'Tail Rotor Drive Shaft', 4),
    ('Подшипники валов', 'Shaft Bearings', 5)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Двигатель (Вертолёты)
WITH helicopter_engine AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Двигатель' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'),
    he.id,
    subcat.display_order
FROM helicopter_engine he
CROSS JOIN (VALUES
    ('Турбовальные двигатели', 'Turboshaft Engines', 1),
    ('Поршневые двигатели для вертолётов', 'Piston Engines for Helicopters', 2),
    ('Компоненты вертолётных двигателей', 'Helicopter Engine Components', 3),
    ('Система зажигания', 'Ignition System', 4),
    ('Система охлаждения', 'Cooling System', 5),
    ('Система смазки', 'Lubrication System', 6)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Шасси (Вертолёты) - аналогично самолётам
WITH helicopter_landing_gear AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Шасси' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'),
    hlg.id,
    subcat.display_order
FROM helicopter_landing_gear hlg
CROSS JOIN (VALUES
    ('Полозья', 'Skids', 1),
    ('Колёсное шасси', 'Wheeled Landing Gear', 2),
    ('Поплавки', 'Floats', 3),
    ('Тормозные системы', 'Brake Systems', 4),
    ('Амортизаторы', 'Shock Absorbers', 5)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Авионика (Вертолёты) - аналогично самолётам
WITH helicopter_avionics AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Авионика' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Вертолёты'),
    hav.id,
    subcat.display_order
FROM helicopter_avionics hav
CROSS JOIN (VALUES
    ('Радиостанции', 'Radios', 1),
    ('Транспондеры', 'Transponders', 2),
    ('GPS и навигация', 'GPS & Navigation', 3),
    ('Автопилоты', 'Autopilots', 4),
    ('Системы предупреждения', 'Warning Systems', 5),
    ('Дисплеи и индикаторы', 'Displays & Indicators', 6),
    ('Антенны', 'Antennas', 7)
) AS subcat(name, name_en, display_order);

-- ============================================
-- 7. ЗАПОЛНЕНИЕ: КАТЕГОРИИ ДЛЯ ОСТАЛЬНЫХ ТИПОВ ТЕХНИКИ
-- ============================================

-- Планёры
WITH gliders_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Планёры'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    gm.id,
    NULL,
    cat.display_order
FROM gliders_main gm
CROSS JOIN (VALUES
    ('Крылья и оперение', 'Wings & Empennage', 1),
    ('Система управления', 'Control System', 2),
    ('Шасси для планёров', 'Glider Landing Gear', 3),
    ('Инструменты для планёров', 'Glider Tools', 4),
    ('Системы безопасности', 'Safety Systems', 5),
    ('Авионика для планёров', 'Glider Avionics', 6)
) AS cat(name, name_en, display_order);

-- Сверхлёгкие
WITH ultralights_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Сверхлёгкие'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    um.id,
    NULL,
    cat.display_order
FROM ultralights_main um
CROSS JOIN (VALUES
    ('Двигатели для сверхлёгких', 'Ultralight Engines', 1),
    ('Крылья и оперение', 'Wings & Empennage', 2),
    ('Система управления', 'Control System', 3),
    ('Шасси', 'Landing Gear', 4),
    ('Авионика', 'Avionics', 5),
    ('Электрооборудование', 'Electrical System', 6),
    ('Безопасность', 'Safety Equipment', 7)
) AS cat(name, name_en, display_order);

-- Дроны и БПЛА
WITH drones_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Дроны и БПЛА'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    dm.id,
    NULL,
    cat.display_order
FROM drones_main dm
CROSS JOIN (VALUES
    ('Моторы и ESC', 'Motors & ESC', 1),
    ('Платы управления', 'Flight Controllers', 2),
    ('Камеры и подвесы', 'Cameras & Gimbals', 3),
    ('Аккумуляторы', 'Batteries', 4),
    ('Рамы и крепления', 'Frames & Mounts', 5),
    ('Радиооборудование', 'Radio Equipment', 6),
    ('GPS модули', 'GPS Modules', 7),
    ('Пропеллеры', 'Propellers', 8),
    ('Системы стабилизации', 'Stabilization Systems', 9),
    ('Зарядные устройства', 'Chargers', 10)
) AS cat(name, name_en, display_order);

-- Гидросамолёты и амфибии
WITH seaplanes_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Гидросамолёты и амфибии'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    sm.id,
    NULL,
    cat.display_order
FROM seaplanes_main sm
CROSS JOIN (VALUES
    ('Поплавки', 'Floats', 1),
    ('Лыжи', 'Skis', 2),
    ('Система выпуска поплавков', 'Float Deployment System', 3),
    ('Система управления на воде', 'Water Control System', 4),
    ('Якорное оборудование', 'Anchoring Equipment', 5),
    ('Общие запчасти самолётов', 'General Aircraft Parts', 6)
) AS cat(name, name_en, display_order);

-- Винтокрылы
WITH gyrocopters_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Винтокрылы'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    gcm.id,
    NULL,
    cat.display_order
FROM gyrocopters_main gcm
CROSS JOIN (VALUES
    ('Несущий винт (автожир)', 'Main Rotor (Autogyro)', 1),
    ('Система трансмиссии', 'Transmission System', 2),
    ('Система управления', 'Control System', 3),
    ('Двигатель', 'Engine', 4),
    ('Шасси', 'Landing Gear', 5),
    ('Авионика', 'Avionics', 6),
    ('Система предварительной раскрутки', 'Pre-rotation System', 7)
) AS cat(name, name_en, display_order);

-- Экспериментальные
WITH experimental_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Экспериментальные'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    em.id,
    NULL,
    cat.display_order
FROM experimental_main em
CROSS JOIN (VALUES
    ('Комплекты для сборки', 'Kit Parts', 1),
    ('Компоненты для самодельных', 'Homebuilt Components', 2),
    ('Специальные крепления', 'Special Mounts', 3),
    ('Экспериментальные системы', 'Experimental Systems', 4),
    ('Универсальные компоненты', 'Universal Components', 5)
) AS cat(name, name_en, display_order);

-- Аэростаты и дирижабли
WITH balloons_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Аэростаты и дирижабли'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    bm.id,
    NULL,
    cat.display_order
FROM balloons_main bm
CROSS JOIN (VALUES
    ('Оболочки', 'Envelopes', 1),
    ('Гондолы', 'Gondolas', 2),
    ('Системы наполнения', 'Filling Systems', 3),
    ('Газовое оборудование', 'Gas Equipment', 4),
    ('Якорные системы', 'Anchoring Systems', 5),
    ('Системы управления', 'Control Systems', 6)
) AS cat(name, name_en, display_order);

-- Военная техника
WITH military_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Военная техника'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    mm.id,
    NULL,
    cat.display_order
FROM military_main mm
CROSS JOIN (VALUES
    ('Военные компоненты', 'Military Components', 1),
    ('Защитные системы', 'Defense Systems', 2),
    ('Специальное оборудование', 'Special Equipment', 3),
    ('Системы связи', 'Communication Systems', 4),
    ('Общие запчасти', 'General Parts', 5)
) AS cat(name, name_en, display_order);

-- Спортивная авиация
WITH sport_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Спортивная авиация'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    sm.id,
    NULL,
    cat.display_order
FROM sport_main sm
CROSS JOIN (VALUES
    ('Пилотажные самолёты', 'Aerobatic Aircraft', 1),
    ('Аэробатические компоненты', 'Aerobatic Components', 2),
    ('Спортивные двигатели', 'Sport Engines', 3),
    ('Специальное оборудование', 'Special Equipment', 4),
    ('Системы безопасности', 'Safety Systems', 5)
) AS cat(name, name_en, display_order);

-- Универсальные запчасти
WITH universal_main AS (
    SELECT id FROM parts_main_categories WHERE name = 'Универсальные запчасти'
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    cat.name,
    cat.name_en,
    um.id,
    NULL,
    cat.display_order
FROM universal_main um
CROSS JOIN (VALUES
    ('Расходные материалы', 'Consumables', 1),
    ('Инструменты', 'Tools', 2),
    ('Крепеж', 'Fasteners', 3),
    ('Смазочные материалы', 'Lubricants', 4),
    ('Химические средства', 'Chemicals', 5)
) AS cat(name, name_en, display_order);

-- ============================================
-- 8. ЗАПОЛНЕНИЕ: ПОДКАТЕГОРИИ ДЛЯ ОСТАЛЬНЫХ ТИПОВ ТЕХНИКИ
-- ============================================

-- Подкатегории для Планёры
WITH gliders_wings AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Крылья и оперение' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Планёры')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Планёры'),
    gw.id,
    subcat.display_order
FROM gliders_wings gw
CROSS JOIN (VALUES
    ('Крылья планёра', 'Glider Wings', 1),
    ('Хвостовое оперение', 'Empennage', 2),
    ('Элероны', 'Ailerons', 3),
    ('Закрылки', 'Flaps', 4),
    ('Тормозные щитки', 'Air Brakes', 5)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Сверхлёгкие
WITH ultralights_engines AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Двигатели для сверхлёгких' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Сверхлёгкие')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Сверхлёгкие'),
    ue.id,
    subcat.display_order
FROM ultralights_engines ue
CROSS JOIN (VALUES
    ('Двухтактные двигатели', 'Two-Stroke Engines', 1),
    ('Четырёхтактные двигатели', 'Four-Stroke Engines', 2),
    ('Электрические двигатели', 'Electric Motors', 3),
    ('Пропеллеры для сверхлёгких', 'Ultralight Propellers', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Дроны и БПЛА
WITH drones_motors AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Моторы и ESC' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Дроны и БПЛА')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Дроны и БПЛА'),
    dm.id,
    subcat.display_order
FROM drones_motors dm
CROSS JOIN (VALUES
    ('Бесколлекторные моторы', 'Brushless Motors', 1),
    ('ESC контроллеры', 'ESC Controllers', 2),
    ('Регуляторы скорости', 'Speed Controllers', 3)
) AS subcat(name, name_en, display_order);

WITH drones_fc AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Платы управления' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Дроны и БПЛА')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Дроны и БПЛА'),
    dfc.id,
    subcat.display_order
FROM drones_fc dfc
CROSS JOIN (VALUES
    ('Платы управления полётом', 'Flight Controllers', 1),
    ('IMU модули', 'IMU Modules', 2),
    ('Компасы', 'Compasses', 3),
    ('Барометры', 'Barometers', 4)
) AS subcat(name, name_en, display_order);

WITH drones_cameras AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Камеры и подвесы' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Дроны и БПЛА')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Дроны и БПЛА'),
    dc.id,
    subcat.display_order
FROM drones_cameras dc
CROSS JOIN (VALUES
    ('Камеры', 'Cameras', 1),
    ('Подвесы', 'Gimbals', 2),
    ('Видеопередатчики', 'Video Transmitters', 3),
    ('Видеоприёмники', 'Video Receivers', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Гидросамолёты
WITH seaplanes_floats AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Поплавки' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Гидросамолёты и амфибии')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Гидросамолёты и амфибии'),
    sf.id,
    subcat.display_order
FROM seaplanes_floats sf
CROSS JOIN (VALUES
    ('Поплавки основные', 'Main Floats', 1),
    ('Поплавки хвостовые', 'Tail Floats', 2),
    ('Крепления поплавков', 'Float Mounts', 3),
    ('Системы управления поплавками', 'Float Control Systems', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Винтокрылы
WITH gyrocopters_rotor AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Несущий винт (автожир)' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Винтокрылы')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Винтокрылы'),
    gr.id,
    subcat.display_order
FROM gyrocopters_rotor gr
CROSS JOIN (VALUES
    ('Лопасти автожира', 'Autogyro Blades', 1),
    ('Втулка автожира', 'Autogyro Hub', 2),
    ('Мачта автожира', 'Autogyro Mast', 3),
    ('Система предварительной раскрутки', 'Pre-rotation System', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Экспериментальные
WITH experimental_kits AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Комплекты для сборки' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Экспериментальные')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Экспериментальные'),
    ek.id,
    subcat.display_order
FROM experimental_kits ek
CROSS JOIN (VALUES
    ('Комплекты для самолётов', 'Aircraft Kits', 1),
    ('Комплекты для вертолётов', 'Helicopter Kits', 2),
    ('Комплекты для планёров', 'Glider Kits', 3),
    ('Частичные комплекты', 'Partial Kits', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Аэростаты
WITH balloons_envelopes AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Оболочки' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Аэростаты и дирижабли')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Аэростаты и дирижабли'),
    be.id,
    subcat.display_order
FROM balloons_envelopes be
CROSS JOIN (VALUES
    ('Оболочки воздушных шаров', 'Balloon Envelopes', 1),
    ('Оболочки дирижаблей', 'Airship Envelopes', 2),
    ('Материалы для оболочек', 'Envelope Materials', 3),
    ('Системы наполнения', 'Filling Systems', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Военная техника
WITH military_components AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Военные компоненты' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Военная техника')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Военная техника'),
    mc.id,
    subcat.display_order
FROM military_components mc
CROSS JOIN (VALUES
    ('Военные двигатели', 'Military Engines', 1),
    ('Военная авионика', 'Military Avionics', 2),
    ('Системы защиты', 'Defense Systems', 3),
    ('Специальное оборудование', 'Special Equipment', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Спортивная авиация
WITH sport_aerobatic AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Пилотажные самолёты' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Спортивная авиация')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Спортивная авиация'),
    sa.id,
    subcat.display_order
FROM sport_aerobatic sa
CROSS JOIN (VALUES
    ('Аэробатические самолёты', 'Aerobatic Aircraft', 1),
    ('Спортивные самолёты', 'Sport Aircraft', 2),
    ('Гоночные самолёты', 'Racing Aircraft', 3),
    ('Спортивные двигатели', 'Sport Engines', 4)
) AS subcat(name, name_en, display_order);

-- Подкатегории для Универсальные запчасти
WITH universal_consumables AS (
    SELECT id FROM parts_subcategories 
    WHERE name = 'Расходные материалы' 
    AND main_categories_id = (SELECT id FROM parts_main_categories WHERE name = 'Универсальные запчасти')
)
INSERT INTO parts_subcategories (name, name_en, main_categories_id, parent_id, display_order)
SELECT 
    subcat.name,
    subcat.name_en,
    (SELECT id FROM parts_main_categories WHERE name = 'Универсальные запчасти'),
    uc.id,
    subcat.display_order
FROM universal_consumables uc
CROSS JOIN (VALUES
    ('Масла и жидкости', 'Oils & Fluids', 1),
    ('Фильтры', 'Filters', 2),
    ('Прокладки', 'Gaskets', 3),
    ('Уплотнители', 'Seals', 4),
    ('Болты и крепеж', 'Bolts & Fasteners', 5)
) AS subcat(name, name_en, display_order);
