# Проверка миграций

## Миграции в MigrationManager

1. ✅ 001 - create_payments_table
2. ✅ 002 - create_subscriptions_table
3. ✅ 003 - create_on_the_way_tables
4. ✅ 004 - create_airports_table (старая, заменена на 009)
5. ✅ 005 - add_avatar_url_to_profiles
6. ✅ 006 - add_reply_to_reviews
7. ✅ 007 - make_rating_nullable_for_replies
8. ✅ 008 - add_flight_photos_table
9. ✅ 009 - recreate_airports_table_aopa (заменяет 004)
10. ✅ 010 - create_feedback_table (ДОБАВЛЕНО)
11. ✅ 011 - create_airport_ownership_requests_table (ДОБАВЛЕНО)

## Миграции в папке migrations, но НЕ в менеджере

### Используются в коде (НУЖНО ДОБАВИТЬ):
- ❌ **add_owned_airports_to_profiles.sql** - используется в airport_repository.dart (строка 143)

### Не используются или устарели:
- ❌ add_owner_id_to_airports.sql - owner_id уже есть в recreate_airports_table_aopa.sql
- ❌ add_photos_to_airports.sql - не используется в коде
- ❌ create_airport_feedback_table.sql - не используется (используется общая таблица feedback)
- ❌ add_description_to_subscription_types.sql - нужно проверить использование
- ❌ add_subscription_fields_to_payments.sql - нужно проверить использование
- ❌ add_subscription_fields_to_profiles.sql - нужно проверить использование
- ❌ add_user_id_to_payments.sql - нужно проверить использование
- ❌ make_payment_id_nullable_in_subscriptions.sql - нужно проверить использование
- ❌ remove_subscription_fields_from_profiles.sql - нужно проверить использование
- ❌ remove_unique_active_subscription_index.sql - нужно проверить использование

### Служебные (не миграции):
- check_and_add_payment_fields.sql
- clear_payments_subscriptions.sql
- create_test_user.sql
- run_all_migrations.sql
- run_migrations_in_order.sh

## Рекомендации

1. ✅ Добавить create_feedback_table (010) - ДОБАВЛЕНО
2. ✅ Добавить create_airport_ownership_requests_table (011) - ДОБАВЛЕНО
3. ⚠️ Добавить add_owned_airports_to_profiles.sql (012) - используется в коде

