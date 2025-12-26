# Сводка всех миграций

## Миграции в MigrationManager (в порядке выполнения)

1. ✅ **001** - create_payments_table
2. ✅ **002** - create_subscriptions_table
3. ✅ **003** - create_on_the_way_tables
4. ✅ **004** - create_airports_table (старая, заменена на 009)
5. ✅ **005** - add_avatar_url_to_profiles
6. ✅ **006** - add_reply_to_reviews
7. ✅ **007** - make_rating_nullable_for_replies
8. ✅ **008** - add_flight_photos_table
9. ✅ **009** - recreate_airports_table_aopa (заменяет 004, создает новую структуру)
10. ✅ **010** - create_feedback_table
11. ✅ **011** - create_airport_ownership_requests_table (уже содержит phone, phone_from_request, full_name, comment)
12. ✅ **012** - add_owned_airports_to_profiles
13. ✅ **013** - add_user_id_to_payments
14. ✅ **014** - add_subscription_fields_to_profiles
15. ✅ **015** - add_subscription_fields_to_payments
16. ✅ **016** - add_description_to_subscription_types
17. ✅ **017** - make_payment_id_nullable_in_subscriptions

## Миграции, которые НЕ добавлены (и причины)

### Не нужны (поля уже есть в основной таблице):
- ❌ `add_phone_to_airport_ownership_requests.sql` - поля уже есть в create_airport_ownership_requests_table.sql
- ❌ `add_phone_and_fullname_to_airport_ownership_requests.sql` - поля уже есть в create_airport_ownership_requests_table.sql
- ❌ `add_owner_id_to_airports.sql` - поле уже есть в recreate_airports_table_aopa.sql

### Не используются в коде:
- ❌ `add_photos_to_airports.sql` - не используется
- ❌ `create_airport_feedback_table.sql` - используется общая таблица feedback

### Откаты (могут быть нужны в будущем, но не добавляем в основной список):
- ⚠️ `remove_subscription_fields_from_profiles.sql` - откат миграции 014
- ⚠️ `remove_unique_active_subscription_index.sql` - откат индекса

### Служебные файлы (не миграции):
- `check_and_add_payment_fields.sql` - служебный скрипт
- `clear_payments_subscriptions.sql` - служебный скрипт
- `create_test_user.sql` - тестовые данные
- `run_all_migrations.sql` - служебный файл
- `run_migrations_in_order.sh` - bash скрипт

## Итого

**Всего миграций в менеджере: 17**

Все используемые в коде миграции добавлены и будут выполняться автоматически при запуске сервера.

