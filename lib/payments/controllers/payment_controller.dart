import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/payments/api/create_payment_request.dart';
import 'package:aviapoint_server/payments/repositories/payment_repository.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:aviapoint_server/push_notifications/fcm_service.dart';
import 'package:aviapoint_server/subscriptions/repositories/subscription_repository.dart';
import 'package:aviapoint_server/telegram/telegram_bot_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'payment_controller.g.dart';

class PaymentController {
  final PaymentRepository _paymentRepository;
  final SubscriptionRepository _subscriptionRepository;

  PaymentController({required PaymentRepository paymentRepository, required SubscriptionRepository subscriptionRepository})
      : _paymentRepository = paymentRepository,
        _subscriptionRepository = subscriptionRepository;

  Router get router => _$PaymentControllerRouter(this);

  ///
  /// Создание платежа
  ///
  /// Создает платеж в ЮKassa и возвращает paymentUrl
  ///
  @Route.post('/api/payments/create')
  @OpenApiRoute()
  Future<Response> createPayment(Request request) async {
    return wrapResponse(() async {
      final body = await request.readAsString();

      // Логируем входящее тело для отладки
      logger.info('Received payment request body: $body');

      // Парсим JSON
      Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        logger.severe('Failed to parse JSON: $e');
        logger.severe('Body content: $body');
        return Response.badRequest(body: jsonEncode({'error': 'Invalid JSON format', 'message': 'Request body must be valid JSON', 'details': e.toString()}), headers: jsonContentHeaders);
      }

      // Создаем объект запроса
      CreatePaymentRequest createPaymentRequest;
      try {
        createPaymentRequest = CreatePaymentRequest.fromJson(jsonData);
      } catch (e) {
        logger.severe('Failed to create CreatePaymentRequest: $e');
        logger.severe('JSON data: $jsonData');
        return Response.badRequest(body: jsonEncode({'error': 'Invalid request data', 'message': 'Failed to parse payment request', 'details': e.toString()}), headers: jsonContentHeaders);
      }

      logger.info(
        'Creating payment: amount=${createPaymentRequest.amount}, '
        'currency=${createPaymentRequest.currency}, '
        'userId=${createPaymentRequest.userId}',
      );

      // Получаем телефон пользователя из профиля, если userId передан и телефон не указан в запросе
      String? customerPhone = createPaymentRequest.customerPhone;
      if (customerPhone == null && createPaymentRequest.userId != null) {
        try {
          final profile = await getIt.get<ProfileRepository>().fetchProfileById(createPaymentRequest.userId!);
          customerPhone = profile.phone;
          logger.info('Using phone from user profile: $customerPhone');
        } catch (e) {
          logger.severe('Failed to fetch user profile for phone: $e');
          // Продолжаем с дефолтным телефоном
        }
      }

      // Получаем period_days из subscription_type_id, если передан ID
      int? periodDays = createPaymentRequest.periodDays;
      int? subscriptionTypeId = createPaymentRequest.subscriptionTypeId;

      if (subscriptionTypeId != null && periodDays == null) {
        try {
          final subscriptionTypes = await _subscriptionRepository.getAllSubscriptionTypes();
          final subscriptionTypeModel = subscriptionTypes.firstWhere(
            (type) => type.id == subscriptionTypeId,
            orElse: () => throw StateError('Subscription type with id $subscriptionTypeId not found'),
          );
          periodDays = subscriptionTypeModel.periodDays;
          logger.info('Got period_days=$periodDays from subscription_type_id=$subscriptionTypeId');
        } catch (e) {
          logger.severe('Failed to get subscription type by ID: $e');
          // Продолжаем без period_days
        }
      }

      final payment = await _paymentRepository.createPayment(
        amount: createPaymentRequest.amount,
        currency: createPaymentRequest.currency,
        description: createPaymentRequest.description,
        returnUrl: createPaymentRequest.returnUrl,
        cancelUrl: createPaymentRequest.cancelUrl,
        userId: createPaymentRequest.userId,
        customerPhone: customerPhone,
        subscriptionTypeId: subscriptionTypeId,
        periodDays: periodDays,
      );

      return Response.ok(
        jsonEncode({
          'id': payment.id,
          'status': payment.status,
          'amount': payment.amount,
          'currency': payment.currency,
          'description': payment.description,
          'payment_url': payment.paymentUrl,
          'created_at': payment.createdAt.toIso8601String(),
          'paid': payment.paid,
        }),
        headers: jsonContentHeaders,
      );
    });
  }

  ///
  /// Получение статуса платежа
  ///
  /// Проверяет статус платежа по ID
  ///
  @Route.get('/api/payments/<paymentId>/status')
  @OpenApiRoute()
  Future<Response> getPaymentStatus(Request request) async {
    return wrapResponse(() async {
      final paymentId = request.params['paymentId']!;
      logger.info('Getting payment status: $paymentId');

      final payment = await _paymentRepository.getPaymentById(paymentId);

      if (payment == null) {
        return Response.notFound(jsonEncode({'error': 'Payment not found'}), headers: jsonContentHeaders);
      }

      // Если платеж успешен, но подписка еще не активирована (для тестового режима, где webhook может не прийти)
      if (payment.status == 'succeeded' && payment.paid && payment.userId > 0) {
        try {
          logger.info('Payment succeeded, checking subscription activation: paymentId=$paymentId, userId=${payment.userId}');

          // Проверяем, есть ли уже активная подписка для этого платежа
          final paymentData = await _paymentRepository.getPaymentDataById(paymentId);
          logger.info('Payment data from DB: ${paymentData?.keys.toList()}');

          if (paymentData != null) {
            final userId = paymentData['user_id'] as int?;
            final subscriptionTypeIdValue = paymentData['subscription_type_id'];
            int? subscriptionTypeId;
            if (subscriptionTypeIdValue != null) {
              subscriptionTypeId = subscriptionTypeIdValue is int ? subscriptionTypeIdValue : (int.tryParse(subscriptionTypeIdValue.toString()));
            }

            logger.info('Payment data: userId=$userId, subscriptionTypeId=$subscriptionTypeId');

            if (userId != null && userId > 0 && subscriptionTypeId != null) {
              // Проверяем, есть ли уже подписка для этого платежа
              final subscriptions = await _subscriptionRepository.getUserSubscriptions(userId);
              final hasSubscriptionForPayment = subscriptions.any((s) => s.paymentId == paymentId);

              logger.info('Subscriptions for user $userId: ${subscriptions.length}, hasSubscriptionForPayment=$hasSubscriptionForPayment');

              if (!hasSubscriptionForPayment) {
                logger.info('Payment succeeded but subscription not activated, activating now: paymentId=$paymentId, userId=$userId, subscriptionTypeId=$subscriptionTypeId');

                dynamic amountValue = paymentData['amount'];
                int subscriptionAmount = 0;
                if (amountValue != null) {
                  if (amountValue is int) {
                    subscriptionAmount = amountValue;
                  } else if (amountValue is num) {
                    subscriptionAmount = amountValue.toInt();
                  } else if (amountValue is String) {
                    final doubleValue = double.tryParse(amountValue);
                    subscriptionAmount = doubleValue?.toInt() ?? 0;
                  }
                }

                logger.info('Creating subscription: userId=$userId, paymentId=$paymentId, subscriptionTypeId=$subscriptionTypeId, amount=$subscriptionAmount');

                await _subscriptionRepository.createSubscription(
                  userId: userId,
                  paymentId: paymentId,
                  subscriptionTypeId: subscriptionTypeId,
                  startDate: DateTime.now(),
                  amount: subscriptionAmount,
                );

                logger.info('✅ Subscription activated for user $userId, payment: $paymentId, subscriptionTypeId: $subscriptionTypeId');
              } else {
                logger.info('Subscription already exists for payment $paymentId');
              }
            } else {
              logger.severe('Cannot activate subscription: userId is null or 0: userId=$userId');
            }
          } else {
            logger.severe('Payment data not found in DB for paymentId: $paymentId');
          }
        } catch (e, stackTrace) {
          logger.severe('❌ Failed to activate subscription after status check: $e');
          logger.severe('Stack trace: $stackTrace');
          // Не прерываем выполнение - возвращаем статус платежа
        }
      }

      return Response.ok(
        jsonEncode({
          'id': payment.id,
          'status': payment.status,
          'amount': payment.amount,
          'currency': payment.currency,
          'description': payment.description,
          'paid': payment.paid,
          'created_at': payment.createdAt.toIso8601String(),
        }),
        headers: jsonContentHeaders,
      );
    });
  }

  ///
  /// Обработка возврата после успешной оплаты
  ///
  /// ЮKassa редиректит пользователя на этот URL после успешной оплаты
  ///
  @Route.get('/api/payments/return')
  Future<Response> paymentReturn(Request request) async {
    return wrapResponse(() async {
      final paymentId = request.url.queryParameters['payment_id'];
      logger.info('Payment return: payment_id=$paymentId');

      // ВАЖНО: Согласно документации ЮKassa, return_url используется для возврата
      // пользователя как при успешной оплате, так и при отмене/ошибке.
      // Статус платежа нужно проверять через API или webhook, а не полагаться на URL.
      // Здесь мы всегда показываем success, так как точный статус будет обработан через webhook.
      // Фронтенд должен проверить статус платежа через API после возврата.
      const paymentStatus = 'success';

      // Редиректим на страницу выбора режима тестирования
      // Всегда показываем сообщение об успешной оплате, так как пользователь вернулся с /payments/return
      // Используем HTML страницу с автоматическим редиректом для более надежной работы
      // Используем path-based routing (без хеша), так как фронтенд использует setPathUrlStrategy()
      final frontendUrl = Platform.environment['FRONTEND_URL'] ?? 'https://avia-point.com';
      final paymentIdParam = paymentId != null && paymentId.isNotEmpty ? '&payment_id=$paymentId' : '';
      final redirectUrl = '$frontendUrl/learning/testing_mode?payment=$paymentStatus$paymentIdParam';

      // Возвращаем HTML страницу с автоматическим редиректом
      // Это работает надежнее, чем простой HTTP редирект, особенно после перехода с ЮKassa
      final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Перенаправление...</title>
  <meta http-equiv="refresh" content="0;url=$redirectUrl">
  <script>
    // Автоматический редирект через JavaScript (более надежно)
    window.location.href = '$redirectUrl';
    
    // Fallback: если через 1 секунду все еще на этой странице, пробуем еще раз
    setTimeout(function() {
      if (window.location.href.includes('/payments/return')) {
        window.location.href = '$redirectUrl';
      }
    }, 1000);
  </script>
</head>
<body>
  <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
    <h1>Перенаправление...</h1>
    <p>Если перенаправление не произошло автоматически, <a href="$redirectUrl">нажмите здесь</a></p>
  </div>
</body>
</html>
''';

      return Response.ok(html, headers: {'Content-Type': 'text/html; charset=utf-8'});
    });
  }

  ///
  /// Обработка отмены платежа
  ///
  /// ЮKassa редиректит пользователя на этот URL при отмене платежа
  ///
  @Route.get('/api/payments/cancel')
  Future<Response> paymentCancel(Request request) async {
    return wrapResponse(() async {
      final paymentId = request.url.queryParameters['payment_id'];
      logger.info('Payment cancel: payment_id=$paymentId');

      // Редиректим на страницу выбора режима тестирования после отмены платежа
      // Используем HTTP редирект (302 Found) - это более надежно, чем JavaScript
      // Используем path-based routing (без хеша), так как фронтенд использует setPathUrlStrategy()
      final frontendUrl = Platform.environment['FRONTEND_URL'] ?? 'https://avia-point.com';
      final redirectUrl = '$frontendUrl/learning/testing_mode?payment=cancel${paymentId != null ? '&payment_id=$paymentId' : ''}';

      // HTTP редирект 302 Found - работает везде (веб, мобильные)
      return Response.found(redirectUrl);
    });
  }

  ///
  /// Webhook от ЮKassa
  ///
  /// Получает уведомления о статусе платежа от ЮKassa
  ///
  @Route.post('/api/payments/webhook')
  @OpenApiRoute()
  Future<Response> webhook(Request request) async {
    return wrapResponse(() async {
      final body = await request.readAsString();

      // Проверяем, что тело запроса не пустое
      if (body.isEmpty || body.trim().isEmpty) {
        logger.info('Received empty webhook body, ignoring');
        return Response.ok(jsonEncode({'status': 'ok', 'message': 'Empty body ignored'}), headers: jsonContentHeaders);
      }

      Map<String, dynamic> json;
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        logger.severe('Failed to parse webhook JSON: $e');
        logger.severe('Body content: $body');
        return Response.badRequest(body: jsonEncode({'error': 'Invalid JSON format', 'details': e.toString()}), headers: jsonContentHeaders);
      }

      final event = json['event'] as String?;
      logger.info('Received webhook from YooKassa: $event');

      // Обрабатываем события о платежах
      if (event == 'payment.succeeded' || event == 'payment.canceled' || event == 'payment.waiting_for_capture') {
        final paymentObject = json['object'] as Map<String, dynamic>?;
        if (paymentObject == null) {
          logger.severe('Payment object is null in webhook');
          return Response.badRequest(body: jsonEncode({'error': 'Payment object is missing'}), headers: jsonContentHeaders);
        }

        final paymentId = paymentObject['id'] as String?;
        final status = paymentObject['status'] as String?;
        final paid = paymentObject['paid'] as bool?;

        if (paymentId == null || status == null || paid == null) {
          logger.severe('Missing required fields in payment object: id=$paymentId, status=$status, paid=$paid');
          return Response.badRequest(body: jsonEncode({'error': 'Missing required payment fields'}), headers: jsonContentHeaders);
        }

        logger.info('Updating payment status: $paymentId -> $status (paid: $paid)');
        logger.info('Full payment object: $paymentObject');

        try {
          await _paymentRepository.updatePaymentStatus(paymentId: paymentId, status: status, paid: paid, paymentObject: paymentObject);
          logger.info('Payment status updated successfully: $paymentId');
        } catch (e, stackTrace) {
          logger.severe('Failed to update payment status in webhook: $e');
          logger.severe('Stack trace: $stackTrace');
          // Логируем ошибку, но продолжаем обработку для создания подписки
          // Если платеж не сохранился, попробуем создать подписку из данных webhook
        }

        // Если платеж успешен, активируем подписку
        if (event == 'payment.succeeded' && paid) {
          try {
            // Получаем информацию о платеже из БД (включая subscription_type_id и period_days)
            Map<String, dynamic>? paymentRow = await _paymentRepository.getPaymentDataById(paymentId);

            // Если платеж не найден в БД, но у нас есть paymentObject, используем его
            if (paymentRow == null) {
              logger.severe('Payment not found in database: $paymentId, but paymentObject exists, using it');
              // Создаем временный объект из paymentObject для дальнейшей обработки
              final metadata = paymentObject['metadata'] as Map<String, dynamic>?;
              final amountObj = paymentObject['amount'] as Map<String, dynamic>?;

              final subscriptionTypeIdFromMetadata = metadata?['subscription_type_id'];
              paymentRow = {
                'user_id': metadata?['user_id'],
                'subscription_type_id': subscriptionTypeIdFromMetadata,
                'period_days': metadata?['period_days'],
                'amount': amountObj?['value'],
                'description': paymentObject['description']?.toString() ?? '',
              };
            }
            final userId = paymentRow['user_id'] as int?;
            final subscriptionTypeIdValue = paymentRow['subscription_type_id'];
            int? subscriptionTypeId;
            if (subscriptionTypeIdValue != null) {
              subscriptionTypeId = subscriptionTypeIdValue is int ? subscriptionTypeIdValue : (int.tryParse(subscriptionTypeIdValue.toString()) ?? 0);
            }
            final periodDaysValue = paymentRow['period_days'];

            logger.info('Payment data extracted: userId=$userId, subscriptionTypeId=$subscriptionTypeId, periodDays=$periodDaysValue');

            // Пытаемся получить amount из webhook объекта (более надежно), если нет - из БД
            dynamic amountValue = paymentRow['amount'];
            final amountObj = paymentObject['amount'] as Map<String, dynamic>?;
            if (amountObj != null && amountObj['value'] != null) {
              // В webhook amount приходит как {"value": "700.00", "currency": "RUB"}
              amountValue = amountObj['value'];
              logger.info('Extracted amount from webhook object: $amountValue');
            } else {
              logger.info('Amount not found in webhook object, using from DB: $amountValue');
            }

            if (userId == null) {
              logger.severe('Payment has no user_id: $paymentId');
              return Response.ok(jsonEncode({'status': 'ok', 'message': 'Payment has no user_id'}), headers: jsonContentHeaders);
            }

            // Парсим amount из платежа (amount в payments - это numeric(10,2), нужно конвертировать в int для subscriptions)
            int subscriptionAmount = 0;
            if (amountValue != null) {
              if (amountValue is int) {
                subscriptionAmount = amountValue;
              } else if (amountValue is num) {
                subscriptionAmount = amountValue.toInt();
              } else if (amountValue is double) {
                subscriptionAmount = amountValue.toInt();
              } else if (amountValue is String) {
                // Если строка, сначала парсим как double, потом в int (для "1000.00" -> 1000)
                final doubleValue = double.tryParse(amountValue);
                subscriptionAmount = doubleValue?.toInt() ?? 0;
              }
            }

            logger.info('Parsed subscription amount from payment: $amountValue -> $subscriptionAmount');

            // Используем subscription_type_id напрямую
            if (subscriptionTypeId == null || subscriptionTypeId == 0) {
              logger.severe('Subscription type ID not found in payment: $paymentId');
              return Response.ok(jsonEncode({'status': 'ok', 'message': 'Subscription type ID not found'}), headers: jsonContentHeaders);
            }

            logger.info('Creating subscription with subscription_type_id=$subscriptionTypeId (period_days will be taken from subscription_types)');

            // Получаем информацию о типе подписки для уведомлений
            int periodDaysForNotification = 365; // Дефолт
            String subscriptionTypeCode = 'unknown'; // Дефолт
            try {
              final subscriptionTypes = await _subscriptionRepository.getAllSubscriptionTypes();
              final subscriptionType = subscriptionTypes.firstWhere(
                (type) => type.id == subscriptionTypeId,
                orElse: () => subscriptionTypes.isNotEmpty ? subscriptionTypes.first : throw StateError('No subscription types found'),
              );
              periodDaysForNotification = subscriptionType.periodDays;
              subscriptionTypeCode = subscriptionType.code;
              logger.info('Found subscription type: code=$subscriptionTypeCode, period_days=$periodDaysForNotification');
            } catch (e) {
              logger.info('Failed to get subscription type from subscription_types for notification: $e');
            }

            // Активируем подписку
            // period_days будет автоматически взят из subscription_types
            await _subscriptionRepository.createSubscription(
              userId: userId,
              paymentId: paymentId,
              subscriptionTypeId: subscriptionTypeId,
              startDate: DateTime.now(),
              amount: subscriptionAmount,
            );

            logger.info('Subscription activated for user $userId, payment: $paymentId, subscriptionTypeId: $subscriptionTypeId');

            // Отправляем уведомление в Telegram о покупке подписки
            try {
              final profileRepository = await getIt.getAsync<ProfileRepository>();
              final profile = await profileRepository.fetchProfileById(userId);
              TelegramBotService().notifySubscriptionPurchase(
                userId: userId,
                phone: profile.phone,
                subscriptionType: subscriptionTypeCode,
                periodDays: periodDaysForNotification,
                amount: subscriptionAmount.toDouble(),
                paymentId: paymentId,
                firstName: profile.firstName,
                lastName: profile.lastName,
              );
            } catch (e) {
              logger.info('Failed to send Telegram notification for subscription: $e');
              // Не прерываем обработку, если уведомление не отправилось
            }

            // Отправляем push-уведомление администраторам о покупке подписки
            try {
              final profileRepository = await getIt.getAsync<ProfileRepository>();
              final profile = await profileRepository.fetchProfileById(userId);
              final adminFcmTokens = await profileRepository.getAdminFcmTokens();

              if (adminFcmTokens.isNotEmpty) {
                final fcmService = FcmService();
                final userName = profile.firstName != null && profile.lastName != null ? '${profile.firstName} ${profile.lastName}'.trim() : profile.firstName ?? profile.lastName;

                final sentCount = await fcmService.notifyAdminsAboutSubscriptionPurchase(
                  adminFcmTokens: adminFcmTokens,
                  userPhone: profile.phone,
                  userName: userName,
                  subscriptionType: subscriptionTypeCode,
                  amount: subscriptionAmount,
                );

                logger.info('✅ Отправлено push-уведомлений администраторам о покупке подписки: $sentCount из ${adminFcmTokens.length}');
              } else {
                logger.info('⚠️ Не найдено FCM токенов администраторов для отправки уведомления о покупке подписки');
              }
            } catch (e, stackTrace) {
              logger.severe('❌ Ошибка отправки push-уведомления администраторам о покупке подписки: $e');
              logger.severe('Stack trace: $stackTrace');
              // Не прерываем обработку, если уведомление не отправилось
            }
          } catch (e, stackTrace) {
            logger.severe('❌ CRITICAL: Failed to activate subscription after payment: $e');

            logger.severe('Stack trace: $stackTrace');
            // НЕ прерываем обработку webhook, чтобы ЮKassa не повторял запрос
            // Но логируем критическую ошибку для дальнейшего разбора
          }
        }
      } else if (event == 'refund.succeeded') {
        // Обрабатываем возврат средств
        final refundObject = json['object'] as Map<String, dynamic>;
        final paymentId = refundObject['payment_id'] as String;
        final refundId = refundObject['id'] as String;
        final status = refundObject['status'] as String;

        logger.info('Refund processed: $refundId for payment $paymentId, status: $status');

        // Можно добавить логику для обработки возвратов
        // Например, обновить статус платежа или создать запись о возврате
      } else {
        logger.info('Unhandled webhook event: $event');
      }

      // Всегда возвращаем 200 OK, чтобы ЮKassa не повторял запрос
      return Response.ok(jsonEncode({'status': 'ok'}), headers: jsonContentHeaders);
    });
  }

}
