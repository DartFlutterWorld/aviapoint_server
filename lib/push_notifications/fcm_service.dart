import 'dart:convert';
import 'dart:io';
import 'package:aviapoint_server/logger/logger.dart';
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

  /// Отправка push-уведомления одному пользователю
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
    final title = '⏰ Напоминание о завершении полёта';
    final body = 'Полёт $departureAirport → $arrivalAirport\nПрошло $hoursSinceDeparture часов. Не забудьте завершить полёт!';

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
}

