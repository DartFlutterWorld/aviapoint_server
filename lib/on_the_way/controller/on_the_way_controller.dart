import 'dart:async';
import 'dart:convert';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/on_the_way/api/create_booking_request.dart';
import 'package:aviapoint_server/on_the_way/api/create_flight_request.dart';
import 'package:aviapoint_server/on_the_way/api/create_review_request.dart';
import 'package:aviapoint_server/on_the_way/repositories/on_the_way_repository.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
      }
      if (dateToStr != null && dateToStr.isNotEmpty) {
        dateTo = DateTime.tryParse(dateToStr);
      }

      final flights = await _onTheWayRepository.fetchFlights(departureAirport: departureAirport, arrivalAirport: arrivalAirport, dateFrom: dateFrom, dateTo: dateTo);

      return Response.ok(jsonEncode(flights), headers: jsonContentHeaders);
    });
  }

  // Получение полета по ID
  @Route.get('/api/flights/:id')
  @OpenApiRoute()
  Future<Response> getFlight(Request request, String id) async {
    return wrapResponse(() async {
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
  @Route.put('/api/flights/:id')
  @OpenApiRoute()
  Future<Response> updateFlight(Request request, String id) async {
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

      final updatedFlight = await _onTheWayRepository.updateFlight(
        id: flightId,
        departureAirport: updateData['departure_airport'] as String?,
        arrivalAirport: updateData['arrival_airport'] as String?,
        departureDate: updateData['departure_date'] != null ? DateTime.parse(updateData['departure_date'] as String) : null,
        availableSeats: updateData['available_seats'] as int?,
        pricePerSeat: (updateData['price_per_seat'] as num?)?.toDouble(),
        aircraftType: updateData['aircraft_type'] as String?,
        description: updateData['description'] as String?,
        status: updateData['status'] as String?,
      );

      return Response.ok(jsonEncode(updatedFlight), headers: jsonContentHeaders);
    });
  }

  // Удаление полета
  @Route.delete('/api/flights/:id')
  @OpenApiRoute()
  Future<Response> deleteFlight(Request request, String id) async {
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

      final flightId = int.parse(id);
      final flight = await _onTheWayRepository.fetchFlightById(flightId);

      if (flight == null) {
        return Response.notFound(jsonEncode({'error': 'Flight not found'}), headers: jsonContentHeaders);
      }

      // Проверка прав доступа (только владелец может удалять)
      if (flight.pilotId != int.parse(userId)) {
        return Response.forbidden(jsonEncode({'error': 'Forbidden: You can only delete your own flights'}), headers: jsonContentHeaders);
      }

      await _onTheWayRepository.deleteFlight(flightId);

      return Response.ok(jsonEncode({'message': 'Flight deleted successfully'}), headers: jsonContentHeaders);
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

      try {
        final booking = await _onTheWayRepository.createBooking(flightId: createRequest.flightId, passengerId: passengerId, seatsCount: createRequest.seatsCount);

        return Response.ok(jsonEncode(booking), headers: jsonContentHeaders);
      } catch (e) {
        return Response.badRequest(jsonEncode({'error': e.toString()}), headers: jsonContentHeaders);
      }
    });
  }

  // Подтверждение бронирования
  @Route.put('/api/bookings/:id/confirm')
  @OpenApiRoute()
  Future<Response> confirmBooking(Request request, String id) async {
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

      final bookingId = int.parse(id);
      // TODO: Проверить, что пользователь является пилотом этого полета

      final booking = await _onTheWayRepository.confirmBooking(bookingId);

      return Response.ok(jsonEncode(booking), headers: jsonContentHeaders);
    });
  }

  // Отмена бронирования
  @Route.put('/api/bookings/:id/cancel')
  @OpenApiRoute()
  Future<Response> cancelBooking(Request request, String id) async {
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

      final bookingId = int.parse(id);
      // TODO: Проверить, что пользователь является владельцем бронирования или пилотом

      final booking = await _onTheWayRepository.cancelBooking(bookingId);

      return Response.ok(jsonEncode(booking), headers: jsonContentHeaders);
    });
  }

  // Получение отзывов о пользователе
  @Route.get('/api/reviews/:userId')
  @OpenApiRoute()
  Future<Response> getReviews(Request request, String userId) async {
    return wrapResponse(() async {
      final reviews = await _onTheWayRepository.fetchReviews(int.parse(userId));

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
      );

      return Response.ok(jsonEncode(review), headers: jsonContentHeaders);
    });
  }
}
