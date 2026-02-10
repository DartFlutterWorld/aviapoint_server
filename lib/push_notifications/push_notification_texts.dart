/// Централизованное хранилище текстов для push-уведомлений
/// Все тексты уведомлений находятся здесь для удобного редактирования
class PushNotificationTexts {
  PushNotificationTexts._();

  // ========== БРОНИРОВАНИЯ ==========

  /// Заголовок уведомления о новом бронировании для владельца полета
  static const String newBookingTitle = '✈️ Новое бронирование на полёт';

  /// Формат тела уведомления о новом бронировании для владельца полета
  /// Параметры: {waypoints} - точки маршрута, {date} - дата полета
  static String newBookingBody(String waypoints, String date) =>
      'У вас новое бронирование на полёт ($waypoints, $date), необходимо подтвердить';

  /// Заголовок уведомления о подтверждении бронирования для пассажира
  static const String bookingConfirmedTitle = '✅ Бронирование подтверждено';

  /// Формат тела уведомления о подтверждении бронирования для пассажира
  /// Параметры: {waypoints} - точки маршрута, {date} - дата полета
  static String bookingConfirmedBody(String waypoints, String date) =>
      'Ваше бронирование на полёт ($waypoints, $date) подтверждено';

  /// Заголовок уведомления об отмене бронирования для пассажира
  static const String bookingCancelledTitle = '❌ Бронирование отменено';

  /// Формат тела уведомления об отмене бронирования для пассажира
  /// Параметры: {waypoints} - точки маршрута, {date} - дата полета
  static String bookingCancelledBody(String waypoints, String date) =>
      'Ваше бронирование на полёт ($waypoints, $date) было отменено';

  // ========== МАРКЕТ (ОБЪЯВЛЕНИЯ) ==========

  /// Заголовок уведомления о снятии объявления с публикации для владельца
  static const String listingUnpublishedTitle = '📢 Объявление снято с публикации';

  /// Формат тела уведомления о снятии объявления с публикации для владельца
  /// Параметры: {title} - название объявления
  static String listingUnpublishedBody(String title) =>
      'Ваше объявление "$title" снято с публикации, вы можете его снова опубликовать в профиле';

  // ========== НАПОМИНАНИЯ ==========

  /// Заголовок уведомления-напоминания о завершении полета
  static const String flightReminderTitle = '⏰ Напоминание о завершении полёта';

  /// Формат тела уведомления-напоминания о завершении полета
  /// Параметры: {departure} - аэропорт отправления, {arrival} - аэропорт прибытия, {hours} - количество часов
  static String flightReminderBody(String departure, String arrival, int hours) =>
      'Полёт $departure → $arrival\nПрошло $hours часов. Не забудьте завершить полёт!';

  // ========== ПОДПИСКИ ==========

  /// Заголовок уведомления о покупке подписки для администратора
  static const String subscriptionPurchaseTitle = '💰 Новая покупка подписки';

  /// Формат тела уведомления о покупке подписки для администратора
  /// Параметры: {userPhone} - телефон пользователя, {userName} - имя пользователя, {subscriptionType} - тип подписки, {amount} - сумма
  static String subscriptionPurchaseBody(String userPhone, String? userName, String subscriptionType, int amount) {
    final name = userName != null && userName.isNotEmpty ? userName : 'Пользователь';
    return '$name ($userPhone) купил подписку "$subscriptionType" на сумму ${amount.toString()} ₽';
  }

  // ========== ВОПРОСЫ ==========

  /// Заголовок уведомления о новом вопросе для пилота
  static const String newQuestionTitle = '❓ Новый вопрос к полёту';

  /// Формат тела уведомления о новом вопросе для пилота
  /// Параметры: {waypoints} - точки маршрута, {date} - дата полета
  static String newQuestionBody(String waypoints, String date) =>
      'Пассажир задал вопрос о вашем полёте ($waypoints, $date)';

  /// Заголовок уведомления об ответе на вопрос для пассажира
  static const String questionAnsweredTitle = '💬 Ответ на вопрос';

  /// Формат тела уведомления об ответе на вопрос для пассажира
  /// Параметры: {waypoints} - точки маршрута, {date} - дата полета
  static String questionAnsweredBody(String waypoints, String date) =>
      'Пилот ответил на ваш вопрос о полёте ($waypoints, $date)';

  // ========== ОТЗЫВЫ ==========

  /// Заголовок уведомления о новом отзыве для пилота
  static const String newReviewTitle = '⭐ Новый отзыв';

  /// Формат тела уведомления о новом отзыве для пилота
  /// Параметры: {waypoints} - точки маршрута, {date} - дата полета
  static String newReviewBody(String waypoints, String date) =>
      'Пассажир оставил отзыв о вас после полёта ($waypoints, $date)';

  /// Заголовок уведомления о получении отзыва для пассажира
  static const String reviewReceivedTitle = '⭐ Новый отзыв';

  /// Формат тела уведомления о получении отзыва для пассажира
  /// Параметры: {waypoints} - точки маршрута, {date} - дата полета
  static String reviewReceivedBody(String waypoints, String date) =>
      'Пилот оставил отзыв о вас после полёта ($waypoints, $date)';

  // ========== РАБОТА (ВАКАНСИИ / РЕЗЮМЕ) ==========

  /// Заголовок: новый отклик на вакансию (работодателю)
  static const String newVacancyResponseTitle = '📩 Новый отклик на вакансию';

  /// Тело: новый отклик на вакансию. {vacancyTitle} — название вакансии
  static String newVacancyResponseBody(String vacancyTitle) =>
      'По вакансии «$vacancyTitle» поступил новый отклик';

  /// Заголовок: ответ на отклик (кандидату)
  static const String vacancyResponseReplyTitle = '💬 Ответ на ваш отклик';

  /// Тело: работодатель ответил на отклик. {vacancyTitle} — название вакансии
  static String vacancyResponseReplyBody(String vacancyTitle) =>
      'Работодатель ответил на ваш отклик по вакансии «$vacancyTitle»';
}
