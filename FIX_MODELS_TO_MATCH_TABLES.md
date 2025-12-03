# 🔧 Приведение кода в соответствие со структурой таблиц

## Проблемы, которые были исправлены

### 1. PaymentModel - добавлены недостающие поля

**Было:**
- Не было полей `subscription_type` и `period_days`

**Стало:**
- Добавлены поля `subscriptionType` и `periodDays` в модель
- Обновлен `.g.dart` файл

### 2. Subscriptions - лишнее поле `amount`

**Проблема:**
- В таблице `subscriptions` есть поле `amount` (integer), которого не должно быть
- Amount должен храниться только в таблице `payments`

**Решение:**
- Создана миграция для удаления поля `amount` из `subscriptions`

---

## Что нужно сделать

### 1. Удалить лишнее поле `amount` из таблицы `subscriptions`

```bash
# На сервере
psql -h localhost -U postgres -d aviapoint -f migrations/remove_amount_from_subscriptions.sql
```

Или через Adminer:
```sql
ALTER TABLE subscriptions DROP COLUMN IF EXISTS amount;
```

### 2. Перегенерировать .g.dart файлы

```bash
fvm dart pub run build_runner build --delete-conflicting-outputs
```

---

## Текущее соответствие моделей и таблиц

### PaymentModel ↔ payments

| Поле в модели | Поле в таблице | Тип | Статус |
|--------------|----------------|-----|--------|
| `id` | `id` | VARCHAR(255) | ✅ |
| `status` | `status` | VARCHAR(50) | ✅ |
| `amount` | `amount` | NUMERIC(10,2) | ✅ |
| `currency` | `currency` | VARCHAR(10) | ✅ |
| `description` | `description` | TEXT | ✅ |
| `paymentUrl` | `payment_url` | TEXT | ✅ |
| `createdAt` | `created_at` | TIMESTAMP | ✅ |
| `paid` | `paid` | BOOLEAN | ✅ |
| `userId` | `user_id` | INTEGER | ✅ |
| `subscriptionType` | `subscription_type` | VARCHAR(50) | ✅ **Добавлено** |
| `periodDays` | `period_days` | INTEGER | ✅ **Добавлено** |

### SubscriptionModel ↔ subscriptions

| Поле в модели | Поле в таблице | Тип | Статус |
|--------------|----------------|-----|--------|
| `id` | `id` | INTEGER | ✅ |
| `userId` | `user_id` | INTEGER | ✅ |
| `paymentId` | `payment_id` | VARCHAR(255) | ✅ |
| `subscriptionTypeId` | `subscription_type_id` | INTEGER | ✅ |
| `periodDays` | `period_days` | INTEGER | ✅ |
| `startDate` | `start_date` | TIMESTAMP | ✅ |
| `endDate` | `end_date` | TIMESTAMP | ✅ |
| `isActive` | `is_active` | BOOLEAN | ✅ |
| `autoRenew` | `auto_renew` | BOOLEAN | ✅ |
| `createdAt` | `created_at` | TIMESTAMP | ✅ |
| `updatedAt` | `updated_at` | TIMESTAMP | ✅ |
| - | `amount` | INTEGER | ❌ **Удалить из БД** |

---

## Проверка после исправлений

### Проверить структуру таблиц:

```sql
-- Проверить payments
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'payments'
ORDER BY ordinal_position;

-- Проверить subscriptions
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'subscriptions'
ORDER BY ordinal_position;
```

### Проверить, что модели работают:

```dart
// PaymentModel должен корректно парсить данные из БД
final payment = PaymentModel.fromJson(dbRow.toColumnMap());

// SubscriptionModel должен корректно парсить данные из БД
final subscription = SubscriptionModel.fromJson(dbRow.toColumnMap());
```

---

## Миграции для применения

1. **Удалить amount из subscriptions:**
   ```bash
   psql -h localhost -U postgres -d aviapoint -f migrations/remove_amount_from_subscriptions.sql
   ```

2. **Сделать payment_id nullable в subscriptions (если еще не сделано):**
   ```bash
   psql -h localhost -U postgres -d aviapoint -f migrations/make_payment_id_nullable_in_subscriptions.sql
   ```

---

**Готово!** Теперь модели соответствуют структуре таблиц! ✅

