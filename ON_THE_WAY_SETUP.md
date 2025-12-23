# Настройка сервиса "По пути"

## 1. Применение миграции базы данных

Выполните SQL миграцию для создания таблиц:

```bash
psql -h <host> -U <user> -d <database> -f migrations/create_on_the_way_tables.sql
```

Или вручную выполните SQL из файла `migrations/create_on_the_way_tables.sql` в вашей базе данных.

## 2. Генерация кода на бэкенде

После создания моделей и контроллера необходимо запустить build_runner для генерации кода:

```bash
cd /Users/admin/Projects/aviapoint_server
dart pub run build_runner build --delete-conflicting-outputs
```

Это сгенерирует:
- `flight_model.freezed.dart` и `flight_model.g.dart`
- `booking_model.freezed.dart` и `booking_model.g.dart`
- `review_model.freezed.dart` и `review_model.g.dart`
- `create_flight_request.freezed.dart` и `create_flight_request.g.dart`
- `create_booking_request.freezed.dart` и `create_booking_request.g.dart`
- `create_review_request.freezed.dart` и `create_review_request.g.dart`
- `on_the_way_controller.g.dart`

## 3. Перезапуск сервера

После применения миграции и генерации кода перезапустите backend сервер, чтобы новые endpoints были доступны.

## 4. Проверка работы

После запуска сервера проверьте доступность endpoints:
- `GET /api/flights` - список полетов
- `GET /api/flights/:id` - детали полета
- `POST /api/flights` - создание полета (требует авторизации)
- `PUT /api/flights/:id` - обновление полета (требует авторизации)
- `DELETE /api/flights/:id` - удаление полета (требует авторизации)
- `GET /api/bookings` - мои бронирования (требует авторизации)
- `POST /api/bookings` - создание бронирования (требует авторизации)
- `PUT /api/bookings/:id/confirm` - подтверждение бронирования (требует авторизации)
- `PUT /api/bookings/:id/cancel` - отмена бронирования (требует авторизации)
- `GET /api/reviews/:userId` - отзывы о пользователе
- `POST /api/reviews` - создание отзыва (требует авторизации)

## Структура созданных файлов

### Backend:
- `migrations/create_on_the_way_tables.sql` - миграция БД
- `lib/on_the_way/data/model/flight_model.dart` - модель полета
- `lib/on_the_way/data/model/booking_model.dart` - модель бронирования
- `lib/on_the_way/data/model/review_model.dart` - модель отзыва
- `lib/on_the_way/api/create_flight_request.dart` - DTO для создания полета
- `lib/on_the_way/api/create_booking_request.dart` - DTO для создания бронирования
- `lib/on_the_way/api/create_review_request.dart` - DTO для создания отзыва
- `lib/on_the_way/repositories/on_the_way_repository.dart` - репозиторий
- `lib/on_the_way/controller/on_the_way_controller.dart` - контроллер с endpoints

### Frontend:
- `lib/on_the_way/presentation/pages/on_the_way_navigation_screen.dart` - navigation screen
- `lib/on_the_way/presentation/pages/on_the_way_screen.dart` - базовый экран
- Обновлен `lib/core/presentation/widgets/bottom_bar.dart` - добавлена кнопка "По пути"
- Обновлен `lib/base_screen.dart` - добавлен OnTheWayNavigationRoute
- Обновлен `lib/core/routes/app_router.dart` - добавлен роут

## Следующие шаги

1. Применить миграцию БД
2. Запустить build_runner на бэкенде
3. Перезапустить backend сервер
4. Запустить build_runner на фронтенде (уже выполнен)
5. Протестировать работу кнопки "По пути" в приложении


