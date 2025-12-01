# Настройка бэкенда для платежей ЮKassa

## ✅ Что уже сделано

1. ✅ Добавлена конфигурация для ЮKassa в `Config`:
   - `yookassaShopId` (по умолчанию: 1214860)
   - `yookassaSecretKey` (по умолчанию: live_A8iyj3kBLfq4YUiKwlHoPpvBP0B7BQIBhY3vOPuDisc)

2. ✅ Создана структура модуля платежей:
   - `lib/payments/api/create_payment_request.dart` - DTO для создания платежа
   - `lib/payments/model/payment_model.dart` - модель платежа
   - `lib/payments/services/yookassa_service.dart` - сервис для работы с API ЮKassa
   - `lib/payments/repositories/payment_repository.dart` - репозиторий для работы с БД
   - `lib/payments/controllers/payment_controller.dart` - контроллер с endpoints

3. ✅ Зарегистрированы зависимости в DI контейнере
4. ✅ Добавлен роутер в `main.dart`
5. ✅ Создана SQL миграция `migrations/create_payments_table.sql`

## 🔧 Что нужно сделать

### 1. Запустить build_runner для генерации кода

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Это сгенерирует:
- `*.g.dart` файлы для Freezed моделей
- `payment_controller.g.dart` для роутера

### 2. Выполнить SQL миграцию

Подключитесь к базе данных и выполните:

```sql
-- Создание таблицы для хранения платежей
CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(255) PRIMARY KEY,
    status VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'RUB',
    description TEXT,
    payment_url TEXT,
    created_at TIMESTAMP NOT NULL,
    paid BOOLEAN NOT NULL DEFAULT false,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);
```

Или выполните файл миграции:
```bash
psql -h localhost -U postgres -d aviapoint -f migrations/create_payments_table.sql
```

### 3. Настроить переменные окружения (опционально)

Если хотите использовать другие значения, добавьте в `.env` или переменные окружения:

```bash
YOOKASSA_SHOP_ID=1214860
YOOKASSA_SECRET_KEY=live_A8iyj3kBLfq4YUiKwlHoPpvBP0B7BQIBhY3vOPuDisc
```

## 📡 API Endpoints

### POST `/payments/create`

Создает платеж в ЮKassa и возвращает paymentUrl.

**Request:**
```json
{
  "amount": 1000.00,
  "currency": "RUB",
  "description": "Оплата подписки AviaPoint",
  "return_url": "aviapoint://payment/success",
  "cancel_url": "aviapoint://payment/cancel"
}
```

**Response:**
```json
{
  "id": "2c5d5b87-0001-5000-8000-1d5e5b5b5b5b",
  "status": "pending",
  "amount": 1000.00,
  "currency": "RUB",
  "description": "Оплата подписки AviaPoint",
  "payment_url": "https://yookassa.ru/checkout/payments/...",
  "created_at": "2024-01-01T12:00:00Z",
  "paid": false
}
```

### GET `/payments/{paymentId}/status`

Проверяет статус платежа.

**Response:**
```json
{
  "id": "2c5d5b87-0001-5000-8000-1d5e5b5b5b5b",
  "status": "succeeded",
  "amount": 1000.00,
  "currency": "RUB",
  "description": "Оплата подписки AviaPoint",
  "paid": true,
  "created_at": "2024-01-01T12:00:00Z"
}
```

### POST `/payments/webhook`

Webhook от ЮKassa для уведомления о статусе платежа. Этот endpoint должен быть настроен в личном кабинете ЮKassa.

**Настройка webhook в ЮKassa:**
1. Зайдите в личный кабинет ЮKassa
2. Перейдите в раздел "Настройки" → "Уведомления"
3. Добавьте URL: `https://ваш-домен.ru/payments/webhook`
4. Выберите события: `payment.succeeded` и `payment.canceled`

## 🔐 Безопасность

⚠️ **ВАЖНО:**
- Секретный ключ хранится только на бэкенде (в переменных окружения)
- Webhook должен проверять подпись запросов (можно добавить позже)
- Все платежи сохраняются в БД для истории

## 🧪 Тестирование

1. Используйте тестовые данные карт от ЮKassa:
   - Номер карты: `5555 5555 5555 4444`
   - Срок действия: любая будущая дата
   - CVC: любые 3 цифры

2. Проверьте endpoints через Swagger UI:
   - Откройте `http://localhost:8080/openapi/`
   - Найдите раздел "PaymentController"
   - Протестируйте создание платежа

## 📝 Чек-лист

- [ ] Запущен `build_runner` для генерации кода
- [ ] Выполнена SQL миграция для создания таблицы `payments`
- [ ] Настроены переменные окружения (если нужно)
- [ ] Настроен webhook URL в личном кабинете ЮKassa
- [ ] Протестировано создание платежа через API
- [ ] Протестирована проверка статуса платежа
- [ ] Протестирован webhook (можно использовать ngrok для локальной разработки)

## 🔗 Полезные ссылки

- Документация ЮKassa API: https://yookassa.ru/developers/api
- Документация для самозанятых: https://yookassa.ru/developers/payment-acceptance/getting-started/self-employed

---

**После выполнения всех шагов бэкенд для платежей будет готов!** 🎉

