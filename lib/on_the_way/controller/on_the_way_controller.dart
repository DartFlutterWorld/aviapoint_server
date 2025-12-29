import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/on_the_way/api/create_booking_request.dart';
import 'package:aviapoint_server/on_the_way/api/create_flight_request.dart';
import 'package:aviapoint_server/on_the_way/api/create_review_request.dart';
import 'package:aviapoint_server/on_the_way/api/create_flight_question_request.dart';
import 'package:aviapoint_server/on_the_way/api/update_flight_question_request.dart';
import 'package:aviapoint_server/on_the_way/api/answer_flight_question_request.dart';
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

      final airport = request.url.queryParameters['airport'];
      final flights = await _onTheWayRepository.fetchFlights(airport: airport, departureAirport: departureAirport, arrivalAirport: arrivalAirport, dateFrom: dateFrom, dateTo: dateTo);

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

      // Читаем тело запроса как обычный JSON (как для аэропортов)
      final body = await request.readAsString();
      final createRequest = CreateFlightRequest.fromJson(jsonDecode(body));

      // Преобразуем waypoints в формат для repository
      List<Map<String, dynamic>>? waypoints;
      if (createRequest.waypoints != null && createRequest.waypoints!.isNotEmpty) {
        waypoints = createRequest.waypoints!
            .map((wp) => {
                  'airport_code': wp.airportCode,
                  'sequence_order': wp.sequenceOrder,
                  'arrival_time': wp.arrivalTime,
                  'departure_time': wp.departureTime,
                  'comment': wp.comment,
                })
            .toList();
      }

      // Создаем полет
      final flight = await _onTheWayRepository.createFlight(
        pilotId: pilotId,
        departureAirport: createRequest.departureAirport,
        arrivalAirport: createRequest.arrivalAirport,
        departureDate: createRequest.departureDate,
        availableSeats: createRequest.availableSeats,
        pricePerSeat: createRequest.pricePerSeat,
        aircraftType: createRequest.aircraftType,
        description: createRequest.description,
        waypoints: waypoints,
      );

      // Фотографии загружаются отдельным запросом через uploadFlightPhotos (как для аэропортов)
      return Response.ok(jsonEncode(flight.toJson()), headers: jsonContentHeaders);
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

      // Преобразуем waypoints, если они переданы
      List<Map<String, dynamic>>? waypoints;
      if (updateData['waypoints'] != null) {
        final waypointsList = updateData['waypoints'] as List;
        waypoints = waypointsList.map((wp) {
          final wpMap = wp as Map<String, dynamic>;
          return {
            'airport_code': wpMap['airport_code'] as String,
            'sequence_order': wpMap['sequence_order'] as int,
            'arrival_time': wpMap['arrival_time'] != null ? DateTime.parse(wpMap['arrival_time'] as String) : null,
            'departure_time': wpMap['departure_time'] != null ? DateTime.parse(wpMap['departure_time'] as String) : null,
            'comment': wpMap['comment'] as String?,
          };
        }).toList();
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
        waypoints: waypoints,
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
      print('🔵 [OnTheWayController] createBooking received body: $body');

      final bodyJson = jsonDecode(body);
      print('🔵 [OnTheWayController] createBooking parsed JSON: $bodyJson');

      final createRequest = CreateBookingRequest.fromJson(bodyJson);
      print('🔵 [OnTheWayController] createBooking request: flightId=${createRequest.flightId}, seatsCount=${createRequest.seatsCount}');

      // Проверяем, что пользователь не является пилотом этого полета
      final flight = await _onTheWayRepository.fetchFlightById(createRequest.flightId);
      if (flight == null) {
        return Response.notFound(jsonEncode({'error': 'Flight not found'}), headers: jsonContentHeaders);
      }

      if (flight.pilotId == passengerId) {
        return Response.badRequest(body: jsonEncode({'error': 'You cannot book a seat on your own flight'}), headers: jsonContentHeaders);
      }

      try {
        print('🔵 [OnTheWayController] createBooking calling repository.createBooking...');
        final booking = await _onTheWayRepository.createBooking(flightId: createRequest.flightId, passengerId: passengerId, seatsCount: createRequest.seatsCount);
        print('✅ [OnTheWayController] createBooking repository returned booking: id=${booking.id}');

        print('🔵 [OnTheWayController] createBooking calling booking.toJson()...');
        final bookingJson = booking.toJson();
        print('✅ [OnTheWayController] createBooking booking.toJson() completed');
        print('🔵 [OnTheWayController] createBooking booking.toJson(): $bookingJson');
        bookingJson.forEach((key, value) {
          print('🔵 [OnTheWayController] createBooking field "$key": value=$value, type=${value.runtimeType}');
        });

        print('🔵 [OnTheWayController] createBooking calling jsonEncode(bookingJson)...');
        final jsonString = jsonEncode(bookingJson);
        print('✅ [OnTheWayController] createBooking jsonEncode completed, length=${jsonString.length}');

        return Response.ok(jsonString, headers: jsonContentHeaders);
      } catch (e, stackTrace) {
        print('❌ [OnTheWayController] createBooking error: $e');
        print('❌ [OnTheWayController] createBooking stackTrace: $stackTrace');
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

      return Response.ok(jsonEncode(booking.toJson()), headers: jsonContentHeaders);
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

  // Загрузка фотографий к полету
  @Route.post('/api/flights/<id>/photos')
  @OpenApiRoute()
  Future<Response> uploadFlightPhotos(Request request) async {
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

      final userIdStr = tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final userId = int.parse(userIdStr);

      // Получаем ID полета
      final id = request.params['id'];
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Flight ID is required'}), headers: jsonContentHeaders);
      }
      final flightId = int.parse(id);

      // Проверяем, что пользователь является участником полета (пилот или пассажир с подтвержденным бронированием)
      final flight = await _onTheWayRepository.fetchFlightById(flightId);
      if (flight == null) {
        return Response.notFound(jsonEncode({'error': 'Flight not found'}), headers: jsonContentHeaders);
      }

      // Проверяем, является ли пользователь пилотом
      final isPilot = flight.pilotId == userId;

      // Если не пилот, проверяем, есть ли подтвержденное бронирование
      if (!isPilot) {
        final bookings = await _onTheWayRepository.fetchBookingsByFlightId(flightId);
        final hasConfirmedBooking = bookings.any(
          (b) => b.passengerId == userId && b.status == 'confirmed',
        );
        if (!hasConfirmedBooking) {
          return Response.forbidden(
            jsonEncode({'error': 'Only flight participants can upload photos'}),
            headers: jsonContentHeaders,
          );
        }
      }

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'];
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}),
          headers: jsonContentHeaders,
        );
      }

      // Парсим multipart запрос (используем ту же логику, что и для профиля)
      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing boundary in Content-Type'}),
          headers: jsonContentHeaders,
        );
      }

      // Читаем тело запроса
      final bodyBytes = <int>[];
      await for (final chunk in request.read()) {
        bodyBytes.addAll(chunk);
      }

      // Парсим multipart вручную
      final boundaryMarker = '--$boundary';
      final boundaryBytes = utf8.encode(boundaryMarker);
      final parts = <Map<String, dynamic>>[];

      int searchStart = 0;
      while (true) {
        final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (boundaryIndex == -1) break;

        searchStart = boundaryIndex + boundaryBytes.length;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

        if (partEnd > searchStart) {
          final partBytes = bodyBytes.sublist(searchStart, partEnd);
          final partData = _parseMultipartPart(partBytes);
          if (partData != null) {
            parts.add(partData);
          }
        }

        if (nextBoundaryIndex == -1) break;
        searchStart = nextBoundaryIndex;
      }

      // Извлекаем все фотографии
      final photoUrls = <String>[];
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final flightsDir = Directory('public/flights');
      if (!await flightsDir.exists()) {
        await flightsDir.create(recursive: true);
      }

      // Обрабатываем все части, которые содержат "photos" в имени
      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        // Проверяем, содержит ли поле имя "photos" (может быть "photos", "photos[]", "photos[0]" и т.д.)
        final isPhotoField = RegExp('name=["\']?photos').hasMatch(contentDisposition);
        if (!isPhotoField) continue;

        final photoData = part['data'] as List<int>?;
        if (photoData == null || photoData.isEmpty) continue;

        // Валидация размера (максимум 5MB)
        if (photoData.length > 5 * 1024 * 1024) {
          return Response.badRequest(
            body: jsonEncode({'error': 'File size exceeds 5MB limit'}),
            headers: jsonContentHeaders,
          );
        }

        // Определяем расширение
        String extension = 'jpg';
        final partContentType = part['content-type'] as String?;
        if (partContentType != null) {
          final partMediaType = MediaType.parse(partContentType);
          if (partMediaType.subtype == 'jpeg' || partMediaType.subtype == 'jpg') {
            extension = 'jpg';
          } else if (partMediaType.subtype == 'png') {
            extension = 'png';
          }
        }

        // Сохраняем фото с уникальным именем для каждого файла
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final index = photoUrls.length; // Индекс для уникальности каждого файла
        final fileName = '$flightId.$timestamp.$random.$index.$extension';
        final filePath = 'public/flights/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(photoData);

        photoUrls.add('flights/$fileName');
      }

      if (photoUrls.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No photos provided'}),
          headers: jsonContentHeaders,
        );
      }

      // Сохраняем фотографии в БД
      await _onTheWayRepository.uploadFlightPhotos(
        flightId: flightId,
        uploadedBy: userId,
        photoUrls: photoUrls,
      );

      // Получаем обновленный полет
      final updatedFlight = await _onTheWayRepository.fetchFlightById(flightId);
      if (updatedFlight == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch updated flight'}),
          headers: jsonContentHeaders,
        );
      }

      return Response.ok(jsonEncode(updatedFlight), headers: jsonContentHeaders);
    });
  }

  // Удаление фотографии полета
  @Route.delete('/api/flights/<id>/photos')
  @OpenApiRoute()
  Future<Response> deleteFlightPhoto(Request request) async {
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

      final userIdStr = tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final userId = int.parse(userIdStr);

      // Получаем ID полета
      final id = request.params['id'];
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Flight ID is required'}),
          headers: jsonContentHeaders,
        );
      }
      final flightId = int.parse(id);

      // Получаем photoUrl из query параметров или body
      final photoUrl = request.url.queryParameters['photo_url'];
      if (photoUrl == null || photoUrl.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Photo URL is required'}),
          headers: jsonContentHeaders,
        );
      }

      try {
        // Удаляем фотографию
        await _onTheWayRepository.deleteFlightPhoto(
          flightId: flightId,
          photoUrl: photoUrl,
          userId: userId,
        );

        // Получаем обновленный полет
        final updatedFlight = await _onTheWayRepository.fetchFlightById(flightId);
        if (updatedFlight == null) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to fetch updated flight'}),
            headers: jsonContentHeaders,
          );
        }

        return Response.ok(jsonEncode(updatedFlight), headers: jsonContentHeaders);
      } catch (e) {
        return Response.badRequest(
          body: jsonEncode({'error': e.toString()}),
          headers: jsonContentHeaders,
        );
      }
    });
  }

  // Вспомогательные методы для парсинга multipart (из profile_controller)
  int _indexOfBytes(List<int> haystack, List<int> needle, int start) {
    for (int i = start; i <= haystack.length - needle.length; i++) {
      bool match = true;
      for (int j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
    return -1;
  }

  Map<String, dynamic>? _parseMultipartPart(List<int> partBytes) {
    // Ищем разделитель между заголовками и телом
    final crlf = [13, 10, 13, 10]; // \r\n\r\n
    int headerEnd = -1;
    for (int i = 0; i <= partBytes.length - crlf.length; i++) {
      bool match = true;
      for (int j = 0; j < crlf.length; j++) {
        if (partBytes[i + j] != crlf[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        headerEnd = i + crlf.length;
        break;
      }
    }

    if (headerEnd == -1) return null;

    // Парсим заголовки
    final headerBytes = partBytes.sublist(0, headerEnd - crlf.length);
    final headers = <String, String>{};
    final headerLines = utf8.decode(headerBytes).split('\r\n');
    for (final line in headerLines) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim().toLowerCase();
        final value = line.substring(colonIndex + 1).trim();
        headers[key] = value;
      }
    }

    // Тело части
    final bodyBytes = partBytes.sublist(headerEnd);
    // Удаляем trailing CRLF если есть
    if (bodyBytes.length >= 2 && bodyBytes[bodyBytes.length - 2] == 13 && bodyBytes[bodyBytes.length - 1] == 10) {
      return {
        ...headers,
        'data': bodyBytes.sublist(0, bodyBytes.length - 2),
      };
    }

    return {
      ...headers,
      'data': bodyBytes,
    };
  }

  // ========== FLIGHT QUESTIONS ==========

  // Получение вопросов по полёту (доступно всем, включая неавторизованных)
  @Route.get('/api/flights/<flightId>/questions')
  @OpenApiRoute()
  Future<Response> getQuestionsByFlightId(Request request) async {
    return wrapResponse(() async {
      final flightId = request.params['flightId'];
      if (flightId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Flight ID is required'}), headers: jsonContentHeaders);
      }

      final questions = await _onTheWayRepository.fetchQuestionsByFlightId(int.parse(flightId));

      return Response.ok(jsonEncode(questions), headers: jsonContentHeaders);
    });
  }

  // Создание вопроса (авторизация опциональна - для неавторизованных authorId будет null)
  @Route.post('/api/flights/<flightId>/questions')
  @OpenApiRoute()
  Future<Response> createQuestion(Request request) async {
    return wrapResponse(() async {
      final flightId = request.params['flightId'];
      if (flightId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Flight ID is required'}), headers: jsonContentHeaders);
      }

      // Проверяем авторизацию (опционально)
      int? authorId;
      final authHeader = request.headers['Authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        final tokenService = getIt.get<TokenService>();

        final isValid = tokenService.validateToken(token);
        if (isValid) {
          final userId = tokenService.getUserIdFromToken(token);
          if (userId != null && userId.isNotEmpty) {
            authorId = int.parse(userId);
          }
        }
      }

      final body = await request.readAsString();
      final createRequest = CreateFlightQuestionRequest.fromJson(jsonDecode(body));

      final question = await _onTheWayRepository.createQuestion(
        flightId: int.parse(flightId),
        authorId: authorId,
        questionText: createRequest.questionText,
      );

      return Response.ok(jsonEncode(question), headers: jsonContentHeaders);
    });
  }

  // Обновление вопроса (автор может обновить вопрос, пилот может обновить ответ)
  @Route.put('/api/flights/<flightId>/questions/<id>')
  @OpenApiRoute()
  Future<Response> updateQuestion(Request request) async {
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
        return Response.badRequest(body: jsonEncode({'error': 'Question ID is required'}), headers: jsonContentHeaders);
      }

      final body = await request.readAsString();
      final updateRequest = UpdateFlightQuestionRequest.fromJson(jsonDecode(body));

      final question = await _onTheWayRepository.updateQuestion(
        questionId: int.parse(id),
        userId: int.parse(userId),
        questionText: updateRequest.questionText,
        answerText: updateRequest.answerText,
      );

      return Response.ok(jsonEncode(question), headers: jsonContentHeaders);
    });
  }

  // Удаление вопроса (автор или пилот)
  @Route.delete('/api/flights/<flightId>/questions/<id>')
  @OpenApiRoute()
  Future<Response> deleteQuestion(Request request) async {
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
        return Response.badRequest(body: jsonEncode({'error': 'Question ID is required'}), headers: jsonContentHeaders);
      }

      await _onTheWayRepository.deleteQuestion(questionId: int.parse(id), userId: int.parse(userId));

      return Response.ok(jsonEncode({'success': true}), headers: jsonContentHeaders);
    });
  }

  // Ответ на вопрос (только создатель полёта)
  @Route.post('/api/flights/<flightId>/questions/<id>/answer')
  @OpenApiRoute()
  Future<Response> answerQuestion(Request request) async {
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
        return Response.badRequest(
          body: jsonEncode({'error': 'Question ID is required'}),
          headers: jsonContentHeaders,
        );
      }

      final body = await request.readAsString();
      final answerRequest = AnswerFlightQuestionRequest.fromJson(jsonDecode(body));

      if (answerRequest.answerText.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Answer text is required'}),
          headers: jsonContentHeaders,
        );
      }

      try {
        final question = await _onTheWayRepository.answerQuestion(
          questionId: int.parse(id),
          userId: int.parse(userId),
          answerText: answerRequest.answerText.trim(),
        );

        return Response.ok(jsonEncode(question), headers: jsonContentHeaders);
      } catch (e) {
        if (e.toString().contains('Only the flight creator')) {
          return Response.forbidden(
            jsonEncode({'error': 'Only the flight creator can answer questions'}),
            headers: jsonContentHeaders,
          );
        }
        if (e.toString().contains('Question not found')) {
          return Response.notFound(
            jsonEncode({'error': 'Question not found'}),
            headers: jsonContentHeaders,
          );
        }
        rethrow;
      }
    });
  }
}
