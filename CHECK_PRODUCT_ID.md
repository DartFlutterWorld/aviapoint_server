# Как проверить, что Product ID совпадает с App Store Connect

## Шаг 1: Найти Product ID в коде

Product ID находится в файле:
```
../aviapoint/lib/payment/data/datasources/iap_service.dart
```

Текущий Product ID в коде:
```dart
class IAPProducts {
  static const String yearlySubscription = 'com.aviapoint.subscription.rosaviatest.yearly';
  static const List<String> allProducts = [yearlySubscription];
}
```

**Текущий Product ID:** `com.aviapoint.subscription.rosaviatest.yearly`

## Шаг 2: Проверить Product ID в App Store Connect

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите: **Ваше приложение** → **Распространение** → **Подписки**
3. Откройте группу подписок "РосАвиаТест"
4. Нажмите на подписку "РосАвиаТест - Годовая подписка"
5. Найдите поле **"ID продукта"** (Product ID)

## Шаг 3: Сравнить

Product ID в коде должен **точно совпадать** с Product ID в App Store Connect.

### ✅ Правильно:
- Код: `com.aviapoint.subscription.rosaviatest.yearly`
- App Store Connect: `com.aviapoint.subscription.rosaviatest.yearly`
- **Совпадает** ✅

### ❌ Неправильно:
- Код: `com.aviapoint.subscription.rosaviatest.yearly`
- App Store Connect: `com.aviapoint.subscription.yearly`
- **Не совпадает** ❌

## Шаг 4: Если не совпадает

Если Product ID не совпадает, нужно:

1. **Вариант 1 (рекомендуется):** Изменить код, чтобы совпадал с App Store Connect
   - Откройте `../aviapoint/lib/payment/data/datasources/iap_service.dart`
   - Измените значение `yearlySubscription` на Product ID из App Store Connect

2. **Вариант 2:** Изменить Product ID в App Store Connect
   - ⚠️ **Внимание:** Product ID нельзя изменить после создания!
   - Нужно будет удалить старый продукт и создать новый

## Быстрая проверка через терминал

Можно быстро проверить Product ID в коде:

```bash
cd ../aviapoint
grep -r "yearlySubscription" lib/payment/data/datasources/iap_service.dart
```

Или посмотреть весь класс IAPProducts:

```bash
cd ../aviapoint
grep -A 3 "class IAPProducts" lib/payment/data/datasources/iap_service.dart
```

## Важно

- Product ID чувствителен к регистру
- Должен совпадать **точно**, включая все точки и подчеркивания
- Если не совпадает - покупки не будут работать
