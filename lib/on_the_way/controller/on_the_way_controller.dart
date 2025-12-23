import 'dart:async';
import 'dart:convert';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/on_the_way/api/create_booking_request.dart';
import 'package:aviapoint_server/on_the_way/api/create_flight_request.dart';
import 'package:aviapoint_server/on_the_way/api/create_review_request.dart';
import 'package:aviapoint_server/on_the_way/data/model/review_model.dart';
import 'package:aviapoint_server/on_the_way/repositories/on_the_way_repository.dart';
import 'package:aviapoint_server/telegram/telegram_bot_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'on_the_way_controller.g.dart';

class OnTheWayController {
  final OnTheWayRepository _onTheWayRepository;
  OnTheWayController({required OnTheWayRepository onTheWayRepository}) : _onTheWayRepository = onTheWayRepository;

  Router get router => _$OnTheWayControllerRouter(this);

  // Получение списка полетов
  @Route.get('/api/flights')
  @OpenApiRoute()
  Future<Response> getFlights(Request request) async {
    return wrapResponse(() async {
      final departureAirport = request.url.queryParameters['departure_airport'];
      final arrivalAirport = request.url.queryParameters['arrival_airport'];
      final dateFromStr = request.url.queryParameters['date_from'];
      final dateToStr = request.url.queryParameters['date_to'];

      DateTime? dateFrom;
      DateTime? dateTo;

      if (dateFromStr != null && dateFromStr.isNotEmpty) {
        dateFrom = DateTime.tryParse(dateFromStr);
        print('🔵 [OnTheWayController] getFlights: dateFromStr = $dateFromStr, parsed = $dateFrom');
      }
      if (dateToStr != null && dateToStr.isNotEmpty) {
        dateTo = DateTime.tryParse(dateToStr);
        print('🔵 [OnTheWayController] getFlights: dateToStr = $dateToStr, parsed = $dateTo');
      }

      print('🔵 [OnTheWayController] getFlights: dateFrom = $dateFrom, dateTo = $dateTo');

      final flights = await _onTheWayRepository.fetchFlights(departureAirport: departureAirport, arrivalAirport: arrivalAirport, dateFrom: dateFrom, dateTo: dateTo);

      print('🔵 [OnTheWayController] getFlights: returned ${flights.length} flights');
      final cancelledFlights = flights.where((f) => f.status == 'cancelled').toList();
      print('🔵 [OnTheWayController] getFlights: cancelled flights count = ${cancelledFlights.length}');

      return Response.ok(jsonEncode(flights), headers: jsonContentHeaders);
    });
  }

  // Получение полетов текущего пилота
  @Route.get('/api/flights/my')
  @OpenApiRoute()
  Future<Response> getMyFlights(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final pilotId = int.parse(userId);
      final flights = await _onTheWayRepository.fetchFlights(pilotId: pilotId);

      return Response.ok(jsonEncode(flights), headers: jsonContentHeaders);
    });
  }

  // Получение полета по ID
  @Route.get('/api/flights/<id>')
  @OpenApiRoute()
  Future<Response> getFlight(Request request) async {
    return wrapResponse(() async {
      final id = request.params['id'];
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Flight ID is required'}), headers: jsonContentHeaders);
      }
      final flightId = int.parse(id);
      final flight = await _onTheWayRepository.fetchFlightById(flightId);

      if (flight == null) {
        return Response.notFound(jsonEncode({'error': 'Flight not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(flight), headers: jsonContentHeaders);
    });
  }

  // Создание полета
  @Route.post('/api/flights')
  @OpenApiRoute()
  Future<Response> createFlight(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final pilotId = int.parse(userId);

      final body = await request.readAsString();
      final createRequest = CreateFlightRequest.fromJson(jsonDecode(body));

      final flight = await _onTheWayRepository.createFlight(
        pilotId: pilotId,
        departureAirport: createRequest.departureAirport,
        arrivalAirport: createRequest.arrivalAirport,
        departureDate: createRequest.departureDate,
        availableSeats: createRequest.availableSeats,
        pricePerSeat: createRequest.pricePerSeat,
        aircraftType: createRequest.aircraftType,
        description: createRequest.description,
      );

      return Response.ok(jsonEncode(flight), headers: jsonContentHeaders);
    });
  }

  // Обновление полета
  @Route.put('/api/flights/<id>')
  @OpenApiRoute()
  Future<Response> updateFlight(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final id = request.params['id'];
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Flight ID is required'}), headers: jsonContentHeaders);
      }
      final flightId = int.parse(id);
      final flight = await _onTheWayRepository.fetchFlightById(flightId);

      if (flight == null) {
        return Response.notFound(jsonEncode({'error': 'Flight not found'}), headers: jsonContentHeaders);
      }

      // Проверка прав доступа (только владелец может редактировать)
      if (flight.pilotId != int.parse(userId)) {
        return Response.forbidden(jsonEncode({'error': 'Forbidden: You can only edit your own flights'}), headers: jsonContentHeaders);
      }

      final body = await request.readAsString();
      final updateData = jsonDecode(body) as Map<String, dynamic>;

      // ВАЖНО: В БД поле price_per_seat имеет тип INTEGER, поэтому округляем до int
      double? pricePerSeat;
      if (updateData['price_per_seat'] != null) {
        final priceValue = updateData['price_per_seat'];
        if (priceValue is num) {
          pricePerSeat = priceValue.toDouble();
        } else if (priceValue is String) {
          pricePerSeat = double.tryParse(priceValue);
        }
      }

      final updatedFlight = await _onTheWayRepository.updateFlight(
        id: flightId,
        departureAirport: updateData['departure_airport'] as String?,
        arrivalAirport: updateData['arrival_airport'] as String?,
        departureDate: updateData['departure_date'] != null ? DateTime.parse(updateData['departure_date'] as String) : null,
        availableSeats: updateData['available_seats'] as int?,
        pricePerSeat: pricePerSeat,
        aircraftType: updateData['aircraft_type'] as String?,
        description: updateData['description'] as String?,
        status: updateData['status'] as String?,
      );

      return Response.ok(jsonEncode(updatedFlight), headers: jsonContentHeaders);
    });
  }

  // Удаление полета
  @Route.delete('/api/flights/<id>')
  @OpenApiRoute()
  Future<Response> deleteFlight(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final id = request.params['id'];
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Flight ID is required'}), headers: jsonContentHeaders);
      }
      final flightId = int.parse(id);
      final flight = await _onTheWayRepository.fetchFlightById(flightId);

      if (flight == null) {
        return Response.notFound(jsonEncode({'error': 'Flight not found'}), headers: jsonContentHeaders);
      }

      // Проверка прав доступа (только владелец может отменять)
      if (flight.pilotId != int.parse(userId)) {
        return Response.forbidden(jsonEncode({'error': 'Forbidden: You can only cancel your own flights'}), headers: jsonContentHeaders);
      }

      // Отменяем полет (меняем статус на 'cancelled' и отменяем все бронирования)
      print('🔵 [OnTheWayController] deleteFlight: Отмена полета id=$flightId');
      final cancelledFlight = await _onTheWayRepository.deleteFlight(flightId);
      print('🔵 [OnTheWayController] deleteFlight: Полет отменен, статус: ${cancelledFlight.status}');

      return Response.ok(jsonEncode(cancelledFlight), headers: jsonContentHeaders);
    });
  }

  // Получение бронирований по flight_id (для пилота)
  @Route.get('/api/flights/<flightId>/bookings')
  @OpenApiRoute()
  Future<Response> getBookingsByFlightId(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final flightIdStr = request.params['flightId'];
      if (flightIdStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Flight ID is required'}), headers: jsonContentHeaders);
      }
      final flightId = int.parse(flightIdStr);

      // Проверяем, что пользователь является пилотом этого полета
      final flight = await _onTheWayRepository.fetchFlightById(flightId);
      if (flight == null) {
        return Response.notFound(jsonEncode({'error': 'Flight not found'}), headers: jsonContentHeaders);
      }

      final pilotId = int.parse(userId);
      if (flight.pilotId != pilotId) {
        return Response.forbidden(jsonEncode({'error': 'Forbidden: You can only view bookings for your own flights'}), headers: jsonContentHeaders);
      }

      final bookings = await _onTheWayRepository.fetchBookingsByFlightId(flightId);

      return Response.ok(jsonEncode(bookings), headers: jsonContentHeaders);
    });
  }

  // Получение бронирований пользователя
  @Route.get('/api/bookings')
  @OpenApiRoute()
  Future<Response> getBookings(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final bookings = await _onTheWayRepository.fetchBookings(userId: int.parse(userId));

      return Response.ok(jsonEncode(bookings), headers: jsonContentHeaders);
    });
  }

  // Создание бронирования
  @Route.post('/api/bookings')
  @OpenApiRoute()
  Future<Response> createBooking(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final passengerId = int.parse(userId);

      final body = await request.readAsString();
      final createRequest = CreateBookingRequest.fromJson(jsonDecode(body));

      // Проверяем, что пользователь не является пилотом этого полета
      final flight = await _onTheWayRepository.fetchFlightById(createRequest.flightId);
      if (flight == null) {
        return Response.notFound(jsonEncode({'error': 'Flight not found'}), headers: jsonContentHeaders);
      }

      if (flight.pilotId == passengerId) {
        return Response.badRequest(body: jsonEncode({'error': 'You cannot book a seat on your own flight'}), headers: jsonContentHeaders);
      }

      try {
        final booking = await _onTheWayRepository.createBooking(flightId: createRequest.flightId, passengerId: passengerId, seatsCount: createRequest.seatsCount);

        final bookingJson = booking.toJson();
        print('🔵 [OnTheWayController] createBooking booking.toJson(): $bookingJson');
        bookingJson.forEach((key, value) {
          print('🔵 [OnTheWayController] createBooking field "$key": value=$value, type=${value.runtimeType}');
        });

        return Response.ok(jsonEncode(booking), headers: jsonContentHeaders);
      } catch (e) {
        print('❌ [OnTheWayController] createBooking error: $e');
        return Response.badRequest(body: jsonEncode({'error': e.toString()}), headers: jsonContentHeaders);
      }
    });
  }

  // Подтверждение бронирования
  @Route.put('/api/bookings/<id>/confirm')
  @OpenApiRoute()
  Future<Response> confirmBooking(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final id = request.params['id'];
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Booking ID is required'}), headers: jsonContentHeaders);
      }
      final bookingId = int.parse(id);

      // Получаем бронирование для проверки прав доступа
      final bookings = await _onTheWayRepository.fetchBookings();
      final booking = bookings.firstWhere((b) => b.id == bookingId, orElse: () => throw Exception('Booking not found'));

      // Получаем полет для проверки, что пользователь является пилотом
      final flight = await _onTheWayRepository.fetchFlightById(booking.flightId);
      if (flight == null) {
        return Response.notFound(jsonEncode({'error': 'Flight not found'}), headers: jsonContentHeaders);
      }

      // Проверяем, что пользователь является пилотом этого полета
      final pilotId = int.parse(userId);
      if (flight.pilotId != pilotId) {
        return Response.forbidden(jsonEncode({'error': 'Forbidden: You can only confirm bookings for your own flights'}), headers: jsonContentHeaders);
      }

      final confirmedBooking = await _onTheWayRepository.confirmBooking(bookingId);

      return Response.ok(jsonEncode(confirmedBooking), headers: jsonContentHeaders);
    });
  }

  // Отмена бронирования
  @Route.put('/api/bookings/<id>/cancel')
  @OpenApiRoute()
  Future<Response> cancelBooking(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final id = request.params['id'];
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Booking ID is required'}), headers: jsonContentHeaders);
      }
      final bookingId = int.parse(id);
      // TODO: Проверить, что пользователь является владельцем бронирования или пилотом

      final booking = await _onTheWayRepository.cancelBooking(bookingId);

      return Response.ok(jsonEncode(booking), headers: jsonContentHeaders);
    });
  }

  // Получение отзывов о пользователе
  @Route.get('/api/reviews/<userId>')
  @OpenApiRoute()
  Future<Response> getReviews(Request request) async {
    return wrapResponse(() async {
      final userId = request.params['userId'];
      if (userId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'User ID is required'}), headers: jsonContentHeaders);
      }
      final reviews = await _onTheWayRepository.fetchReviews(int.parse(userId));

      return Response.ok(jsonEncode(reviews), headers: jsonContentHeaders);
    });
  }

  // Получение отзывов по полёту
  @Route.get('/api/reviews/flight/<flightId>')
  @OpenApiRoute()
  Future<Response> getReviewsByFlightId(Request request) async {
    return wrapResponse(() async {
      final flightId = request.params['flightId'];
      if (flightId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Flight ID is required'}), headers: jsonContentHeaders);
      }
      final reviews = await _onTheWayRepository.fetchReviewsByFlightId(int.parse(flightId));

      return Response.ok(jsonEncode(reviews), headers: jsonContentHeaders);
    });
  }

  // Создание отзыва
  @Route.post('/api/reviews')
  @OpenApiRoute()
  Future<Response> createReview(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final reviewerId = int.parse(userId);

      final body = await request.readAsString();
      final createRequest = CreateReviewRequest.fromJson(jsonDecode(body));

      final review = await _onTheWayRepository.createReview(
        bookingId: createRequest.bookingId,
        reviewerId: reviewerId,
        reviewedId: createRequest.reviewedId,
        rating: createRequest.rating,
        comment: createRequest.comment,
        replyToReviewId: createRequest.replyToReviewId,
      );

      // Отправляем уведомление в Telegram
      try {
        final flightInfo = await _onTheWayRepository.getFlightInfoForNotification(createRequest.bookingId);
        await _sendTelegramNotification(review, flightInfo);
      } catch (e) {
        print('⚠️ [OnTheWayController] Ошибка отправки Telegram уведомления: $e');
        // Не прерываем выполнение, если уведомление не отправилось
      }

      return Response.ok(jsonEncode(review), headers: jsonContentHeaders);
    });
  }

  // Обновление отзыва
  @Route.put('/api/reviews/<id>')
  @OpenApiRoute()
  Future<Response> updateReview(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final id = request.params['id'];
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Review ID is required'}), headers: jsonContentHeaders);
      }

      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final rating = json['rating'] as int?; // Может быть null для ответов на отзывы
      final comment = json['comment'] as String?;

      final review = await _onTheWayRepository.updateReview(reviewId: int.parse(id), userId: int.parse(userId), rating: rating, comment: comment);

      return Response.ok(jsonEncode(review), headers: jsonContentHeaders);
    });
  }

  // Удаление отзыва
  @Route.delete('/api/reviews/<id>')
  @OpenApiRoute()
  Future<Response> deleteReview(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final id = request.params['id'];
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Review ID is required'}), headers: jsonContentHeaders);
      }

      await _onTheWayRepository.deleteReview(reviewId: int.parse(id), userId: int.parse(userId));

      return Response.ok(jsonEncode({'success': true}), headers: jsonContentHeaders);
    });
  }

  // Отправка уведомления в Telegram
  Future<void> _sendTelegramNotification(ReviewModel review, Map<String, dynamic> flightInfo) async {
    try {
      final telegramBotService = TelegramBotService();

      // Получаем дату полёта
      DateTime departureDate;
      if (flightInfo['departure_date'] is DateTime) {
        departureDate = flightInfo['departure_date'] as DateTime;
      } else if (flightInfo['departure_date'] is String) {
        departureDate = DateTime.parse(flightInfo['departure_date'] as String);
      } else {
        departureDate = DateTime.now();
      }

      // Отправляем уведомление только если есть рейтинг (для основных отзывов) или это ответ на отзыв
      // Для ответов на отзывы rating может быть null, используем 0
      // Для обычных отзывов rating должен быть не null
      if (review.rating != null || review.replyToReviewId != null) {
        await telegramBotService.notifyReviewCreated(
          reviewId: review.id,
          flightId: flightInfo['flight_id'] as int,
          pilotId: flightInfo['pilot_id'] as int,
          passengerId: flightInfo['passenger_id'] as int,
          departureAirport: flightInfo['departure_airport'] as String,
          arrivalAirport: flightInfo['arrival_airport'] as String,
          departureDate: departureDate,
          pilotName: flightInfo['pilot_name'] as String? ?? 'Пилот',
          passengerName: flightInfo['passenger_name'] as String? ?? 'Пассажир',
          reviewerId: review.reviewerId,
          reviewedId: review.reviewedId,
          rating: review.rating ?? 0, // Для ответов на отзывы rating может быть null, используем 0
          comment: review.comment,
          isReply: review.replyToReviewId != null,
        );
      }

      print('✅ [OnTheWayController] Telegram уведомление о новом отзыве отправлено');
    } catch (e, stackTrace) {
      print('❌ [OnTheWayController] Ошибка отправки Telegram уведомления: $e');
      print('Stack trace: $stackTrace');
      // Не прерываем выполнение, если уведомление не отправилось
    }
  }
}
