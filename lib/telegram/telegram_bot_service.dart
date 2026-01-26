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

      final response =
          await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'chat_id': _chatId, 'text': message, 'parse_mode': 'HTML'})).timeout(const Duration(seconds: 10));

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
    final message = '''
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

    final message = '''
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

  /// Уведомление о создании нового полёта
  Future<void> notifyFlightCreated({
    required int flightId,
    required int pilotId,
    required String pilotName,
    required String pilotPhone,
    required String departureAirport,
    required String arrivalAirport,
    required DateTime departureDate,
    required int availableSeats,
    required double pricePerSeat,
    String? aircraftType,
    List<Map<String, dynamic>>? waypoints,
  }) async {
    // Форматируем дату полёта
    final flightDate = departureDate.toLocal().toString().substring(0, 16);

    // Формируем маршрут с промежуточными точками
    String routeText = '$departureAirport → $arrivalAirport';
    if (waypoints != null && waypoints.length > 2) {
      // Сортируем waypoints по sequence_order
      final sortedWaypoints = List<Map<String, dynamic>>.from(waypoints)..sort((a, b) => (a['sequence_order'] as int).compareTo(b['sequence_order'] as int));

      // Берем промежуточные точки (исключаем первую и последнюю)
      final intermediatePoints = sortedWaypoints.sublist(1, sortedWaypoints.length - 1).map((wp) => wp['airport_code'] as String? ?? '').where((code) => code.isNotEmpty).toList();

      if (intermediatePoints.isNotEmpty) {
        routeText = '$departureAirport → ${intermediatePoints.join(' → ')} → $arrivalAirport';
      }
    }

    final message = '''
✈️ <b>Новый полёт создан</b>

🆔 <b>ID полёта:</b> $flightId
👤 <b>Пилот ID:</b> $pilotId
👤 <b>Пилот:</b> $pilotName
📱 <b>Телефон:</b> $pilotPhone

✈️ <b>Маршрут:</b> $routeText
📅 <b>Дата вылета:</b> $flightDate
💺 <b>Свободных мест:</b> $availableSeats
💵 <b>Цена за место:</b> ${pricePerSeat.toStringAsFixed(0)} ₽
${aircraftType != null && aircraftType.isNotEmpty ? '🛩️ <b>Тип самолёта:</b> $aircraftType' : ''}

🕐 <b>Время создания:</b> ${DateTime.now().toLocal().toString().substring(0, 19)}
''';

    await sendMessage(message);
  }

  /// Отправка фото в Telegram
  Future<bool> sendPhoto(String photoUrl, {String? caption}) async {
    if (_botToken == null || _botToken!.isEmpty || _chatId == null || _chatId!.isEmpty) {
      logger.info('Telegram bot не настроен, пропускаем отправку фото');
      return false;
    }

    try {
      final url = Uri.parse('https://api.telegram.org/bot$_botToken/sendPhoto');

      final body = {
        'chat_id': _chatId,
        'photo': photoUrl,
        if (caption != null && caption.isNotEmpty) 'caption': caption,
        'parse_mode': 'HTML',
      };

      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body)).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        logger.info('✅ Telegram фото отправлено');
        return true;
      } else {
        logger.info('⚠️ Ошибка отправки Telegram фото: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      logger.severe('❌ Ошибка при отправке Telegram фото: $e');
      logger.severe('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Уведомление о создании новой статьи блога
  Future<void> notifyBlogArticleCreated({
    required int articleId,
    required int authorId,
    required String authorName,
    required String authorPhone,
    required String title,
    String? excerpt,
    String? content,
    String? coverImageUrl,
    required String status,
    String? categoryName,
    String? aircraftModelName,
    String? baseUrl,
  }) async {
    try {
      logger.info('📤 Начинаю отправку уведомления о создании статьи в Telegram. ID статьи: $articleId');

      // Определяем статус статьи
      String statusText = status;
      switch (status.toLowerCase()) {
        case 'draft':
          statusText = 'Черновик';
          break;
        case 'published':
          statusText = 'Опубликовано';
          break;
        case 'archived':
          statusText = 'Архив';
          break;
      }

      // Обрезаем excerpt, если он слишком длинный
      String? excerptText = excerpt;
      if (excerptText != null && excerptText.length > 200) {
        excerptText = '${excerptText.substring(0, 200)}...';
      }

      // Преобразуем JSON Delta content в читаемый текст
      String? contentText = _extractTextFromContent(content);
      if (contentText != null) {
        logger.info('📝 Извлечено содержимое статьи, длина: ${contentText.length} символов');
      }

      // Формируем базовое сообщение
      final message = '''
📝 <b>Новая статья блога создана</b>

🆔 <b>ID статьи:</b> $articleId
👤 <b>Автор ID:</b> $authorId
👤 <b>Автор:</b> $authorName
📱 <b>Телефон:</b> $authorPhone

📌 <b>Название:</b> $title
${excerptText != null && excerptText.isNotEmpty ? '📄 <b>Краткое описание:</b> $excerptText' : ''}
${contentText != null && contentText.isNotEmpty ? '📝 <b>Содержимое:</b>\n${contentText.length > 1000 ? contentText.substring(0, 1000) + '...' : contentText}' : ''}
📊 <b>Статус:</b> $statusText
${categoryName != null && categoryName.isNotEmpty ? '📂 <b>Категория:</b> $categoryName' : ''}
${aircraftModelName != null && aircraftModelName.isNotEmpty ? '🛩️ <b>Модель самолёта:</b> $aircraftModelName' : ''}

🕐 <b>Время создания:</b> ${DateTime.now().toLocal().toString().substring(0, 19)}
''';

      // Если есть обложка, отправляем фото с подписью, иначе только текст
      if (coverImageUrl != null && coverImageUrl.isNotEmpty) {
        logger.info('🖼️ Обложка найдена: $coverImageUrl');
        // Формируем полный URL изображения
        String fullImageUrl = _buildImageUrl(coverImageUrl, baseUrl);
        logger.info('🔗 Полный URL обложки: $fullImageUrl');

        // Отправляем фото с подписью (в Telegram максимальная длина подписи - 1024 символа)
        final photoCaption = message.length > 1024 ? message.substring(0, 1021) + '...' : message;
        final photoSent = await sendPhoto(fullImageUrl, caption: photoCaption);

        if (photoSent) {
          logger.info('✅ Фото с подписью отправлено успешно');
          // Если сообщение было обрезано, отправляем остаток отдельным сообщением
          if (message.length > 1024) {
            await sendMessage(message.substring(1024));
          }
        } else {
          logger.info('⚠️ Не удалось отправить фото, пробуем отправить только текст');
          await sendMessage(message);
        }
      } else {
        logger.info('📝 Обложка не найдена, отправляю только текстовое сообщение');
        await sendMessage(message);
      }

      logger.info('✅ Уведомление о создании статьи отправлено успешно');
    } catch (e, stackTrace) {
      logger.severe('❌ Ошибка при отправке уведомления о создании статьи: $e');
      logger.severe('Stack trace: $stackTrace');
    }
  }

  /// Извлекает текст из JSON Delta контента
  String? _extractTextFromContent(String? contentJson) {
    if (contentJson == null || contentJson.isEmpty) {
      return null;
    }

    try {
      final List<dynamic> delta = jsonDecode(contentJson);
      final buffer = StringBuffer();

      for (final operation in delta) {
        if (operation is Map<String, dynamic>) {
          final insert = operation['insert'];
          if (insert is String) {
            buffer.write(insert);
          } else if (insert is Map<String, dynamic>) {
            // Если это вложение (например, изображение), пропускаем или добавляем метку
            if (insert.containsKey('image')) {
              buffer.write('[Изображение] ');
            }
          }
        }
      }

      final text = buffer.toString().trim();
      return text.isEmpty ? null : text;
    } catch (e) {
      logger.info('⚠️ Ошибка парсинга JSON Delta контента: $e');
      return null;
    }
  }

  /// Формирует полный URL изображения
  String _buildImageUrl(String imagePath, String? baseUrl) {
    // Если путь уже является полным URL, возвращаем как есть
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Получаем базовый URL из переменной окружения или используем переданный
    String serverBaseUrl = baseUrl ?? Platform.environment['BASE_URL'] ?? Platform.environment['SERVER_BASE_URL'] ?? 'https://avia-point.com';

    // Убираем слеш в конце baseUrl, если есть
    if (serverBaseUrl.endsWith('/')) {
      serverBaseUrl = serverBaseUrl.substring(0, serverBaseUrl.length - 1);
    }

    // Убираем начальный слеш из imagePath, если есть
    String cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

    // Формируем полный URL с префиксом /public/
    return '$serverBaseUrl/public/$cleanPath';
  }

  /// Уведомление о создании новой новости
  Future<void> notifyNewsCreated({
    required int newsId,
    required int authorId,
    required String authorName,
    required String authorPhone,
    required String title,
    required String subTitle,
    required String source,
    required String body,
    required String pictureMiniUrl,
    required String pictureBigUrl,
    required int categoryId,
    String? categoryName,
    String? baseUrl,
  }) async {
    try {
      logger.info('📤 Начинаю отправку уведомления о создании новости в Telegram. ID новости: $newsId');

      // Обрезаем текст, если он слишком длинный
      String bodyText = body;
      if (bodyText.length > 500) {
        bodyText = '${bodyText.substring(0, 500)}...';
      }

      // Формируем базовое сообщение
      final message = '''
📰 <b>Новая предложенная новость</b>

🆔 <b>ID новости:</b> $newsId
👤 <b>Автор ID:</b> $authorId
👤 <b>Автор:</b> $authorName
📱 <b>Телефон:</b> $authorPhone

📌 <b>Заголовок:</b> $title
📝 <b>Подзаголовок:</b> $subTitle
🔗 <b>Источник:</b> $source
📂 <b>Категория:</b> ${categoryName ?? 'ID: $categoryId'}

📄 <b>Текст:</b>
$bodyText

🖼️ <b>Изображения:</b>
Миниатюра: $pictureMiniUrl
Большое: $pictureBigUrl

🕐 <b>Время создания:</b> ${DateTime.now().toLocal().toString().substring(0, 19)}
''';

      // Если есть изображение, отправляем фото с подписью
      if (pictureBigUrl.isNotEmpty) {
        final fullImageUrl = _buildImageUrl(pictureBigUrl, baseUrl);
        logger.info('🔗 Полный URL изображения: $fullImageUrl');

        // Отправляем фото с подписью (в Telegram максимальная длина подписи - 1024 символа)
        final photoCaption = message.length > 1024 ? message.substring(0, 1021) + '...' : message;
        final photoSent = await sendPhoto(fullImageUrl, caption: photoCaption);

        if (photoSent) {
          logger.info('✅ Фото с подписью отправлено успешно');
          // Если сообщение было обрезано, отправляем остаток отдельным сообщением
          if (message.length > 1024) {
            await sendMessage(message.substring(1024));
          }
        } else {
          logger.info('⚠️ Не удалось отправить фото, пробуем отправить только текст');
          await sendMessage(message);
        }
      } else {
        logger.info('📝 Изображение не найдено, отправляю только текстовое сообщение');
        await sendMessage(message);
      }

      logger.info('✅ Уведомление о создании новости отправлено успешно');
    } catch (e, stackTrace) {
      logger.severe('❌ Ошибка при отправке уведомления о создании новости: $e');
      logger.severe('Stack trace: $stackTrace');
    }
  }
}
