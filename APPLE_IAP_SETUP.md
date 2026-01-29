# Настройка Apple In-App Purchases

## Обзор

Система поддерживает Apple In-App Purchases (IAP) для iOS приложений. Пользователи могут покупать подписки через App Store, и они будут автоматически активироваться на сервере.

## Настройка в App Store Connect

1. **Создайте Subscription Group (группу подписок):**
   - App Store Connect → Ваше приложение → Features → In-App Purchases
   - Нажмите "+" для создания новой группы
   - Название группы: "РосАвиаТест Подписки" или "AviaPoint Subscriptions"

2. **Создайте продукт подписки на год:**
   - В созданной группе нажмите "+" для добавления продукта
   - **Тип:** Выберите **"Автоматически возобновляемая подписка"** (Auto-Renewable Subscription)
   - **Оригинальное название (Reference Name):** `Подписка РосАвиаТест на год` или `РосАвиаТест - Годовая подписка`
   - **ID продукта (Product ID):** `com.aviapoint.subscription.rosaviatest.yearly` или `com.aviapoint.subscription.yearly`
     - ⚠️ **Важно:** Product ID должен быть уникальным и не может быть изменен после создания
     - Формат: `com.aviapoint.subscription.rosaviatest.yearly` (рекомендуется)
   
3. **Настройте подписку:**
   - **Период подписки:** 1 год (12 месяцев)
   - **Цена:** Установите цену для всех стран или используйте "Match my price in other currencies"
   - **Локализация:** Добавьте название и описание на русском и английском языках

2. **Получите ключи для App Store Server API:**
   - App Store Connect → Users and Access → Keys → App Store Connect API
   - Создайте ключ с правами на In-App Purchases
   - Сохраните:
     - Key ID
     - Issuer ID
     - .p8 файл (приватный ключ)

## Настройка на сервере

Добавьте следующие переменные окружения:

```bash
# Apple IAP настройки
APPLE_IAP_KEY_ID=your_key_id_here
APPLE_IAP_ISSUER_ID=your_issuer_id_here
APPLE_IAP_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
APPLE_BUNDLE_ID=com.aviapoint.app
```

**Важно:** 
- `APPLE_IAP_PRIVATE_KEY` должен содержать весь приватный ключ в формате PEM, включая заголовки
- Используйте `\n` для переносов строк в переменной окружения
- Или сохраните ключ в файл и загрузите его содержимое

## Миграция базы данных

Миграция `073_add_iap_support_to_payments.sql` автоматически добавит необходимые поля:
- `payment_source` - источник платежа ('yookassa' или 'apple_iap')
- `apple_transaction_id` - Transaction ID от Apple
- `apple_original_transaction_id` - Original Transaction ID для отслеживания подписок

## API Endpoint

### POST /api/payments/verify-iap

Верифицирует IAP транзакцию от iOS приложения.

**Request Body:**
```json
{
  "receipt_data": "base64_encoded_receipt",
  "transaction_id": "1000000123456789",
  "user_id": 123,
  "original_transaction_id": "1000000123456789",
  "is_sandbox": false
}
```

**Response:**
```json
{
  "status": "success",
  "payment_id": "iap_1000000123456789",
  "transaction_id": "1000000123456789",
  "subscription_type": "monthly",
  "expires_date": "2024-02-01T00:00:00Z"
}
```

## Интеграция в iOS приложение

1. Используйте пакет `in_app_purchase` для работы с IAP
2. После успешной покупки отправьте receipt data на сервер:

```dart
final response = await http.post(
  Uri.parse('https://your-server.com/api/payments/verify-iap'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'receipt_data': receiptData,
    'transaction_id': transactionId,
    'user_id': userId,
    'original_transaction_id': originalTransactionId,
    'is_sandbox': isSandbox,
  }),
);
```

## Маппинг Product ID → Subscription Type

Сервер автоматически определяет тип подписки из Product ID:
- `monthly` → если Product ID содержит "monthly"
- `yearly` → если Product ID содержит "yearly" или "year"
- `quarterly` → если Product ID содержит "quarterly"
- По умолчанию → `rosaviatest_365`

Убедитесь, что Product ID в App Store Connect соответствуют этим паттернам.

## Тестирование

1. Создайте Sandbox Test Account в App Store Connect
2. Используйте тестовый Apple ID в приложении
3. Установите `is_sandbox: true` при верификации
4. Проверьте логи сервера для отладки

## Важные замечания

- Apple берет комиссию 30% в первый год, 15% со второго года
- Все подписки синхронизируются между платформами (iOS, Android, Web)
- Transaction ID должен быть уникальным - сервер проверяет дубликаты
- Для production используйте production URL, для тестирования - sandbox URL
