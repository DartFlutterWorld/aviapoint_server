import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/payments/api/create_payment_request.dart';
import 'package:aviapoint_server/payments/repositories/payment_repository.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:aviapoint_server/subscriptions/repositories/subscription_repository.dart';
import 'package:aviapoint_server/subscriptions/model/subscription_type.dart';
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
  @Route.post('/payments/create')
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

      final payment = await _paymentRepository.createPayment(
        amount: createPaymentRequest.amount,
        currency: createPaymentRequest.currency,
        description: createPaymentRequest.description,
        returnUrl: createPaymentRequest.returnUrl,
        cancelUrl: createPaymentRequest.cancelUrl,
        userId: createPaymentRequest.userId,
        customerPhone: customerPhone,
        subscriptionType: createPaymentRequest.subscriptionType,
        periodDays: createPaymentRequest.periodDays,
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
  @Route.get('/payments/<paymentId>/status')
  @OpenApiRoute()
  Future<Response> getPaymentStatus(Request request) async {
    return wrapResponse(() async {
      final paymentId = request.params['paymentId']!;
      logger.info('Getting payment status: $paymentId');

      final payment = await _paymentRepository.getPaymentById(paymentId);

      if (payment == null) {
        return Response.notFound(jsonEncode({'error': 'Payment not found'}), headers: jsonContentHeaders);
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
  @Route.get('/payments/return')
  Future<Response> paymentReturn(Request request) async {
    return wrapResponse(() async {
      final paymentId = request.url.queryParameters['payment_id'];
      logger.info('Payment return: payment_id=$paymentId');

      // Редиректим на фронтенд (профиль) с параметром успешной оплаты
      // Для веб используем фронтенд URL, для мобильных - deep link
      final frontendUrl = Platform.environment['FRONTEND_URL'] ?? 'https://avia-point.com';
      final redirectUrl = '$frontendUrl/#/profile?payment=success${paymentId != null ? '&payment_id=$paymentId' : ''}';

      // Возвращаем HTML страницу с автоматическим редиректом
      // Это работает и для веб, и для мобильных (WebView)
      final html =
          '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Оплата успешна</title>
  <script>
    // Пытаемся закрыть окно/вкладку (для веб)
    window.onload = function() {
      // Редирект на фронтенд
      window.location.href = '$redirectUrl';
      
      // Для мобильных приложений (WebView) можно использовать deep link
      // Если это не сработает, WebView сам обработает URL через NavigationDelegate
      setTimeout(function() {
        // Если через 2 секунды все еще на этой странице, пробуем закрыть
        if (window.location.href.includes('/payments/return')) {
          // Пытаемся закрыть окно (работает только если было открыто через window.open)
          window.close();
        }
      }, 2000);
    };
  </script>
</head>
<body>
  <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
    <h1>Оплата успешно выполнена!</h1>
    <p>Перенаправление...</p>
    <p><a href="$redirectUrl">Нажмите здесь, если перенаправление не произошло автоматически</a></p>
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
  @Route.get('/payments/cancel')
  Future<Response> paymentCancel(Request request) async {
    return wrapResponse(() async {
      final paymentId = request.url.queryParameters['payment_id'];
      logger.info('Payment cancel: payment_id=$paymentId');

      // Редиректим на фронтенд (профиль) с параметром отмены
      final frontendUrl = Platform.environment['FRONTEND_URL'] ?? 'https://avia-point.com';
      final redirectUrl = '$frontendUrl/#/profile?payment=cancel${paymentId != null ? '&payment_id=$paymentId' : ''}';

      // Возвращаем HTML страницу с автоматическим редиректом
      final html =
          '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Оплата отменена</title>
  <script>
    window.onload = function() {
      // Редирект на фронтенд
      window.location.href = '$redirectUrl';
      
      // Для мобильных приложений (WebView)
      setTimeout(function() {
        if (window.location.href.includes('/payments/cancel')) {
          window.close();
        }
      }, 2000);
    };
  </script>
</head>
<body>
  <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
    <h1>Оплата отменена</h1>
    <p>Перенаправление...</p>
    <p><a href="$redirectUrl">Нажмите здесь, если перенаправление не произошло автоматически</a></p>
  </div>
</body>
</html>
''';

      return Response.ok(html, headers: {'Content-Type': 'text/html; charset=utf-8'});
    });
  }

  ///
  /// Webhook от ЮKassa
  ///
  /// Получает уведомления о статусе платежа от ЮKassa
  ///
  @Route.post('/payments/webhook')
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
          // Не прерываем обработку, возвращаем 200, чтобы ЮKassa не повторял запрос
          return Response.ok(jsonEncode({'status': 'error', 'message': 'Failed to update payment', 'error': e.toString()}), headers: jsonContentHeaders);
        }

        // Если платеж успешен, активируем подписку
        if (event == 'payment.succeeded' && paid) {
          try {
            // Получаем информацию о платеже из БД (включая subscription_type и period_days)
            final paymentRow = await _paymentRepository.getPaymentDataById(paymentId);

            if (paymentRow == null) {
              logger.severe('Payment not found in database: $paymentId');
              return Response.ok(jsonEncode({'status': 'ok', 'message': 'Payment not found'}), headers: jsonContentHeaders);
            }
            final userId = paymentRow['user_id'] as int?;
            final subscriptionTypeStr = paymentRow['subscription_type'] as String?;
            final periodDaysValue = paymentRow['period_days'];

            // Пытаемся получить amount из webhook объекта (более надежно), если нет - из БД
            dynamic amountValue = paymentRow['amount'];
            if (paymentObject != null) {
              final amountObj = paymentObject['amount'] as Map<String, dynamic>?;
              if (amountObj != null && amountObj['value'] != null) {
                // В webhook amount приходит как {"value": "700.00", "currency": "RUB"}
                amountValue = amountObj['value'];
                logger.info('Extracted amount from webhook object: $amountValue');
              } else {
                logger.info('Amount not found in webhook object, using from DB: $amountValue');
              }
            } else {
              logger.info('Payment object is null, using amount from DB: $amountValue');
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

            // Определяем тип подписки и период
            SubscriptionType subscriptionType = SubscriptionType.monthly;
            int periodDays = 30;

            if (subscriptionTypeStr != null && periodDaysValue != null) {
              // Используем сохраненные данные из БД
              switch (subscriptionTypeStr.toLowerCase()) {
                case 'monthly':
                  subscriptionType = SubscriptionType.monthly;
                  break;
                case 'quarterly':
                  subscriptionType = SubscriptionType.quarterly;
                  break;
                case 'yearly':
                  subscriptionType = SubscriptionType.yearly;
                  break;
                default:
                  subscriptionType = SubscriptionType.monthly;
              }

              // Парсим periodDays
              if (periodDaysValue is int) {
                periodDays = periodDaysValue;
              } else if (periodDaysValue is num) {
                periodDays = periodDaysValue.toInt();
              } else if (periodDaysValue is String) {
                periodDays = int.tryParse(periodDaysValue) ?? 30;
              }
            } else {
              // Fallback: определяем из описания, если данные не сохранены
              logger.severe('Subscription type/period not found in payment, using description fallback');
              final description = (paymentRow['description'] as String? ?? '').toLowerCase();

              if (description.contains('месяц') || description.contains('monthly')) {
                subscriptionType = SubscriptionType.monthly;
                periodDays = 30;
              } else if (description.contains('квартал') || description.contains('quarterly')) {
                subscriptionType = SubscriptionType.quarterly;
                periodDays = 90;
              } else if (description.contains('год') || description.contains('yearly') || description.contains('годов')) {
                subscriptionType = SubscriptionType.yearly;
                periodDays = 365;
              }
            }

            // Активируем подписку
            await _subscriptionRepository.createSubscription(
              userId: userId,
              paymentId: paymentId,
              subscriptionType: subscriptionType,
              periodDays: periodDays,
              startDate: DateTime.now(),
              amount: subscriptionAmount,
            );

            logger.info('Subscription activated for user $userId, payment: $paymentId, type: ${subscriptionType.code}, days: $periodDays');
          } catch (e, stackTrace) {
            logger.severe('Failed to activate subscription after payment: $e');
            logger.severe('Stack trace: $stackTrace');
            // Не прерываем обработку webhook, даже если активация подписки не удалась
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
