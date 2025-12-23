import 'dart:convert';
import 'dart:io';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:http/http.dart' as http;

/// Сервис для отправки уведомлений в Telegram
class TelegramBotService {
  static final TelegramBotService _instance = TelegramBotService._internal();
  factory TelegramBotService() => _instance;
  TelegramBotService._internal();

  String? _botToken;
  String? _chatId;

  /// Инициализация бота
  void init({String? botToken, String? chatId}) {
    _botToken = botToken ?? (Platform.environment['TELEGRAM_BOT_TOKEN'] ?? '');
    _chatId = chatId ?? (Platform.environment['TELEGRAM_CHAT_ID'] ?? '');

    if (_botToken == null || _botToken!.isEmpty) {
      logger.info('⚠️ TELEGRAM_BOT_TOKEN не установлен. Уведомления в Telegram отключены.');
    }
    if (_chatId == null || _chatId!.isEmpty) {
      logger.info('⚠️ TELEGRAM_CHAT_ID не установлен. Уведомления в Telegram отключены.');
    }
  }

  /// Отправка сообщения в Telegram
  Future<bool> sendMessage(String message) async {
    if (_botToken == null || _botToken!.isEmpty || _chatId == null || _chatId!.isEmpty) {
      logger.info('Telegram bot не настроен, пропускаем отправку сообщения');
      return false;
    }

    try {
      final url = Uri.parse('https://api.telegram.org/bot$_botToken/sendMessage');

      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'chat_id': _chatId, 'text': message, 'parse_mode': 'HTML'}))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        logger.info('✅ Telegram уведомление отправлено');
        return true;
      } else {
        logger.info('⚠️ Ошибка отправки Telegram уведомления: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      logger.severe('❌ Ошибка при отправке Telegram уведомления: $e');
      logger.severe('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Уведомление о регистрации нового пользователя
  Future<void> notifyUserRegistration({required int userId, required String phone, String? firstName, String? lastName, String? email}) async {
    final message =
        '''
🔵 <b>Новая регистрация</b>

👤 <b>Пользователь ID:</b> $userId
📱 <b>Телефон:</b> $phone
${firstName != null ? '👤 <b>Имя:</b> $firstName' : ''}
${lastName != null ? '👤 <b>Фамилия:</b> $lastName' : ''}
${email != null && email.isNotEmpty ? '📧 <b>Email:</b> $email' : ''}
🕐 <b>Время:</b> ${DateTime.now().toLocal().toString().substring(0, 19)}
''';

    await sendMessage(message);
  }

  /// Уведомление о покупке подписки
  Future<void> notifySubscriptionPurchase({
    required int userId,
    required String phone,
    required String subscriptionType,
    required int periodDays,
    required double amount,
    required String paymentId,
    String? firstName,
    String? lastName,
  }) async {
    // Преобразуем код типа подписки в читаемое название
    String subscriptionTypeName = subscriptionType;
    switch (subscriptionType.toLowerCase()) {
      case 'monthly':
        subscriptionTypeName = 'Месячная подписка';
        break;
      case 'quarterly':
        subscriptionTypeName = 'Квартальная подписка';
        break;
      case 'yearly':
        subscriptionTypeName = 'Годовая подписка';
        break;
      case 'custom':
        subscriptionTypeName = 'Произвольная подписка';
        break;
    }

    final message =
        '''
💰 <b>Новая подписка</b>

👤 <b>Пользователь ID:</b> $userId
📱 <b>Телефон:</b> $phone
${firstName != null && firstName.isNotEmpty ? '👤 <b>Имя:</b> $firstName' : ''}
${lastName != null && lastName.isNotEmpty ? '👤 <b>Фамилия:</b> $lastName' : ''}
📦 <b>Тип подписки:</b> $subscriptionTypeName
⏱️ <b>Период:</b> $periodDays дней
💵 <b>Сумма:</b> ${amount.toStringAsFixed(2)} ₽
🆔 <b>Payment ID:</b> $paymentId
🕐 <b>Время:</b> ${DateTime.now().toLocal().toString().substring(0, 19)}
''';

    await sendMessage(message);
  }

  /// Уведомление о новом отзыве
  Future<void> notifyReviewCreated({
    required int reviewId,
    required int flightId,
    required int pilotId,
    required int passengerId,
    required String departureAirport,
    required String arrivalAirport,
    required DateTime departureDate,
    required String pilotName,
    required String passengerName,
    required int reviewerId,
    required int reviewedId,
    required int rating,
    String? comment,
    bool isReply = false,
  }) async {
    // Определяем, кто оставил отзыв (пилот или пассажир)
    final isPilotReview = reviewerId == pilotId;
    final reviewerName = isPilotReview ? pilotName : passengerName;
    final reviewedName = isPilotReview ? passengerName : pilotName;

    // Форматируем дату полёта
    final flightDate = departureDate.toLocal().toString().substring(0, 16);

    // Формируем звёздочки для рейтинга
    final stars = '⭐' * rating + '☆' * (5 - rating);

    final message = isReply
        ? '''
💬 <b>Новый ответ на отзыв</b>

✈️ <b>Полёт:</b> $departureAirport → $arrivalAirport
📅 <b>Дата полёта:</b> $flightDate
🆔 <b>ID полёта:</b> $flightId

👤 <b>От:</b> $reviewerName
👤 <b>Для:</b> $reviewedName
${comment != null && comment.isNotEmpty ? '💬 <b>Комментарий:</b> $comment' : ''}
🕐 <b>Время:</b> ${DateTime.now().toLocal().toString().substring(0, 19)}
'''
        : '''
⭐ <b>Новый отзыв о полёте</b>

✈️ <b>Полёт:</b> $departureAirport → $arrivalAirport
📅 <b>Дата полёта:</b> $flightDate
🆔 <b>ID полёта:</b> $flightId

👤 <b>От:</b> $reviewerName
👤 <b>Для:</b> $reviewedName
⭐ <b>Рейтинг:</b> $stars ($rating/5)
${comment != null && comment.isNotEmpty ? '💬 <b>Комментарий:</b> $comment' : ''}
🕐 <b>Время:</b> ${DateTime.now().toLocal().toString().substring(0, 19)}
''';

    await sendMessage(message);
  }
}
