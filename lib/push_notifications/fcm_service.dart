import 'dart:convert';
import 'dart:io';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/push_notifications/push_notification_texts.dart';
import 'package:http/http.dart' as http;

/// Сервис для отправки push-уведомлений через Firebase Cloud Messaging
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  String? _serverKey;

  /// Инициализация сервиса
  void init({String? serverKey}) {
    _serverKey = serverKey ?? (Platform.environment['FCM_SERVER_KEY'] ?? '');

    if (_serverKey == null || _serverKey!.isEmpty) {
      logger.info('⚠️ FCM_SERVER_KEY не установлен. Push-уведомления отключены.');
    }
  }

  /// Отправка push-уведомления одному пользователю (по токену)
  Future<bool> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (_serverKey == null || _serverKey!.isEmpty) {
      logger.info('FCM не настроен, пропускаем отправку push-уведомления');
      return false;
    }

    if (fcmToken.isEmpty) {
      logger.info('FCM токен пустой, пропускаем отправку');
      return false;
    }

    try {
      // Используем legacy FCM API (более простой, не требует OAuth)
      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

      final message = {
        'to': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
        if (data != null) 'data': data.map((key, value) => MapEntry(key, value.toString())),
        'priority': 'high',
        'android': {
          'priority': 'high',
        },
        'apns': {
          'headers': {
            'apns-priority': '10',
          },
          'payload': {
            'aps': {
              'alert': {
                'title': title,
                'body': body,
              },
              'sound': 'default',
              'badge': 1,
            },
          },
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'key=$_serverKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(message),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        logger.info('✅ Push-уведомление отправлено успешно');
        return true;
      } else {
        logger.info('⚠️ Ошибка отправки push-уведомления: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      logger.severe('❌ Ошибка при отправке push-уведомления: $e');
      logger.severe('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Отправка уведомления пилоту о необходимости завершить полёт
  Future<bool> notifyPilotToCompleteFlight({
    required String fcmToken,
    required String departureAirport,
    required String arrivalAirport,
    required DateTime departureDate,
    required int flightId,
    required int hoursSinceDeparture,
  }) async {
    final title = PushNotificationTexts.flightReminderTitle;
    final body = PushNotificationTexts.flightReminderBody(departureAirport, arrivalAirport, hoursSinceDeparture);

    final data = {
      'type': 'flight_reminder',
      'flight_id': flightId.toString(),
      'departure_airport': departureAirport,
      'arrival_airport': arrivalAirport,
    };

    return await sendNotification(
      fcmToken: fcmToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Отправка уведомления владельцу полёта о новом бронировании
  Future<bool> notifyPilotAboutNewBooking({
    required String fcmToken,
    required String waypointsText,
    required String formattedDate,
    required int flightId,
  }) async {
    final title = PushNotificationTexts.newBookingTitle;
    final body = PushNotificationTexts.newBookingBody(waypointsText, formattedDate);

    final data = {
      'type': 'new_booking',
      'flight_id': flightId.toString(),
      'screen': 'flight_detail', // Экран для перехода
    };

    return await sendNotification(
      fcmToken: fcmToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Отправка уведомления пассажиру о подтверждении бронирования
  Future<bool> notifyPassengerAboutConfirmedBooking({
    required String fcmToken,
    required String waypointsText,
    required String formattedDate,
    required int flightId,
  }) async {
    final title = PushNotificationTexts.bookingConfirmedTitle;
    final body = PushNotificationTexts.bookingConfirmedBody(waypointsText, formattedDate);

    final data = {
      'type': 'booking_confirmed',
      'flight_id': flightId.toString(),
      'screen': 'flight_detail', // Экран для перехода
    };

    return await sendNotification(
      fcmToken: fcmToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Отправка уведомления пассажиру об отмене бронирования
  Future<bool> notifyPassengerAboutCancelledBooking({
    required String fcmToken,
    required String waypointsText,
    required String formattedDate,
    required int flightId,
  }) async {
    final title = PushNotificationTexts.bookingCancelledTitle;
    final body = PushNotificationTexts.bookingCancelledBody(waypointsText, formattedDate);

    final data = {
      'type': 'booking_cancelled',
      'flight_id': flightId.toString(),
      'screen': 'flight_detail', // Экран для перехода
    };

    return await sendNotification(
      fcmToken: fcmToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Отправка уведомления владельцу объявления о снятии с публикации
  Future<bool> notifyOwnerAboutUnpublishedListing({
    required String fcmToken,
    required String listingTitle,
    required int listingId,
  }) async {
    final title = PushNotificationTexts.listingUnpublishedTitle;
    final body = PushNotificationTexts.listingUnpublishedBody(listingTitle);

    final data = {
      'type': 'listing_unpublished',
      'listing_id': listingId.toString(),
      'screen': 'listing_detail', // Экран для перехода
    };

    return await sendNotification(
      fcmToken: fcmToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Отправка push-уведомления на все токены пользователя
  /// Отправляет уведомление на все активные устройства пользователя (веб и мобильные)
  Future<int> sendNotificationToAllUserTokens({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (fcmTokens.isEmpty) {
      logger.info('Список FCM токенов пуст, нечего отправлять');
      return 0;
    }

    int successCount = 0;
    for (final token in fcmTokens) {
      if (token.isNotEmpty) {
        final success = await sendNotification(
          fcmToken: token,
          title: title,
          body: body,
          data: data,
        );
        if (success) {
          successCount++;
        }
      }
    }

    logger.info('✅ Отправлено уведомлений: $successCount из ${fcmTokens.length}');
    return successCount;
  }

  /// Отправка уведомления администраторам о покупке подписки
  Future<int> notifyAdminsAboutSubscriptionPurchase({
    required List<String> adminFcmTokens,
    required String userPhone,
    String? userName,
    required String subscriptionType,
    required int amount,
  }) async {
    final title = PushNotificationTexts.subscriptionPurchaseTitle;
    final body = PushNotificationTexts.subscriptionPurchaseBody(userPhone, userName, subscriptionType, amount);

    final data = {
      'type': 'subscription_purchase',
      'user_phone': userPhone,
      'subscription_type': subscriptionType,
      'amount': amount.toString(),
    };

    return await sendNotificationToAllUserTokens(
      fcmTokens: adminFcmTokens,
      title: title,
      body: body,
      data: data,
    );
  }
}

