import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/payments/model/payment_model.dart';
import 'package:aviapoint_server/payments/services/yookassa_service.dart';
import 'package:postgres/postgres.dart';

class PaymentRepository {
  final Connection _connection;
  final YooKassaService _yookassaService;

  PaymentRepository({required Connection connection, required YooKassaService yookassaService})
      : _connection = connection,
        _yookassaService = yookassaService;

  /// Создание платежа
  Future<PaymentModel> createPayment({
    required double amount,
    required String currency,
    required String description,
    String? returnUrl,
    String? cancelUrl,
    int? userId,
    String? customerPhone,
    String? subscriptionType,
    int? periodDays,
  }) async {
    try {
      // Создаем платеж в ЮKassa
      // Сначала создаем платеж без payment_id в return_url
      final payment = await _yookassaService.createPayment(
        amount: amount,
        currency: currency,
        description: description,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
        customerPhone: customerPhone,
        subscriptionType: subscriptionType,
        periodDays: periodDays,
        userId: userId,
      );

      // НЕ сохраняем платеж в БД сразу - сохраним только после успешной оплаты через webhook
      // Это позволяет избежать накопления неоплаченных платежей в БД
      // Платеж будет сохранен автоматически в updatePaymentStatus при получении webhook

      logger.info('Payment created in YooKassa: ${payment.id}, user_id: $userId (will be saved after successful payment)');

      // ВАЖНО: ЮKassa не передает payment_id в query параметрах при редиректе
      // Поэтому payment_id нужно получать из других источников (последние платежи пользователя, webhook и т.д.)

      return payment;
    } catch (e, stackTrace) {
      logger.severe('Failed to create payment: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Получение платежа по ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      // Сначала проверяем в БД
      final dbResult = await _connection.execute(Sql.named('SELECT * FROM payments WHERE id = @id'), parameters: {'id': paymentId});

      if (dbResult.isEmpty) {
        // Если нет в БД, получаем из ЮKassa
        return await _yookassaService.getPayment(paymentId);
      }

      final row = dbResult.first;
      return PaymentModel.fromJson(row.toColumnMap());
    } catch (e, stackTrace) {
      logger.severe('Failed to get payment: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Получение платежа напрямую из API ЮKassa (без проверки БД)
  /// Используется для получения актуального статуса, когда БД может быть еще не обновлена
  Future<PaymentModel?> getPaymentFromYooKassa(String paymentId) async {
    try {
      return await _yookassaService.getPayment(paymentId);
    } catch (e, stackTrace) {
      logger.severe('Failed to get payment from YooKassa: $e');
      logger.severe('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Получение последних успешных платежей пользователя за указанный период
  /// Используется для определения payment_id, если он не передан в URL
  Future<List<PaymentModel>> getRecentSuccessfulPayments({int? userId, int minutes = 10}) async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(minutes: minutes));

      // Если userId не передан, получаем последние успешные платежи всех пользователей
      // Это нужно, так как при редиректе с ЮKassa мы не знаем userId
      final dbResult = userId != null
          ? await _connection.execute(
              Sql.named('''
                SELECT * FROM payments 
                WHERE user_id = @user_id 
                  AND (status = 'succeeded' OR paid = true)
                  AND created_at >= @cutoff_time
                ORDER BY created_at DESC
                LIMIT 1
              '''),
              parameters: {
                'user_id': userId,
                'cutoff_time': cutoffTime,
              },
            )
          : await _connection.execute(
              Sql.named('''
                SELECT * FROM payments 
                WHERE (status = 'succeeded' OR paid = true)
                  AND created_at >= @cutoff_time
                ORDER BY created_at DESC
                LIMIT 1
              '''),
              parameters: {
                'cutoff_time': cutoffTime,
              },
            );

      if (dbResult.isEmpty) {
        return [];
      }

      return dbResult.map((row) => PaymentModel.fromJson(row.toColumnMap())).toList();
    } catch (e, stackTrace) {
      logger.severe('Failed to get recent successful payments: $e');
      logger.severe('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Получение полных данных платежа из БД (включая subscription_type и period_days)
  Future<Map<String, dynamic>?> getPaymentDataById(String paymentId) async {
    try {
      final dbResult = await _connection.execute(Sql.named('SELECT * FROM payments WHERE id = @id'), parameters: {'id': paymentId});

      if (dbResult.isEmpty) {
        return null;
      }

      return dbResult.first.toColumnMap();
    } catch (e, stackTrace) {
      logger.severe('Failed to get payment data: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Обновление статуса платежа
  /// Принимает paymentObject для получения metadata с subscription_type и period_days
  Future<void> updatePaymentStatus({required String paymentId, required String status, required bool paid, Map<String, dynamic>? paymentObject}) async {
    try {
      // Проверяем, существует ли платеж в БД
      final existingPayment = await _connection.execute(Sql.named('SELECT id FROM payments WHERE id = @id'), parameters: {'id': paymentId});

      if (existingPayment.isEmpty) {
        // Если платежа нет в БД, пытаемся получить информацию из paymentObject или из ЮKassa
        // Используем данные из paymentObject (приходят в webhook), если они есть
        // Иначе запрашиваем из ЮKassa

        logger.info('Payment $paymentId not found in DB, creating new record from webhook');
        logger.info('Payment object keys: ${paymentObject?.keys.toList()}');

        double amount = 0.0;
        String currency = 'RUB';
        String description = '';
        String paymentUrl = '';
        DateTime createdAt = DateTime.now();

        // Пытаемся извлечь данные из paymentObject (приходит в webhook)
        if (paymentObject != null) {
          try {
            final amountObj = paymentObject['amount'] as Map<String, dynamic>?;
            if (amountObj != null) {
              amount = double.tryParse(amountObj['value']?.toString() ?? '0') ?? 0.0;
              currency = amountObj['currency']?.toString() ?? 'RUB';
              logger.info('Extracted from webhook: amount=$amount, currency=$currency');
            }
            description = paymentObject['description']?.toString() ?? '';
            final confirmation = paymentObject['confirmation'] as Map<String, dynamic>?;
            paymentUrl = confirmation?['confirmation_url']?.toString() ?? '';
            final createdAtStr = paymentObject['created_at']?.toString();
            if (createdAtStr != null) {
              createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
            }
            logger.info('Extracted: description=$description, paymentUrl=$paymentUrl, createdAt=$createdAt');
          } catch (e, stackTrace) {
            logger.severe('Failed to parse payment data from webhook object: $e');
            logger.severe('Stack trace: $stackTrace');
          }
        } else {
          logger.severe('Payment object is null in webhook for payment $paymentId');
        }

        // Если данных недостаточно, пытаемся получить из ЮKassa
        // Но только если это не тестовый платеж (не начинается с "test-")
        if (amount == 0.0 && !paymentId.startsWith('test-')) {
          try {
            final payment = await _yookassaService.getPayment(paymentId);
            amount = payment.amount;
            currency = payment.currency;
            description = payment.description;
            paymentUrl = payment.paymentUrl;
            createdAt = payment.createdAt;
            // Обновляем данные из metadata платежа, если они есть
            // (эти данные уже должны быть в payment, но на всякий случай)
          } catch (e) {
            logger.info('Failed to get payment from YooKassa: $e. Using data from webhook object.');
            // Продолжаем с данными из paymentObject
          }
        }

        // Получаем subscription_type, period_days и user_id из metadata платежа
        String subscriptionType = '';
        int periodDays = 0;
        int userIdFromMetadata = 0;

        // Пытаемся получить из metadata (сохранены при создании платежа)
        if (paymentObject != null) {
          final metadata = paymentObject['metadata'] as Map<String, dynamic>?;
          if (metadata != null) {
            subscriptionType = metadata['subscription_type']?.toString() ?? '';
            final periodDaysStr = metadata['period_days'];
            if (periodDaysStr != null) {
              periodDays = periodDaysStr is int ? periodDaysStr : (int.tryParse(periodDaysStr.toString()) ?? 0);
            }
            final userIdStr = metadata['user_id'];
            if (userIdStr != null) {
              userIdFromMetadata = userIdStr is int ? userIdStr : (int.tryParse(userIdStr.toString()) ?? 0);
            }
          }
        }

        // Проверяем, существует ли пользователь, если user_id указан
        // Для тестовых платежей или если пользователь не найден, используем 0
        int finalUserId = userIdFromMetadata;
        if (userIdFromMetadata > 0) {
          try {
            final userCheck = await _connection.execute(Sql.named('SELECT id FROM profiles WHERE id = @user_id'), parameters: {'user_id': userIdFromMetadata});
            if (userCheck.isEmpty) {
              logger.info('User $userIdFromMetadata not found in profiles, setting user_id to 0 for payment $paymentId');
              finalUserId = 0;
            }
          } catch (e) {
            logger.info('Error checking user existence: $e, setting user_id to 0');
            finalUserId = 0;
          }
        }

        logger.info('Inserting payment into DB: id=$paymentId, status=$status, amount=$amount, user_id=$finalUserId, subscription_type=$subscriptionType, period_days=$periodDays');

        try {
          await _connection.execute(
            Sql.named('''
              INSERT INTO payments (
                id, status, amount, currency, description, 
                payment_url, created_at, paid, subscription_type, period_days, user_id
              ) VALUES (
                @id, @status, @amount, @currency, @description,
                @payment_url, @created_at, @paid, @subscription_type, @period_days, @user_id
              )
            '''),
            parameters: {
              'id': paymentId,
              'status': status,
              'amount': amount,
              'currency': currency,
              'description': description,
              'payment_url': paymentUrl,
              'created_at': createdAt,
              'paid': paid,
              'subscription_type': subscriptionType,
              'period_days': periodDays,
              'user_id': finalUserId,
            },
          );
          logger.info('Payment successfully saved to database: $paymentId -> $status (paid: $paid, user_id: $finalUserId)');
        } catch (insertError, insertStackTrace) {
          logger.severe('Failed to INSERT payment into database: $insertError');
          logger.severe('Payment ID: $paymentId');
          logger.severe('Parameters: status=$status, amount=$amount, user_id=$finalUserId');
          logger.severe('Stack trace: $insertStackTrace');
          rethrow;
        }
      } else {
        // Обновляем существующий платеж
        await _connection.execute(
          Sql.named('''
            UPDATE payments 
            SET status = @status, paid = @paid
            WHERE id = @id
          '''),
          parameters: {'id': paymentId, 'status': status, 'paid': paid},
        );
        logger.info('Payment status updated: $paymentId -> $status');
      }
    } catch (e, stackTrace) {
      logger.severe('Failed to update payment status: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Создание платежа из Apple IAP
  Future<void> createIAPPayment({
    required String paymentId,
    required int userId,
    required String transactionId,
    required String originalTransactionId,
    required String subscriptionType,
    required int periodDays,
    required double amount,
    required DateTime purchaseDate,
  }) async {
    try {
      await _connection.execute(
        Sql.named('''
          INSERT INTO payments (
            id, status, amount, currency, description,
            payment_url, created_at, paid, subscription_type, period_days, user_id,
            payment_source, apple_transaction_id, apple_original_transaction_id
          ) VALUES (
            @id, @status, @amount, @currency, @description,
            @payment_url, @created_at, @paid, @subscription_type, @period_days, @user_id,
            @payment_source, @apple_transaction_id, @apple_original_transaction_id
          )
        '''),
        parameters: {
          'id': paymentId,
          'status': 'succeeded',
          'amount': amount,
          'currency': 'USD', // Apple IAP всегда в USD (или валюта App Store)
          'description': 'Apple In-App Purchase: $subscriptionType',
          'payment_url': '',
          'created_at': purchaseDate,
          'paid': true,
          'subscription_type': subscriptionType,
          'period_days': periodDays,
          'user_id': userId,
          'payment_source': 'apple_iap',
          'apple_transaction_id': transactionId,
          'apple_original_transaction_id': originalTransactionId,
        },
      );
      logger.info('IAP payment created: $paymentId, transaction: $transactionId');
    } catch (e, stackTrace) {
      logger.severe('Failed to create IAP payment: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Получение платежа по Apple transaction_id
  Future<PaymentModel?> getPaymentByAppleTransactionId(String transactionId) async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM payments WHERE apple_transaction_id = @transaction_id'),
        parameters: {'transaction_id': transactionId},
      );

      if (result.isEmpty) {
        return null;
      }

      return PaymentModel.fromJson(result.first.toColumnMap());
    } catch (e, stackTrace) {
      logger.severe('Failed to get payment by Apple transaction ID: $e');
      logger.severe('Stack trace: $stackTrace');
      return null;
    }
  }
}
