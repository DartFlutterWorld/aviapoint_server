import 'package:aviapoint_server/on_the_way/data/model/booking_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/flight_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/review_model.dart';
import 'package:postgres/postgres.dart';
import 'package:aviapoint_server/logger/logger.dart';

class OnTheWayRepository {
  final Connection _connection;

  OnTheWayRepository({required Connection connection}) : _connection = connection;

  // Получение списка полетов с фильтрами
  Future<List<FlightModel>> fetchFlights({String? departureAirport, String? arrivalAirport, DateTime? dateFrom, DateTime? dateTo}) async {
    var query = 'SELECT * FROM flights WHERE status = \'active\'';
    final parameters = <String, dynamic>{};

    if (departureAirport != null && departureAirport.isNotEmpty) {
      query += ' AND departure_airport ILIKE @departure_airport';
      parameters['departure_airport'] = '%$departureAirport%';
    }

    if (arrivalAirport != null && arrivalAirport.isNotEmpty) {
      query += ' AND arrival_airport ILIKE @arrival_airport';
      parameters['arrival_airport'] = '%$arrivalAirport%';
    }

    if (dateFrom != null) {
      query += ' AND departure_date >= @date_from';
      parameters['date_from'] = dateFrom;
    }

    if (dateTo != null) {
      query += ' AND departure_date <= @date_to';
      parameters['date_to'] = dateTo;
    }

    query += ' ORDER BY departure_date ASC';

    final result = await _connection.execute(Sql.named(query), parameters: parameters);

    return result.map((row) {
      final map = row.toColumnMap();
      return FlightModel.fromJson(map);
    }).toList();
  }

  // Получение полета по ID
  Future<FlightModel?> fetchFlightById(int id) async {
    final result = await _connection.execute(Sql.named('SELECT * FROM flights WHERE id = @id'), parameters: {'id': id});

    if (result.isEmpty) {
      return null;
    }

    final map = result.first.toColumnMap();
    return FlightModel.fromJson(map);
  }

  // Создание полета
  Future<FlightModel> createFlight({
    required int pilotId,
    required String departureAirport,
    required String arrivalAirport,
    required DateTime departureDate,
    required int availableSeats,
    required double pricePerSeat,
    String? aircraftType,
    String? description,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO flights (
          pilot_id, departure_airport, arrival_airport, departure_date,
          available_seats, price_per_seat, aircraft_type, description
        ) VALUES (
          @pilot_id, @departure_airport, @arrival_airport, @departure_date,
          @available_seats, @price_per_seat, @aircraft_type, @description
        ) RETURNING *
      '''),
      parameters: {
        'pilot_id': pilotId,
        'departure_airport': departureAirport,
        'arrival_airport': arrivalAirport,
        'departure_date': departureDate,
        'available_seats': availableSeats,
        'price_per_seat': pricePerSeat,
        'aircraft_type': aircraftType,
        'description': description,
      },
    );

    final map = result.first.toColumnMap();
    return FlightModel.fromJson(map);
  }

  // Обновление полета
  Future<FlightModel> updateFlight({
    required int id,
    String? departureAirport,
    String? arrivalAirport,
    DateTime? departureDate,
    int? availableSeats,
    double? pricePerSeat,
    String? aircraftType,
    String? description,
    String? status,
  }) async {
    final updates = <String>[];
    final parameters = <String, dynamic>{'id': id};

    if (departureAirport != null) {
      updates.add('departure_airport = @departure_airport');
      parameters['departure_airport'] = departureAirport;
    }
    if (arrivalAirport != null) {
      updates.add('arrival_airport = @arrival_airport');
      parameters['arrival_airport'] = arrivalAirport;
    }
    if (departureDate != null) {
      updates.add('departure_date = @departure_date');
      parameters['departure_date'] = departureDate;
    }
    if (availableSeats != null) {
      updates.add('available_seats = @available_seats');
      parameters['available_seats'] = availableSeats;
    }
    if (pricePerSeat != null) {
      updates.add('price_per_seat = @price_per_seat');
      parameters['price_per_seat'] = pricePerSeat;
    }
    if (aircraftType != null) {
      updates.add('aircraft_type = @aircraft_type');
      parameters['aircraft_type'] = aircraftType;
    }
    if (description != null) {
      updates.add('description = @description');
      parameters['description'] = description;
    }
    if (status != null) {
      updates.add('status = @status');
      parameters['status'] = status;
    }

    if (updates.isEmpty) {
      return await fetchFlightById(id)!;
    }

    final query = 'UPDATE flights SET ${updates.join(', ')} WHERE id = @id RETURNING *';
    final result = await _connection.execute(Sql.named(query), parameters: parameters);

    final map = result.first.toColumnMap();
    return FlightModel.fromJson(map);
  }

  // Удаление полета
  Future<void> deleteFlight(int id) async {
    await _connection.execute(Sql.named('DELETE FROM flights WHERE id = @id'), parameters: {'id': id});
  }

  // Получение бронирований пользователя
  Future<List<BookingModel>> fetchBookings({int? userId}) async {
    var query = 'SELECT * FROM bookings';
    final parameters = <String, dynamic>{};

    if (userId != null) {
      query += ' WHERE passenger_id = @user_id';
      parameters['user_id'] = userId;
    }

    query += ' ORDER BY created_at DESC';

    final result = await _connection.execute(Sql.named(query), parameters: parameters);

    return result.map((row) {
      final map = row.toColumnMap();
      return BookingModel.fromJson(map);
    }).toList();
  }

  // Создание бронирования
  Future<BookingModel> createBooking({required int flightId, required int passengerId, required int seatsCount}) async {
    // Проверяем доступность мест
    final flight = await fetchFlightById(flightId);
    if (flight == null) {
      throw Exception('Flight not found');
    }

    // Подсчитываем уже забронированные места
    final bookedResult = await _connection.execute(
      Sql.named('''
        SELECT COALESCE(SUM(seats_count), 0) as booked_seats
        FROM bookings
        WHERE flight_id = @flight_id AND status IN ('pending', 'confirmed')
      '''),
      parameters: {'flight_id': flightId},
    );

    final bookedSeats = bookedResult.first[0] as int;
    final availableSeats = flight.availableSeats - bookedSeats;

    if (seatsCount > availableSeats) {
      throw Exception('Not enough available seats');
    }

    final totalPrice = seatsCount * flight.pricePerSeat;

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO bookings (flight_id, passenger_id, seats_count, total_price)
        VALUES (@flight_id, @passenger_id, @seats_count, @total_price)
        RETURNING *
      '''),
      parameters: {'flight_id': flightId, 'passenger_id': passengerId, 'seats_count': seatsCount, 'total_price': totalPrice},
    );

    final map = result.first.toColumnMap();
    return BookingModel.fromJson(map);
  }

  // Подтверждение бронирования
  Future<BookingModel> confirmBooking(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE bookings
        SET status = 'confirmed'
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': id},
    );

    final map = result.first.toColumnMap();
    return BookingModel.fromJson(map);
  }

  // Отмена бронирования
  Future<BookingModel> cancelBooking(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE bookings
        SET status = 'cancelled'
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': id},
    );

    final map = result.first.toColumnMap();
    return BookingModel.fromJson(map);
  }

  // Получение отзывов о пользователе
  Future<List<ReviewModel>> fetchReviews(int userId) async {
    final result = await _connection.execute(Sql.named('SELECT * FROM reviews WHERE reviewed_id = @user_id ORDER BY created_at DESC'), parameters: {'user_id': userId});

    return result.map((row) {
      final map = row.toColumnMap();
      return ReviewModel.fromJson(map);
    }).toList();
  }

  // Создание отзыва
  Future<ReviewModel> createReview({required int bookingId, required int reviewerId, required int reviewedId, required int rating, String? comment}) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO reviews (booking_id, reviewer_id, reviewed_id, rating, comment)
        VALUES (@booking_id, @reviewer_id, @reviewed_id, @rating, @comment)
        RETURNING *
      '''),
      parameters: {'booking_id': bookingId, 'reviewer_id': reviewerId, 'reviewed_id': reviewedId, 'rating': rating, 'comment': comment},
    );

    final map = result.first.toColumnMap();
    return ReviewModel.fromJson(map);
  }
}
