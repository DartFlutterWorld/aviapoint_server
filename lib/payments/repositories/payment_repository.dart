import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/payments/model/payment_model.dart';
import 'package:aviapoint_server/payments/services/yookassa_service.dart';
import 'package:postgres/postgres.dart';

class PaymentRepository {
  final Connection _connection;
  final YooKassaService _yookassaService;

  PaymentRepository({
    required Connection connection,
    required YooKassaService yookassaService,
  })  : _connection = connection,
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
      final payment = await _yookassaService.createPayment(
        amount: amount,
        currency: currency,
        description: description,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
        customerPhone: customerPhone,
        subscriptionType: subscriptionType,
        periodDays: periodDays,
      );

      // НЕ сохраняем платеж в БД сразу - сохраним только после успешной оплаты через webhook
      // Это позволяет избежать накопления неоплаченных платежей в БД
      // Платеж будет сохранен автоматически в updatePaymentStatus при получении webhook

      logger.info('Payment created in YooKassa: ${payment.id}, user_id: $userId (will be saved after successful payment)');
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
      final dbResult = await _connection.execute(
        Sql.named('SELECT * FROM payments WHERE id = @id'),
        parameters: {'id': paymentId},
      );

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

  /// Получение полных данных платежа из БД (включая subscription_type и period_days)
  Future<Map<String, dynamic>?> getPaymentDataById(String paymentId) async {
    try {
      final dbResult = await _connection.execute(
        Sql.named('SELECT * FROM payments WHERE id = @id'),
        parameters: {'id': paymentId},
      );

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
  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
    required bool paid,
    Map<String, dynamic>? paymentObject,
  }) async {
    try {
      // Проверяем, существует ли платеж в БД
      final existingPayment = await _connection.execute(
        Sql.named('SELECT id FROM payments WHERE id = @id'),
        parameters: {'id': paymentId},
      );

      if (existingPayment.isEmpty) {
        // Если платежа нет в БД, получаем полную информацию из ЮKassa и сохраняем
        // Это происходит при получении webhook - сохраняем только после того, как платеж обработан
        final payment = await _yookassaService.getPayment(paymentId);

        // Получаем subscription_type и period_days из metadata платежа
        String? subscriptionType;
        int? periodDays;

        // Пытаемся получить из metadata (сохранены при создании платежа)
        if (paymentObject != null) {
          final metadata = paymentObject['metadata'] as Map<String, dynamic>?;
          if (metadata != null) {
            subscriptionType = metadata['subscription_type'] as String?;
            final periodDaysStr = metadata['period_days'];
            if (periodDaysStr != null) {
              periodDays = periodDaysStr is int ? periodDaysStr : int.tryParse(periodDaysStr.toString());
            }
          }
        }

        await _connection.execute(
          Sql.named('''
            INSERT INTO payments (
              id, status, amount, currency, description, 
              payment_url, created_at, paid, subscription_type, period_days
            ) VALUES (
              @id, @status, @amount, @currency, @description,
              @payment_url, @created_at, @paid, @subscription_type, @period_days
            )
          '''),
          parameters: {
            'id': payment.id,
            'status': payment.status,
            'amount': payment.amount,
            'currency': payment.currency,
            'description': payment.description,
            'payment_url': payment.paymentUrl,
            'created_at': payment.createdAt,
            'paid': payment.paid,
            'subscription_type': subscriptionType,
            'period_days': periodDays,
          },
        );
        logger.info('Payment saved to database from webhook: $paymentId -> $status (paid: $paid)');
      } else {
        // Обновляем существующий платеж
        await _connection.execute(
          Sql.named('''
            UPDATE payments 
            SET status = @status, paid = @paid, updated_at = CURRENT_TIMESTAMP
            WHERE id = @id
          '''),
          parameters: {
            'id': paymentId,
            'status': status,
            'paid': paid,
          },
        );
        logger.info('Payment status updated: $paymentId -> $status');
      }
    } catch (e, stackTrace) {
      logger.severe('Failed to update payment status: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
