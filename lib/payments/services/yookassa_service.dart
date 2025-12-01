import 'dart:convert';
import 'dart:math';
import 'package:aviapoint_server/core/config/config.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/payments/model/payment_model.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class YooKassaService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.yookassa.ru/v3';

  YooKassaService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Базовая аутентификация для ЮKassa
    final credentials = base64Encode(
      utf8.encode('${Config.yookassaShopId}:${Config.yookassaSecretKey}'),
    );
    _dio.options.headers['Authorization'] = 'Basic $credentials';
  }

  /// Создание платежа в ЮKassa
  Future<PaymentModel> createPayment({
    required double amount,
    required String currency,
    required String description,
    String? returnUrl,
    String? cancelUrl,
    String? customerPhone,
    String? subscriptionType,
    int? periodDays,
    int? userId,
  }) async {
    try {
      logger.info('Creating payment in YooKassa: amount=$amount, currency=$currency');

      // Валидация URL (если предоставлены)
      if (returnUrl != null) {
        if (!returnUrl.startsWith('http://') && !returnUrl.startsWith('https://')) {
          throw ArgumentError('return_url must start with http:// or https://');
        }
      }
      if (cancelUrl != null) {
        if (!cancelUrl.startsWith('http://') && !cancelUrl.startsWith('https://')) {
          throw ArgumentError('cancel_url must start with http:// or https://');
        }
      }

      // Формируем данные запроса
      final requestData = <String, dynamic>{
        'amount': {
          'value': amount.toStringAsFixed(2),
          'currency': currency,
        },
        'capture': true,
        'description': description,
      };

      // Сохраняем subscription_type, period_days и user_id в metadata для использования в webhook
      if (subscriptionType != null || periodDays != null || userId != null) {
        requestData['metadata'] = <String, dynamic>{};
        if (subscriptionType != null) {
          requestData['metadata']['subscription_type'] = subscriptionType;
        }
        if (periodDays != null) {
          requestData['metadata']['period_days'] = periodDays;
        }
        if (userId != null) {
          requestData['metadata']['user_id'] = userId;
        }
      }

      // confirmation обязателен для создания платежа в ЮKassa
      // Для мобильных приложений используем deep link, если returnUrl не передан
      final finalReturnUrl = returnUrl ?? 'aviapoint://payment/return';

      requestData['confirmation'] = {
        'type': 'redirect',
        'return_url': finalReturnUrl,
      };

      // Добавляем receipt с customer
      // По российскому законодательству нужен email или телефон для отправки фискального чека
      // Используем переданный телефон или дефолтный
      final receiptPhone = customerPhone ?? '+79999999999';

      requestData['receipt'] = {
        'customer': {
          'phone': receiptPhone,
        },
        'items': [
          {
            'description': description,
            'quantity': '1.00',
            'amount': {
              'value': amount.toStringAsFixed(2),
              'currency': currency,
            },
            'vat_code': 1, // НДС не облагается (для УСН)
          },
        ],
      };

      logger.info('Request data to YooKassa: ${jsonEncode(requestData)}');
      logger.info('Return URL: $returnUrl');
      logger.info('Cancel URL: $cancelUrl');

      // Генерируем уникальный ключ для идемпотентности
      // Используем комбинацию timestamp и случайных байтов
      final random = Random.secure();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomBytes = List<int>.generate(16, (i) => random.nextInt(256));
      final idempotenceKey = sha256.convert([...utf8.encode(timestamp.toString()), ...randomBytes]).toString();

      logger.info('Idempotence-Key: $idempotenceKey');

      final response = await _dio.post(
        '/payments',
        data: requestData,
        options: Options(
          headers: {
            'Idempotence-Key': idempotenceKey,
          },
        ),
      );

      logger.info('Payment created successfully: ${response.data['id']}');

      return PaymentModel(
        id: response.data['id'],
        status: response.data['status'],
        amount: double.parse(response.data['amount']['value']),
        currency: response.data['amount']['currency'],
        description: response.data['description'] ?? description,
        paymentUrl: response.data['confirmation']?['confirmation_url'],
        createdAt: DateTime.parse(response.data['created_at']),
        paid: response.data['paid'] ?? false,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to create payment in YooKassa: $e');

      // Логируем детали ошибки от Dio
      if (e is DioException) {
        logger.severe('DioException details:');
        logger.severe('  Status code: ${e.response?.statusCode}');
        logger.severe('  Status message: ${e.response?.statusMessage}');
        logger.severe('  Response data: ${e.response?.data}');
        logger.severe('  Request path: ${e.requestOptions.path}');
        logger.severe('  Request data: ${e.requestOptions.data}');
        logger.severe('  Request headers: ${e.requestOptions.headers}');
      }

      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Получение информации о платеже
  Future<PaymentModel> getPayment(String paymentId) async {
    try {
      logger.info('Getting payment info: $paymentId');

      final response = await _dio.get('/payments/$paymentId');

      logger.info('Payment info retrieved: ${response.data['id']}');

      return PaymentModel(
        id: response.data['id'],
        status: response.data['status'],
        amount: double.parse(response.data['amount']['value']),
        currency: response.data['amount']['currency'],
        description: response.data['description'] ?? '',
        paymentUrl: response.data['confirmation']?['confirmation_url'],
        createdAt: DateTime.parse(response.data['created_at']),
        paid: response.data['paid'] ?? false,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to get payment info: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
