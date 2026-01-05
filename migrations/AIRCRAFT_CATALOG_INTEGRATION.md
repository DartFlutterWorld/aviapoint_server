# Интеграция каталога самолётов

## Что сделано

### Backend

1. ✅ **Создана нормализованная структура БД:**
   - `manufacturers` - таблица производителей
   - `aircraft_models` - таблица моделей самолётов
   - `aircraft_model_specs` - таблица расширенных характеристик (опционально)

2. ✅ **Созданы модели данных:**
   - `AircraftManufacturerModel` - модель производителя
   - `AircraftModel` - модель самолёта

3. ✅ **Создан репозиторий:**
   - `AircraftCatalogRepository` - репозиторий для работы с каталогом
   - Методы: `getManufacturers()`, `getAircraftModels()`, `getAircraftModelById()`

4. ✅ **Создан контроллер:**
   - `AircraftCatalogController` - API контроллер
   - Endpoints:
     - `GET /api/aircraft/manufacturers` - получить всех производителей
     - `GET /api/aircraft/models` - получить модели (с фильтрами)
     - `GET /api/aircraft/models/<id>` - получить модель по ID

5. ✅ **Зарегистрировано в DI:**
   - Репозиторий и контроллер зарегистрированы в `setup_dependencies.dart`
   - Роутер подключен в `main.dart`

### Миграции

1. ✅ `create_aircraft_catalog_tables.sql` - создание таблиц
2. ✅ `insert_aircraft_catalog_data.sql` - базовое заполнение данных

## Что нужно сделать

### 1. Заполнить данные

Текущий SQL-скрипт содержит базовые данные. Для полного заполнения нужно:

1. Выполнить миграции:
   ```bash
   psql -d your_database -f create_aircraft_catalog_tables.sql
   psql -d your_database -f insert_aircraft_catalog_data.sql
   ```

2. Дополнить данные из списка PlaneCheck.com (можно создать скрипт для автоматической генерации SQL)

### 2. Сгенерировать код (build_runner)

После создания моделей нужно сгенерировать код:

```bash
cd ../aviapoint_server
dart run build_runner build --delete-conflicting-outputs
```

Это создаст файлы `.g.dart` для:
- `aircraft_manufacturer_model.g.dart`
- `aircraft_model.g.dart`
- `aircraft_catalog_controller.g.dart`

### 3. Frontend интеграция

Нужно создать:

1. **Модели данных** (lib/on_the_way/data/models/):
   - `aircraft_manufacturer_dto.dart`
   - `aircraft_model_dto.dart`

2. **API сервис** (lib/on_the_way/data/datasources/):
   - `aircraft_catalog_service.dart` (retrofit)

3. **Обновить UI:**
   - Заменить текстовое поле `aircraft_type` на выпадающий список/поиск
   - Добавить фильтры по производителю, категории, типу двигателя
   - Использовать автодополнение

## API Endpoints

### GET /api/aircraft/manufacturers
Получить всех производителей

**Query параметры:**
- `active_only` (boolean, default: true) - только активные производители

**Пример:**
```bash
GET /api/aircraft/manufacturers
GET /api/aircraft/manufacturers?active_only=false
```

### GET /api/aircraft/models
Получить модели самолётов

**Query параметры:**
- `manufacturer_id` (int) - фильтр по производителю
- `category` (string) - фильтр по категории (single_engine, twin_engine, helicopter, etc.)
- `engine_type` (string) - фильтр по типу двигателя (piston, turboprop, jet, etc.)
- `active_only` (boolean, default: true) - только активные модели
- `q` (string) - поиск по названию, коду модели или производителю

**Пример:**
```bash
GET /api/aircraft/models
GET /api/aircraft/models?manufacturer_id=1
GET /api/aircraft/models?category=single_engine&engine_type=piston
GET /api/aircraft/models?q=Cessna 172
```

### GET /api/aircraft/models/<id>
Получить модель по ID

**Пример:**
```bash
GET /api/aircraft/models/1
```

## Примеры запросов

### Получить все модели Cessna
```bash
# 1. Найти ID производителя Cessna
GET /api/aircraft/manufacturers

# 2. Получить модели Cessna
GET /api/aircraft/models?manufacturer_id=<cesna_id>
```

### Поиск модели по названию
```bash
GET /api/aircraft/models?q=172
```

### Получить все одномоторные самолёты
```bash
GET /api/aircraft/models?category=single_engine
```

## Следующие шаги

1. ✅ Сгенерировать код через build_runner
2. ⏳ Создать frontend модели и сервисы
3. ⏳ Обновить UI создания/редактирования полёта
4. ⏳ Добавить все данные из списка PlaneCheck.com
5. ⏳ Опционально: добавить расширенные характеристики (seats, speed, range, etc.)

