import 'dart:async';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/on_the_way/repositories/on_the_way_repository.dart';
import 'package:aviapoint_server/push_notifications/fcm_service.dart';

/// Сервис для автоматического управления статусами полётов
class FlightStatusService {
  final OnTheWayRepository _repository;
  Timer? _completionTimer;
  Timer? _notificationTimer;
  final Map<int, bool> _notifiedFlights = {}; // Кэш для отслеживания отправленных уведомлений

  FlightStatusService({required OnTheWayRepository repository}) : _repository = repository;

  /// Запуск периодических задач
  void start() {
    logger.info('🚀 [FlightStatusService] Запуск периодических задач...');

    // Задача для автоматического завершения полётов (каждые 30 минут)
    _completionTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _completeFlightsAfter24Hours().catchError((e, stackTrace) {
        logger.severe('❌ [FlightStatusService] Ошибка в периодической задаче завершения: $e');
        logger.severe('Stack trace: $stackTrace');
      });
    });

    // Задача для уведомлений пилотам (каждые 30 минут)
    _notificationTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _notifyPilotsAfter12Hours().catchError((e, stackTrace) {
        logger.severe('❌ [FlightStatusService] Ошибка в периодической задаче уведомлений: $e');
        logger.severe('Stack trace: $stackTrace');
      });
    });

    // Выполняем задачи сразу при старте (без await, чтобы не блокировать запуск)
    _completeFlightsAfter24Hours().catchError((e, stackTrace) {
      logger.severe('❌ [FlightStatusService] Ошибка при начальной проверке завершения: $e');
      logger.severe('Stack trace: $stackTrace');
    });
    _notifyPilotsAfter12Hours().catchError((e, stackTrace) {
      logger.severe('❌ [FlightStatusService] Ошибка при начальной проверке уведомлений: $e');
      logger.severe('Stack trace: $stackTrace');
    });

    logger.info('✅ [FlightStatusService] Периодические задачи запущены');
  }

  /// Остановка периодических задач
  void stop() {
    _completionTimer?.cancel();
    _notificationTimer?.cancel();
    logger.info('🛑 [FlightStatusService] Периодические задачи остановлены');
  }

  /// Автоматическое завершение полётов через 24 часа после даты полёта
  Future<void> _completeFlightsAfter24Hours() async {
    try {
      logger.info('🔄 [FlightStatusService] Проверка полётов для автоматического завершения...');

      // Получаем все активные полёты
      final flights = await _repository.fetchFlights(pilotId: null);

      final now = DateTime.now();
      int completedCount = 0;

      for (final flight in flights) {
        // Пропускаем полёты, которые уже не активны
        if (flight.status != 'active') {
          continue;
        }

        // Проверяем, прошло ли 24 часа с даты полёта
        final hoursSinceDeparture = now.difference(flight.departureDate).inHours;

        // Пропускаем полёты, которые ещё не состоялись
        if (hoursSinceDeparture < 0) {
          continue;
        }

        if (hoursSinceDeparture >= 24) {
          try {
            // Обновляем статус на 'completed'
            await _repository.updateFlight(
              id: flight.id,
              departureAirport: null,
              arrivalAirport: null,
              departureDate: null,
              availableSeats: null,
              pricePerSeat: null,
              aircraftType: null,
              description: null,
              status: 'completed',
            );

            completedCount++;
            logger.info('✅ [FlightStatusService] Полёт #${flight.id} автоматически завершён (прошло ${hoursSinceDeparture} часов)');

            // Удаляем из кэша уведомлений, если был там
            _notifiedFlights.remove(flight.id);
          } catch (e) {
            logger.severe('❌ [FlightStatusService] Ошибка при завершении полёта #${flight.id}: $e');
          }
        }
      }

      if (completedCount > 0) {
        logger.info('✅ [FlightStatusService] Автоматически завершено полётов: $completedCount');
      }
    } catch (e, stackTrace) {
      logger.severe('❌ [FlightStatusService] Ошибка при автоматическом завершении полётов: $e');
      logger.severe('Stack trace: $stackTrace');
    }
  }

  /// Уведомление пилотам через 12 часов после даты полёта
  Future<void> _notifyPilotsAfter12Hours() async {
    try {
      logger.info('🔄 [FlightStatusService] Проверка полётов для уведомлений пилотам...');

      // Получаем все активные полёты
      final flights = await _repository.fetchFlights(pilotId: null);

      final now = DateTime.now();
      int notifiedCount = 0;

      for (final flight in flights) {
        // Пропускаем полёты, которые уже не активны
        if (flight.status != 'active') {
          continue;
        }

        // Пропускаем, если уже отправили уведомление
        if (_notifiedFlights[flight.id] == true) {
          continue;
        }

        // Проверяем, прошло ли 12 часов с даты полёта
        final hoursSinceDeparture = now.difference(flight.departureDate).inHours;

        // Пропускаем полёты, которые ещё не состоялись или уже прошло больше 24 часов
        if (hoursSinceDeparture < 0 || hoursSinceDeparture >= 24) {
          continue;
        }

        if (hoursSinceDeparture >= 12) {
          try {
            // Получаем информацию о пилоте для уведомления
            final pilotInfo = await _repository.getPilotInfoForNotification(flight.pilotId);
            final fcmToken = pilotInfo['fcm_token'] as String?;

            bool notificationSent = false;

            // Отправляем push-уведомление пилоту, если есть FCM токен
            if (fcmToken != null && fcmToken.isNotEmpty) {
              final fcmService = FcmService();
              final pushSent = await fcmService.notifyPilotToCompleteFlight(
                fcmToken: fcmToken,
                departureAirport: flight.departureAirport,
                arrivalAirport: flight.arrivalAirport,
                departureDate: flight.departureDate,
                flightId: flight.id,
                hoursSinceDeparture: hoursSinceDeparture,
              );

              if (pushSent) {
                notificationSent = true;
                logger.info('✅ [FlightStatusService] Push-уведомление отправлено пилоту полёта #${flight.id}');
              }
            }

            if (notificationSent) {
              _notifiedFlights[flight.id] = true;
              notifiedCount++;
            } else {
              logger.info('⚠️ [FlightStatusService] Не удалось отправить push-уведомление для полёта #${flight.id} (нет FCM токена)');
            }
          } catch (e) {
            logger.severe('❌ [FlightStatusService] Ошибка при отправке уведомления для полёта #${flight.id}: $e');
          }
        }
      }

      if (notifiedCount > 0) {
        logger.info('✅ [FlightStatusService] Отправлено уведомлений пилотам: $notifiedCount');
      }
    } catch (e, stackTrace) {
      logger.severe('❌ [FlightStatusService] Ошибка при отправке уведомлений пилотам: $e');
      logger.severe('Stack trace: $stackTrace');
    }
  }
}
