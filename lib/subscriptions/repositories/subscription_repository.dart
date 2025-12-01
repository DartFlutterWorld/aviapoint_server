import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/subscriptions/model/subscription_model.dart';
import 'package:aviapoint_server/subscriptions/model/subscription_type.dart';
import 'package:postgres/postgres.dart';

class SubscriptionRepository {
  final Connection _connection;

  SubscriptionRepository({required Connection connection}) : _connection = connection;

  /// Безопасное преобразование значения из БД в int
  int _parseInt(dynamic value) {
    if (value == null) {
      throw ArgumentError('Cannot convert null to int');
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
      throw ArgumentError('Cannot parse "$value" as int');
    }
    // Попытка преобразования через toString
    final stringValue = value.toString();
    final parsed = int.tryParse(stringValue);
    if (parsed != null) {
      return parsed;
    }
    throw ArgumentError('Cannot convert $value (${value.runtimeType}) to int');
  }

  /// Создание подписки
  Future<SubscriptionModel> createSubscription({
    required int userId,
    required String paymentId,
    required SubscriptionType subscriptionType,
    required int periodDays,
    DateTime? startDate,
    bool autoRenew = false,
  }) async {
    try {
      // Деактивируем предыдущие активные подписки пользователя
      await _connection.execute(
        Sql.named('''
          UPDATE subscriptions 
          SET is_active = false 
          WHERE user_id = @user_id AND is_active = true
        '''),
        parameters: {'user_id': userId},
      );

      // Получаем ID типа подписки
      final typeResult = await _connection.execute(
        Sql.named('SELECT id FROM subscription_types WHERE code = @code'),
        parameters: {'code': subscriptionType.code},
      );

      final subscriptionTypeId = typeResult.isNotEmpty ? _parseInt(typeResult.first.toColumnMap()['id']) : null;

      // Определяем даты
      final start = startDate ?? DateTime.now();
      final end = start.add(Duration(days: periodDays));

      // Создаем новую подписку
      final result = await _connection.execute(
        Sql.named('''
          INSERT INTO subscriptions (
            user_id, payment_id, subscription_type_id, period_days,
            start_date, end_date, is_active, auto_renew
          ) VALUES (
            @user_id, @payment_id, @subscription_type_id, @period_days,
            @start_date, @end_date, @is_active, @auto_renew
          )
          RETURNING *
        '''),
        parameters: {
          'user_id': userId,
          'payment_id': paymentId,
          'subscription_type_id': subscriptionTypeId,
          'period_days': periodDays,
          'start_date': start,
          'end_date': end,
          'is_active': true,
          'auto_renew': autoRenew,
        },
      );

      final row = result.first;
      logger.info('Subscription created: user_id=$userId, end_date=$end');

      return SubscriptionModel.fromJson(row.toColumnMap());
    } catch (e, stackTrace) {
      logger.severe('Failed to create subscription: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Получение активной подписки пользователя
  Future<SubscriptionModel?> getActiveSubscription(int userId) async {
    try {
      final result = await _connection.execute(
        Sql.named('''
          SELECT * FROM subscriptions 
          WHERE user_id = @user_id 
            AND is_active = true
            AND end_date > CURRENT_TIMESTAMP
          ORDER BY end_date DESC
          LIMIT 1
        '''),
        parameters: {'user_id': userId},
      );

      if (result.isEmpty) {
        return null;
      }

      return SubscriptionModel.fromJson(result.first.toColumnMap());
    } catch (e, stackTrace) {
      logger.severe('Failed to get active subscription: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Проверка наличия активной подписки
  Future<bool> hasActiveSubscription(int userId) async {
    try {
      final result = await _connection.execute(
        Sql.named('''
          SELECT COUNT(*) as count FROM subscriptions 
          WHERE user_id = @user_id 
            AND is_active = true
            AND end_date > CURRENT_TIMESTAMP
        '''),
        parameters: {'user_id': userId},
      );

      return _parseInt(result.first.toColumnMap()['count']) > 0;
    } catch (e, stackTrace) {
      logger.severe('Failed to check active subscription: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Получение всех подписок пользователя
  Future<List<SubscriptionModel>> getUserSubscriptions(int userId) async {
    try {
      final result = await _connection.execute(
        Sql.named('''
          SELECT * FROM subscriptions 
          WHERE user_id = @user_id 
          ORDER BY created_at DESC
        '''),
        parameters: {'user_id': userId},
      );

      return result.map((row) => SubscriptionModel.fromJson(row.toColumnMap())).toList();
    } catch (e, stackTrace) {
      logger.severe('Failed to get user subscriptions: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Деактивация подписки
  Future<void> deactivateSubscription(int subscriptionId) async {
    try {
      await _connection.execute(
        Sql.named('''
          UPDATE subscriptions 
          SET is_active = false 
          WHERE id = @id
        '''),
        parameters: {'id': subscriptionId},
      );

      logger.info('Subscription deactivated: $subscriptionId');
    } catch (e, stackTrace) {
      logger.severe('Failed to deactivate subscription: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Деактивация всех истекших подписок
  Future<int> deactivateExpiredSubscriptions() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT deactivate_expired_subscriptions() as count'),
      );

      final count = _parseInt(result.first.toColumnMap()['count']);
      if (count > 0) {
        logger.info('Deactivated $count expired subscriptions');
      }

      return count;
    } catch (e, stackTrace) {
      logger.severe('Failed to deactivate expired subscriptions: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
