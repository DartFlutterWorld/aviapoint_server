import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/subscriptions/model/subscription_model.dart';
import 'package:aviapoint_server/subscriptions/model/subscription_type_model.dart';
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
  /// period_days берется из subscription_types, а не передается параметром
  Future<SubscriptionModel> createSubscription({
    required int userId,
    required String paymentId,
    required String subscriptionTypeCode, // Код типа подписки из БД (например, 'rosaviatest_365', 'monthly')
    required DateTime startDate,
    required int amount, // Цена подписки из платежа
  }) async {
    try {
      logger.info('Creating subscription: userId=$userId, paymentId=$paymentId, subscriptionTypeCode=$subscriptionTypeCode, amount=$amount');

      // Получаем ID типа подписки и period_days из БД
      final typeResult = await _connection.execute(
        Sql.named('SELECT id, code, name, period_days, price, is_active, created_at, description FROM subscription_types WHERE code = @code'),
        parameters: {'code': subscriptionTypeCode},
      );

      if (typeResult.isEmpty) {
        logger.severe('Subscription type not found in database: code=$subscriptionTypeCode');
        throw ArgumentError('Subscription type "$subscriptionTypeCode" not found in subscription_types table');
      }

      final typeRow = typeResult.first.toColumnMap();
      final subscriptionTypeId = _parseInt(typeRow['id']);
      final periodDays = _parseInt(typeRow['period_days']); // Берем period_days из subscription_types

      logger.info('Found subscription type ID: $subscriptionTypeId for code: $subscriptionTypeCode, period_days: $periodDays');

      // Определяем даты
      final start = startDate;
      final end = start.add(Duration(days: periodDays));

      logger.info('Subscription dates: start=$start, end=$end');

      // Создаем новую подписку (пользователь может иметь несколько активных подписок)
      logger.info('Inserting subscription into database with params: user_id=$userId, payment_id=$paymentId, subscription_type_id=$subscriptionTypeId, period_days=$periodDays, amount=$amount');

      final result = await _connection.execute(
        Sql.named('''
          INSERT INTO subscriptions (
            user_id, payment_id, subscription_type_id, period_days,
            start_date, end_date, is_active, amount
          ) VALUES (
            @user_id, @payment_id, @subscription_type_id, @period_days,
            @start_date, @end_date, @is_active, @amount
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
          'amount': amount,
        },
      );

      if (result.isEmpty) {
        logger.severe('INSERT returned no rows - subscription was not created');
        throw StateError('Failed to create subscription: INSERT returned no rows');
      }

      final row = result.first;
      final subscriptionId = _parseInt(row.toColumnMap()['id']);
      logger.info('✅ Subscription created successfully: id=$subscriptionId, user_id=$userId, payment_id=$paymentId, end_date=$end');

      return SubscriptionModel.fromJson(row.toColumnMap());
    } catch (e, stackTrace) {
      logger.severe('❌ Failed to create subscription: $e');
      logger.severe('Parameters: userId=$userId, paymentId=$paymentId, subscriptionTypeCode=$subscriptionTypeCode, amount=$amount');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Получение всех активных подписок пользователя
  Future<List<SubscriptionModel>> getActiveSubscription(int userId) async {
    try {
      final result = await _connection.execute(
        Sql.named('''
          SELECT * FROM subscriptions 
          WHERE user_id = @user_id 
            AND is_active = true
            AND end_date > CURRENT_TIMESTAMP
          ORDER BY end_date DESC
        '''),
        parameters: {'user_id': userId},
      );

      return result.map((row) => SubscriptionModel.fromJson(row.toColumnMap())).toList();
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

  /// Получение всех типов подписок
  Future<List<SubscriptionTypeModel>> getAllSubscriptionTypes() async {
    try {
      final result = await _connection.execute(
        Sql.named('''
          SELECT id, code, name, period_days, price, is_active, created_at, description 
          FROM subscription_types 
          WHERE is_active = true
          ORDER BY period_days ASC
        '''),
      );

      return result.map((row) => SubscriptionTypeModel.fromJson(row.toColumnMap())).toList();
    } catch (e, stackTrace) {
      logger.severe('Failed to get subscription types: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
