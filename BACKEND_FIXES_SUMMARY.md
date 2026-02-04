# Исправления бэкенда: замена subscription_type на subscription_type_id

## ✅ Выполненные исправления

### 1. PaymentModel (`lib/payments/model/payment_model.dart`)
- ✅ Заменено поле `subscriptionType: String` на `subscriptionTypeId: int`
- ✅ Обновлен `@JsonKey(name: 'subscription_type_id')`

### 2. CreatePaymentRequest (`lib/payments/api/create_payment_request.dart`)
- ✅ Удалено поле `subscriptionType: String?`
- ✅ Оставлено только `subscriptionTypeId: int?`
- ✅ Обновлены комментарии

### 3. PaymentController (`lib/payments/controllers/payment_controller.dart`)
- ✅ Обновлен ответ verifyIAP - возвращает `subscription_type_id` вместо `subscription_type`

### 4. YooKassaService (`lib/payments/services/yookassa_service.dart`)
- ✅ Обновлено извлечение `subscription_type_id` из metadata
- ✅ Обновлено создание PaymentModel с использованием `subscriptionTypeId`

## ⚠️ Требуется выполнить

### 1. Перегенерировать .g.dart файлы
```bash
cd /Users/admin/Projects/aviapoint_server
dart run build_runner build --delete-conflicting-outputs
```

Это обновит:
- `lib/payments/model/payment_model.g.dart`
- `lib/payments/api/create_payment_request.g.dart`

### 2. Проверить использование FCM сервиса
FCM сервис (`lib/push_notifications/fcm_service.dart`) использует `subscriptionType` (код) для уведомлений. Это нормально для уведомлений, но нужно убедиться, что код правильно получается из `subscription_type_id`.

### 3. Проверить все места использования PaymentModel
Убедиться, что везде используется `subscriptionTypeId`, а не `subscriptionType`.

## 📋 Проверка БД

Миграция 075 уже выполнена:
- ✅ Добавлено поле `subscription_type_id` в таблицу `payments`
- ✅ Удалено поле `subscription_type` из таблицы `payments`
- ✅ Создан foreign key на `subscription_types(id)`

## 🔍 Что проверить после исправлений

1. ✅ API `/api/payments/create` принимает `subscription_type_id` (integer)
2. ✅ API `/api/payments/{id}/status` возвращает `subscription_type_id` (integer)
3. ✅ API `/api/subscriptions/active` возвращает `subscription_type_id` (integer)
4. ✅ API `/api/subscriptions/types` возвращает объекты с полем `id`
5. ✅ PaymentModel корректно работает с данными из БД
6. ✅ Webhook от ЮKassa корректно обрабатывает `subscription_type_id` из metadata

## 📝 Примечания

- FCM уведомления могут продолжать использовать код типа подписки для читаемости
- Telegram уведомления могут продолжать использовать код типа подписки
- В БД и API везде используется `subscription_type_id` (integer)
