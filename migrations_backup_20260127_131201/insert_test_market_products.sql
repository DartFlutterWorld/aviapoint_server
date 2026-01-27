-- Миграция для добавления тестовых самолётов в market_products

BEGIN;

-- Вставляем 3 тестовых самолёта
-- Используем первый доступный профиль как продавца для всех
DO $$
DECLARE
    seller_id_val INTEGER;
    category_id_1 INTEGER;
    category_id_2 INTEGER;
    category_id_3 INTEGER;
BEGIN
    -- Получаем ID первого профиля
    SELECT id INTO seller_id_val FROM profiles LIMIT 1;
    
    -- Получаем ID первых трёх категорий из aircraft_subcategories где main_categories_id = 1
    SELECT id INTO category_id_1 FROM aircraft_subcategories WHERE main_categories_id = 1 ORDER BY id LIMIT 1;
    SELECT id INTO category_id_2 FROM aircraft_subcategories WHERE main_categories_id = 1 ORDER BY id OFFSET 1 LIMIT 1;
    SELECT id INTO category_id_3 FROM aircraft_subcategories WHERE main_categories_id = 1 ORDER BY id OFFSET 2 LIMIT 1;
    
    -- Если категорий меньше 3, используем первую для всех
    IF category_id_2 IS NULL THEN category_id_2 := category_id_1; END IF;
    IF category_id_3 IS NULL THEN category_id_3 := category_id_1; END IF;
    
    -- Вставляем первый самолёт
    IF seller_id_val IS NOT NULL AND category_id_1 IS NOT NULL THEN
        INSERT INTO market_products (
            seller_id,
            aircraft_subcategories_id,
            title,
            description,
            price,
            main_image_url,
            additional_image_urls,
            brand,
            location,
            location_type,
            year,
            flight_hours,
            seats,
            condition,
            is_active,
            created_at
        ) VALUES (
            seller_id_val,
            category_id_1,
            'Cessna 172 Skyhawk',
            'Отличный самолёт для обучения и прогулочных полётов. Состояние отличное, регулярное техническое обслуживание. Готов к полётам.',
            250000.00,
            NULL,
            '[]'::jsonb,
            'Cessna',
            'Москва, аэродром Мячково',
            'airport',
            2015,
            1200.5,
            4,
            'used',
            true,
            NOW()
        );
    END IF;
    
    -- Вставляем второй самолёт
    IF seller_id_val IS NOT NULL AND category_id_2 IS NOT NULL THEN
        INSERT INTO market_products (
            seller_id,
            aircraft_subcategories_id,
            title,
            description,
            price,
            main_image_url,
            additional_image_urls,
            brand,
            location,
            location_type,
            year,
            flight_hours,
            seats,
            condition,
            is_active,
            created_at
        ) VALUES (
            seller_id_val,
            category_id_2,
            'Piper PA-28 Cherokee',
            'Надёжный самолёт для дальних перелётов. Полностью укомплектован, все документы в порядке.',
            180000.00,
            NULL,
            '[]'::jsonb,
            'Piper',
            'Санкт-Петербург, аэродром Левашово',
            'airport',
            2010,
            2500.0,
            4,
            'used',
            true,
            NOW()
        );
    END IF;
    
    -- Вставляем третий самолёт
    IF seller_id_val IS NOT NULL AND category_id_3 IS NOT NULL THEN
        INSERT INTO market_products (
            seller_id,
            aircraft_subcategories_id,
            title,
            description,
            price,
            main_image_url,
            additional_image_urls,
            brand,
            location,
            location_type,
            year,
            flight_hours,
            seats,
            condition,
            is_active,
            created_at
        ) VALUES (
            seller_id_val,
            category_id_3,
            'Cirrus SR22',
            'Современный самолёт с системой CAPS. Отличное оснащение, подходит для бизнес-авиации.',
            450000.00,
            NULL,
            '[]'::jsonb,
            'Cirrus',
            'Казань, аэропорт Казань',
            'airport',
            2020,
            500.0,
            4,
            'used',
            true,
            NOW()
        );
    END IF;
END $$;

COMMIT;
