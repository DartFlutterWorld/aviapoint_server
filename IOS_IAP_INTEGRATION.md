# Интеграция Apple In-App Purchases в iOS приложение (Flutter)

## Обзор

После настройки сервера нужно интегрировать IAP в iOS приложение. Пользователи смогут покупать подписки через App Store, а сервер будет автоматически их верифицировать и активировать.

## Шаг 1: Добавление зависимости

В `pubspec.yaml` вашего Flutter приложения добавьте:

```yaml
dependencies:
  in_app_purchase: ^3.1.11
```

Затем выполните:
```bash
flutter pub get
```

## Шаг 2: Настройка Product ID

Создайте файл с константами Product ID (соответствуют тем, что создали в App Store Connect):

```dart
// lib/constants/iap_products.dart
class IAPProducts {
  // Product ID должен совпадать с тем, что в App Store Connect
  static const String yearlySubscription = 'com.aviapoint.subscription.rosaviatest.yearly';
  
  // Если добавите другие подписки:
  // static const String monthlySubscription = 'com.aviapoint.subscription.rosaviatest.monthly';
  // static const String quarterlySubscription = 'com.aviapoint.subscription.rosaviatest.quarterly';
  
  static const List<String> allProducts = [yearlySubscription];
}
```

## Шаг 3: Создание сервиса для работы с IAP

```dart
// lib/services/iap_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import '../constants/iap_products.dart';

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // URL вашего сервера
  static const String serverUrl = 'https://avia-point.com'; // или ваш URL
  
  /// Инициализация IAP
  Future<bool> initialize() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      print('IAP not available');
      return false;
    }
    
    // Слушаем обновления покупок
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Purchase stream error: $error'),
    );
    
    return true;
  }
  
  /// Загрузка доступных продуктов
  Future<List<ProductDetails>> loadProducts() async {
    final Set<String> productIds = IAPProducts.allProducts.toSet();
    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);
    
    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }
    
    if (response.error != null) {
      print('Error loading products: ${response.error}');
      return [];
    }
    
    return response.productDetails;
  }
  
  /// Покупка подписки
  Future<bool> buySubscription(String productId, int userId) async {
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails({productId});
      
      if (response.productDetails.isEmpty) {
        print('Product not found: $productId');
        return false;
      }
      
      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
      
      // Запускаем покупку
      final bool success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (!success) {
        print('Failed to initiate purchase');
        return false;
      }
      
      // Обработка покупки произойдет в _onPurchaseUpdate
      return true;
    } catch (e) {
      print('Error buying subscription: $e');
      return false;
    }
  }
  
  /// Обработка обновлений покупок
  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        // Покупка в процессе
        print('Purchase pending: ${purchase.productID}');
        continue;
      }
      
      if (purchase.status == PurchaseStatus.error) {
        // Ошибка покупки
        print('Purchase error: ${purchase.error}');
        _handlePurchaseError(purchase);
        continue;
      }
      
      if (purchase.status == PurchaseStatus.purchased || 
          purchase.status == PurchaseStatus.restored) {
        // Покупка успешна - верифицируем на сервере
        await _verifyPurchaseOnServer(purchase);
      }
      
      // Завершаем транзакцию
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
  
  /// Верификация покупки на сервере
  Future<void> _verifyPurchaseOnServer(PurchaseDetails purchase) async {
    try {
      // Получаем userId (из вашей системы аутентификации)
      final int userId = await _getCurrentUserId(); // Реализуйте этот метод
      
      // Определяем, это Sandbox или Production
      final bool isSandbox = purchase.verificationData.source == 'app_store';
      
      // Отправляем на сервер для верификации
      final response = await http.post(
        Uri.parse('$serverUrl/api/payments/verify-iap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'receipt_data': purchase.verificationData.serverVerificationData,
          'transaction_id': purchase.purchaseID ?? '',
          'user_id': userId,
          'original_transaction_id': purchase.transactionDate ?? '',
          'is_sandbox': !isSandbox, // В Sandbox source будет 'sandbox'
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Purchase verified: ${data['payment_id']}');
        
        // Обновляем статус подписки в приложении
        await _updateSubscriptionStatus(data);
      } else {
        print('Verification failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error verifying purchase: $e');
    }
  }
  
  /// Получение текущего userId
  Future<int> _getCurrentUserId() async {
    // Реализуйте получение userId из вашей системы аутентификации
    // Например, из SharedPreferences, токена и т.д.
    // Это пример - замените на вашу реализацию
    return 0; // TODO: получить реальный userId
  }
  
  /// Обновление статуса подписки после верификации
  Future<void> _updateSubscriptionStatus(Map<String, dynamic> data) async {
    // Сохраните информацию о подписке в локальное хранилище
    // Например, в SharedPreferences или в вашу локальную БД
    print('Subscription activated: ${data['subscription_type']}');
    print('Expires: ${data['expires_date']}');
    
    // Обновите UI, покажите уведомление об успешной покупке
  }
  
  /// Обработка ошибки покупки
  void _handlePurchaseError(PurchaseDetails purchase) {
    print('Purchase error: ${purchase.error}');
    // Покажите пользователю сообщение об ошибке
  }
  
  /// Восстановление покупок
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: $e');
    }
  }
  
  /// Очистка ресурсов
  void dispose() {
    _subscription?.cancel();
  }
}
```

## Шаг 4: Использование в UI

```dart
// lib/screens/subscription_screen.dart
import 'package:flutter/material.dart';
import '../services/iap_service.dart';
import '../constants/iap_products.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final IAPService _iapService = IAPService();
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }
  
  Future<void> _initializeIAP() async {
    final bool available = await _iapService.initialize();
    if (!available) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    final products = await _iapService.loadProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }
  
  Future<void> _buySubscription(String productId) async {
    // Получите userId из вашей системы аутентификации
    final int userId = await _getCurrentUserId(); // TODO: реализуйте
    
    final success = await _iapService.buySubscription(productId, userId);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось начать покупку')),
      );
    }
  }
  
  Future<int> _getCurrentUserId() async {
    // TODO: получить userId из вашей системы
    return 0;
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('Подписка')),
      body: ListView(
        children: [
          // Годовая подписка
          if (_products.any((p) => p.id == IAPProducts.yearlySubscription))
            _buildSubscriptionCard(
              _products.firstWhere((p) => p.id == IAPProducts.yearlySubscription),
              'Годовая подписка',
              'Полный доступ на год',
            ),
        ],
      ),
    );
  }
  
  Widget _buildSubscriptionCard(ProductDetails product, String title, String description) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              product.price,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(product.priceCurrencyCode),
          ],
        ),
        onTap: () => _buySubscription(product.id),
      ),
    );
  }
  
  @override
  void dispose() {
    _iapService.dispose();
    super.dispose();
  }
}
```

## Шаг 5: Настройка для тестирования

1. **Создайте Sandbox Test Account:**
   - App Store Connect → Users and Access → Sandbox Testers
   - Создайте тестовый Apple ID

2. **Тестирование:**
   - Выйдите из App Store на устройстве
   - Используйте Sandbox Test Account при покупке
   - Сервер автоматически определит Sandbox по `is_sandbox: true`

## Шаг 6: Обработка ошибок

Добавьте обработку различных сценариев:
- Пользователь отменил покупку
- Ошибка сети при верификации
- Дубликат транзакции (уже обработана)
- Проблемы с подключением к серверу

## Важные замечания

1. **Product ID должен совпадать** с тем, что в App Store Connect
2. **Верификация обязательна** - всегда проверяйте покупки на сервере
3. **Восстановление покупок** - реализуйте кнопку "Восстановить покупки"
4. **Обработка подписок** - проверяйте статус подписки при запуске приложения

## Проверка работы

1. Запустите приложение на реальном устройстве (не симулятор)
2. Используйте Sandbox Test Account
3. Попробуйте купить подписку
4. Проверьте логи сервера - должна быть верификация
5. Проверьте, что подписка активировалась в БД
