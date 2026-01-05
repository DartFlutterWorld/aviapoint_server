# Структура каталога самолётов

## Обзор

Каталог самолётов построен по нормализованной структуре с тремя основными таблицами:

1. **manufacturers** - производители
2. **aircraft_models** - модели самолётов (связь с производителями)
3. **aircraft_model_specs** - расширенные технические характеристики (опционально)

## Преимущества такой структуры

### 1. Нормализация данных
- Исключается дублирование данных о производителях
- Каждая запись о производителе хранится один раз
- Легче поддерживать актуальность данных

### 2. Гибкость
- Можно добавлять новые производители независимо от моделей
- Легко добавлять новые модели к существующим производителям
- Можно добавлять расширенные характеристики по мере необходимости

### 3. Производительность
- Быстрый поиск по производителям
- Эффективная фильтрация по категориям, типам двигателей
- Индексы оптимизированы для частых запросов

### 4. Масштабируемость
- Легко добавлять новые поля в таблицы
- Можно расширять характеристики через отдельную таблицу
- Поддержка множества языков (через дополнительную таблицу translations)

## Структура таблиц

### manufacturers (Производители)
```sql
- id (PK)
- name (UNIQUE) - название производителя
- country - страна происхождения
- website - официальный сайт
- description - описание
- is_active - активен ли для выбора
- created_at, updated_at
```

### aircraft_models (Модели самолётов)
```sql
- id (PK)
- manufacturer_id (FK -> manufacturers.id)
- model_code - код модели (например, "172", "SR22")
- full_name - полное название (например, "Cessna 172 Skyhawk")
- category - категория (single_engine, twin_engine, helicopter, etc.)
- engine_type - тип двигателя (piston, turboprop, jet, etc.)
- engine_count - количество двигателей
- is_active - активна ли модель
- created_at, updated_at
- UNIQUE(manufacturer_id, model_code)
```

### aircraft_model_specs (Расширенные характеристики)
```sql
- id (PK)
- aircraft_model_id (FK -> aircraft_models.id, UNIQUE)
- seats - количество мест
- max_speed_kmh - максимальная скорость
- cruise_speed_kmh - крейсерская скорость
- range_km - дальность полёта
- max_altitude_ft - практический потолок
- max_takeoff_weight_kg - максимальный взлётный вес
- empty_weight_kg - вес пустого
- fuel_capacity_liters - ёмкость топливных баков
- description - описание
- photo_url - URL фотографии
- source_url - ссылка на источник
- created_at, updated_at
```

## Представления

### aircraft_catalog_view
Представление для удобного получения полной информации о моделях с производителями и характеристиками.

## Примеры запросов

### Получить все модели производителя
```sql
SELECT am.*, m.name as manufacturer_name
FROM aircraft_models am
INNER JOIN manufacturers m ON am.manufacturer_id = m.id
WHERE m.name = 'Cessna'
ORDER BY am.full_name;
```

### Поиск модели по названию
```sql
SELECT * FROM aircraft_catalog_view
WHERE full_name ILIKE '%172%'
ORDER BY manufacturer_name, full_name;
```

### Получить все одномоторные самолёты с поршневым двигателем
```sql
SELECT * FROM aircraft_catalog_view
WHERE category = 'single_engine' 
  AND engine_type = 'piston'
ORDER BY manufacturer_name, full_name;
```

### Получить модели с количеством мест больше 4
```sql
SELECT * FROM aircraft_catalog_view
WHERE seats >= 4
ORDER BY seats DESC, manufacturer_name, full_name;
```

### Получить статистику по производителям
```sql
SELECT 
    m.name as manufacturer,
    COUNT(am.id) as models_count,
    COUNT(ams.id) as models_with_specs
FROM manufacturers m
LEFT JOIN aircraft_models am ON m.id = am.manufacturer_id AND am.is_active = true
LEFT JOIN aircraft_model_specs ams ON am.id = ams.aircraft_model_id
WHERE m.is_active = true
GROUP BY m.id, m.name
ORDER BY models_count DESC;
```

## Интеграция с таблицей flights

Текущая таблица `flights` имеет поле `aircraft_type VARCHAR(100)`. 

Для полной интеграции можно:
1. Оставить `aircraft_type` как есть (для обратной совместимости)
2. Добавить `aircraft_model_id INTEGER REFERENCES aircraft_models(id)` для новых записей
3. Постепенно мигрировать старые данные, сопоставляя строковые значения с моделями в каталоге

## Миграция данных

Для миграции данных из старой структуры (одна таблица `aircraft_types`) в новую:

1. Извлечь уникальных производителей
2. Создать записи в `manufacturers`
3. Создать записи в `aircraft_models` с привязкой к производителям
4. При необходимости перенести расширенные данные в `aircraft_model_specs`

## Дальнейшее развитие

1. **Мультиязычность**: добавить таблицу `manufacturer_translations` и `aircraft_model_translations`
2. **Фото галерея**: создать отдельную таблицу `aircraft_model_photos`
3. **История изменений**: добавить версионирование для характеристик
4. **Категории и теги**: создать систему категорий и тегов для фильтрации
5. **Связь с полётами**: добавить статистику использования моделей в полётах

