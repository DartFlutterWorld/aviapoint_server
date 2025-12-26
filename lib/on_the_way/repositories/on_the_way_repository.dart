import 'dart:io';
import 'package:aviapoint_server/on_the_way/data/model/booking_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/flight_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/review_model.dart';
import 'package:postgres/postgres.dart';

class OnTheWayRepository {
  final Connection _connection;

  OnTheWayRepository({required Connection connection}) : _connection = connection;

  // Получение списка полетов с фильтрами и вычислением свободных мест на лету
  Future<List<FlightModel>> fetchFlights({String? departureAirport, String? arrivalAirport, DateTime? dateFrom, DateTime? dateTo, int? pilotId}) async {
    var query = '''
      SELECT 
        f.id,
        f.pilot_id,
        f.departure_airport,
        f.arrival_airport,
        f.departure_date,
        f.available_seats AS total_seats,
        COALESCE(
          f.available_seats - COALESCE(booked.total_booked, 0),
          f.available_seats
        ) AS available_seats,
        f.price_per_seat,
        f.aircraft_type,
        f.description,
        f.status,
        f.created_at,
        f.updated_at,
        p.first_name AS pilot_first_name,
        p.last_name AS pilot_last_name,
        p.avatar_url AS pilot_avatar_url,
        COALESCE((
          SELECT AVG(rating)::numeric
          FROM reviews
          WHERE reviewed_id = p.id 
            AND reply_to_review_id IS NULL 
            AND rating IS NOT NULL
        ), 0) AS pilot_average_rating,
        COALESCE((
          SELECT json_agg(photo_url ORDER BY created_at)
          FROM flight_photos
          WHERE flight_id = f.id
        ), '[]'::json) AS photos,
        -- Информация об аэропорте отправления
        dep_airport.name AS departure_airport_name,
        dep_airport.city AS departure_airport_city,
        dep_airport.region AS departure_airport_region,
        dep_airport.type AS departure_airport_type,
        dep_airport.ident_ru AS departure_airport_ident_ru,
        -- Информация об аэропорте прибытия
        arr_airport.name AS arrival_airport_name,
        arr_airport.city AS arrival_airport_city,
        arr_airport.region AS arrival_airport_region,
        arr_airport.type AS arrival_airport_type,
        arr_airport.ident_ru AS arrival_airport_ident_ru
      FROM flights f
      LEFT JOIN profiles p ON f.pilot_id = p.id
      LEFT JOIN airports dep_airport ON f.departure_airport = dep_airport.ident
      LEFT JOIN airports arr_airport ON f.arrival_airport = arr_airport.ident
      LEFT JOIN (
        SELECT 
          flight_id,
          SUM(seats_count) AS total_booked
        FROM bookings
        WHERE status IN ('pending', 'confirmed')
        GROUP BY flight_id
      ) booked ON booked.flight_id = f.id
      WHERE 1=1
    ''';
    final parameters = <String, dynamic>{};

    if (departureAirport != null && departureAirport.isNotEmpty) {
      query += ' AND f.departure_airport = @departure_airport';
      parameters['departure_airport'] = departureAirport;
    }

    if (arrivalAirport != null && arrivalAirport.isNotEmpty) {
      query += ' AND f.arrival_airport = @arrival_airport';
      parameters['arrival_airport'] = arrivalAirport;
    }

    if (dateFrom != null) {
      // Если dateFrom - это только дата без времени, устанавливаем время на начало дня (00:00:00)
      final dateFromWithTime = dateFrom.hour == 0 && dateFrom.minute == 0 && dateFrom.second == 0 ? dateFrom : DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
      query += ' AND f.departure_date >= @date_from';
      parameters['date_from'] = dateFromWithTime;
      print('🔵 [OnTheWayRepository] fetchFlights: dateFrom = $dateFromWithTime');
    }

    if (dateTo != null) {
      // Если dateTo - это только дата без времени, устанавливаем время на конец дня (23:59:59)
      final dateToWithTime = dateTo.hour == 0 && dateTo.minute == 0 && dateTo.second == 0 ? DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59) : dateTo;
      query += ' AND f.departure_date <= @date_to';
      parameters['date_to'] = dateToWithTime;
      print('🔵 [OnTheWayRepository] fetchFlights: dateTo = $dateToWithTime');
    }

    if (pilotId != null) {
      query += ' AND f.pilot_id = @pilot_id';
      parameters['pilot_id'] = pilotId;
    }

    // Сортировка: ближайшие полеты по дате и времени первыми (независимо от статуса)
    // Сначала будущие полеты (departure_date >= NOW()), затем прошедшие
    query += '''
      ORDER BY 
        CASE WHEN f.departure_date >= NOW() THEN 0 ELSE 1 END ASC,
        f.departure_date ASC
    ''';

    print('🔵 [OnTheWayRepository] fetchFlights SQL query: $query');
    print('🔵 [OnTheWayRepository] fetchFlights parameters: $parameters');

    final result = await _connection.execute(Sql.named(query), parameters: parameters);

    final flights = result.map((row) {
      final map = row.toColumnMap();
      return FlightModel.fromJson(map);
    }).toList();

    print('🔵 [OnTheWayRepository] fetchFlights returned ${flights.length} flights');
    for (var flight in flights) {
      print('🔵 [OnTheWayRepository] Flight id=${flight.id}, status=${flight.status}');
    }

    return flights;
  }

  // Получение полета по ID с вычислением свободных мест на лету
  Future<FlightModel?> fetchFlightById(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          f.id,
          f.pilot_id,
          f.departure_airport,
          f.arrival_airport,
          f.departure_date,
          f.available_seats AS total_seats,
          COALESCE(
            f.available_seats - (
              SELECT COALESCE(SUM(b.seats_count), 0)
              FROM bookings b
              WHERE b.flight_id = f.id
                AND b.status IN ('pending', 'confirmed')
            ),
            f.available_seats
          ) AS available_seats,
          f.price_per_seat,
          f.aircraft_type,
          f.description,
          f.status,
          f.created_at,
          f.updated_at,
          p.first_name AS pilot_first_name,
          p.last_name AS pilot_last_name,
          p.avatar_url AS pilot_avatar_url,
          COALESCE((
            SELECT AVG(rating)::numeric
            FROM reviews
            WHERE reviewed_id = p.id 
              AND reply_to_review_id IS NULL 
              AND rating IS NOT NULL
          ), 0) AS pilot_average_rating,
          COALESCE((
            SELECT json_agg(photo_url ORDER BY created_at)
            FROM flight_photos
            WHERE flight_id = f.id
          ), '[]'::json) AS photos,
          -- Информация об аэропорте отправления
          dep_airport.name AS departure_airport_name,
          dep_airport.city AS departure_airport_city,
          dep_airport.region AS departure_airport_region,
          dep_airport.type AS departure_airport_type,
          dep_airport.ident_ru AS departure_airport_ident_ru,
          -- Информация об аэропорте прибытия
          arr_airport.name AS arrival_airport_name,
          arr_airport.city AS arrival_airport_city,
          arr_airport.region AS arrival_airport_region,
          arr_airport.type AS arrival_airport_type,
          arr_airport.ident_ru AS arrival_airport_ident_ru
        FROM flights f
        LEFT JOIN profiles p ON f.pilot_id = p.id
        LEFT JOIN airports dep_airport ON f.departure_airport = dep_airport.ident
        LEFT JOIN airports arr_airport ON f.arrival_airport = arr_airport.ident
        WHERE f.id = @id
      '''),
      parameters: {'id': id},
    );

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
    // ВАЖНО: В БД поле price_per_seat имеет тип INTEGER, поэтому округляем до int
    final priceAsInt = pricePerSeat.round().toInt();

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO flights (
          pilot_id, departure_airport, arrival_airport, departure_date,
          available_seats, price_per_seat, aircraft_type, description
        ) VALUES (
          @pilot_id, @departure_airport, @arrival_airport, @departure_date,
          @available_seats, @price_per_seat, @aircraft_type, @description
        ) RETURNING 
          id, pilot_id, departure_airport, arrival_airport, departure_date,
          available_seats AS total_seats,
          available_seats,
          price_per_seat, aircraft_type, description, status, created_at, updated_at
      '''),
      parameters: {
        'pilot_id': pilotId,
        'departure_airport': departureAirport,
        'arrival_airport': arrivalAirport,
        'departure_date': departureDate,
        'available_seats': availableSeats,
        'price_per_seat': priceAsInt, // Передаем как int
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
      // ВАЖНО: В БД поле price_per_seat имеет тип INTEGER, поэтому округляем до int
      updates.add('price_per_seat = @price_per_seat');
      parameters['price_per_seat'] = pricePerSeat.round().toInt();
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
      final existingFlight = await fetchFlightById(id);
      if (existingFlight == null) {
        throw Exception('Flight not found');
      }
      return existingFlight;
    }

    final query = 'UPDATE flights SET ${updates.join(', ')} WHERE id = @id RETURNING *';
    final result = await _connection.execute(Sql.named(query), parameters: parameters);

    final map = result.first.toColumnMap();
    return FlightModel.fromJson(map);
  }

  // Отмена полета (изменение статуса на 'cancelled' вместо физического удаления)
  Future<FlightModel> deleteFlight(int id) async {
    print('🔵 [OnTheWayRepository] deleteFlight: Отмена полета id=$id');

    // Сначала отменяем все активные бронирования на этот полет (pending и confirmed)
    final bookingsUpdateResult = await _connection.execute(
      Sql.named('UPDATE bookings SET status = @cancelled_status WHERE flight_id = @flight_id AND status != @cancelled_status'),
      parameters: {'flight_id': id, 'cancelled_status': 'cancelled'},
    );
    print('🔵 [OnTheWayRepository] deleteFlight: Отменено бронирований: ${bookingsUpdateResult.length}');

    // Затем меняем статус полета на 'cancelled'
    final result = await _connection.execute(Sql.named('UPDATE flights SET status = @status WHERE id = @id RETURNING *'), parameters: {'id': id, 'status': 'cancelled'});

    if (result.isEmpty) {
      throw Exception('Flight not found or could not be cancelled');
    }

    final map = result.first.toColumnMap();
    final cancelledFlight = FlightModel.fromJson(map);
    print('🔵 [OnTheWayRepository] deleteFlight: Статус полета изменен на: ${cancelledFlight.status}');

    return cancelledFlight;
  }

  // Получение бронирований пользователя
  Future<List<BookingModel>> fetchBookings({int? userId}) async {
    var query = '''
      SELECT 
        b.id,
        b.flight_id,
        b.passenger_id,
        b.seats_count,
        b.total_price,
        b.status,
        b.created_at,
        b.updated_at,
        p.first_name AS passenger_first_name,
        p.last_name AS passenger_last_name,
        p.avatar_url AS passenger_avatar_url,
        COALESCE((
          SELECT AVG(rating)::numeric
          FROM reviews
          WHERE reviewed_id = p.id 
            AND reply_to_review_id IS NULL 
            AND rating IS NOT NULL
        ), 0) AS passenger_average_rating
      FROM bookings b
      LEFT JOIN profiles p ON b.passenger_id = p.id
    ''';
    final parameters = <String, dynamic>{};

    if (userId != null) {
      query += ' WHERE b.passenger_id = @user_id';
      parameters['user_id'] = userId;
    }

    query += ' ORDER BY b.created_at DESC';

    final result = await _connection.execute(Sql.named(query), parameters: parameters);

    return result.map((row) {
      final map = row.toColumnMap();
      return BookingModel.fromJson(map);
    }).toList();
  }

  // Получение бронирований по flight_id (для пилота)
  Future<List<BookingModel>> fetchBookingsByFlightId(int flightId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          b.id,
          b.flight_id,
          b.passenger_id,
          b.seats_count,
          b.total_price,
          b.status,
          b.created_at,
          b.updated_at,
          p.first_name AS passenger_first_name,
          p.last_name AS passenger_last_name,
          p.avatar_url AS passenger_avatar_url,
          COALESCE((
            SELECT AVG(rating)::numeric
            FROM reviews
            WHERE reviewed_id = p.id 
              AND reply_to_review_id IS NULL 
              AND rating IS NOT NULL
          ), 0) AS passenger_average_rating
        FROM bookings b
        LEFT JOIN profiles p ON b.passenger_id = p.id
        WHERE b.flight_id = @flight_id
        ORDER BY b.created_at DESC
      '''),
      parameters: {'flight_id': flightId},
    );

    return result.map((row) {
      final map = row.toColumnMap();
      return BookingModel.fromJson(map);
    }).toList();
  }

  // Создание бронирования
  Future<BookingModel> createBooking({required int flightId, required int passengerId, required int seatsCount}) async {
    // Проверяем доступность мест (используем транзакцию с блокировкой)
    final flightResult = await _connection.execute(Sql.named('SELECT * FROM flights WHERE id = @flight_id FOR UPDATE'), parameters: {'flight_id': flightId});

    if (flightResult.isEmpty) {
      throw Exception('Flight not found');
    }

    final flightMap = flightResult.first.toColumnMap();
    final flight = FlightModel.fromJson(flightMap);

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

    final totalPrice = (seatsCount * flight.pricePerSeat).round(); // Округляем до целого числа
    print('🔵 [OnTheWayRepository] createBooking totalPrice: $totalPrice (type: ${totalPrice.runtimeType})');

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO bookings (flight_id, passenger_id, seats_count, total_price)
        VALUES (@flight_id, @passenger_id, @seats_count, @total_price)
        RETURNING *
      '''),
      parameters: {
        'flight_id': flightId,
        'passenger_id': passengerId,
        'seats_count': seatsCount,
        'total_price': totalPrice, // Передаем как int
      },
    );

    final map = result.first.toColumnMap();
    print('🔵 [OnTheWayRepository] createBooking raw map from DB: $map');
    map.forEach((key, value) {
      print('🔵 [OnTheWayRepository] createBooking DB field "$key": value=$value, type=${value.runtimeType}');
    });

    // Получаем данные пассажира через JOIN
    final passengerResult = await _connection.execute(
      Sql.named('''
        SELECT 
          p.first_name AS passenger_first_name,
          p.last_name AS passenger_last_name,
          p.avatar_url AS passenger_avatar_url,
          COALESCE((
            SELECT AVG(rating)::numeric
            FROM reviews
            WHERE reviewed_id = p.id 
              AND reply_to_review_id IS NULL 
              AND rating IS NOT NULL
          ), 0) AS passenger_average_rating
        FROM profiles p
        WHERE p.id = @passenger_id
      '''),
      parameters: {'passenger_id': passengerId},
    );

    if (passengerResult.isNotEmpty) {
      final passengerMap = passengerResult.first.toColumnMap();
      map.addAll(passengerMap);
    }

    final booking = BookingModel.fromJson(map);
    print('🔵 [OnTheWayRepository] createBooking parsed BookingModel: ${booking.toJson()}');
    return booking;
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

    if (result.isEmpty) {
      throw Exception('Booking not found');
    }

    // Получаем данные пассажира через JOIN
    final bookingMap = result.first.toColumnMap();
    final passengerId = bookingMap['passenger_id'] as int;

    final passengerResult = await _connection.execute(
      Sql.named('''
        SELECT 
          p.first_name AS passenger_first_name,
          p.last_name AS passenger_last_name,
          p.avatar_url AS passenger_avatar_url,
          COALESCE((
            SELECT AVG(rating)::numeric
            FROM reviews
            WHERE reviewed_id = p.id 
              AND reply_to_review_id IS NULL 
              AND rating IS NOT NULL
          ), 0) AS passenger_average_rating
        FROM profiles p
        WHERE p.id = @passenger_id
      '''),
      parameters: {'passenger_id': passengerId},
    );

    if (passengerResult.isNotEmpty) {
      final passengerMap = passengerResult.first.toColumnMap();
      bookingMap.addAll(passengerMap);
    }

    return BookingModel.fromJson(bookingMap);
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

    if (result.isEmpty) {
      throw Exception('Booking not found');
    }

    // Получаем данные пассажира через JOIN
    final bookingMap = result.first.toColumnMap();
    final passengerId = bookingMap['passenger_id'] as int;

    final passengerResult = await _connection.execute(
      Sql.named('''
        SELECT 
          p.first_name AS passenger_first_name,
          p.last_name AS passenger_last_name,
          p.avatar_url AS passenger_avatar_url,
          COALESCE((
            SELECT AVG(rating)::numeric
            FROM reviews
            WHERE reviewed_id = p.id 
              AND reply_to_review_id IS NULL 
              AND rating IS NOT NULL
          ), 0) AS passenger_average_rating
        FROM profiles p
        WHERE p.id = @passenger_id
      '''),
      parameters: {'passenger_id': passengerId},
    );

    if (passengerResult.isNotEmpty) {
      final passengerMap = passengerResult.first.toColumnMap();
      bookingMap.addAll(passengerMap);
    }

    return BookingModel.fromJson(bookingMap);
  }

  // Получение отзывов о пользователе
  Future<List<ReviewModel>> fetchReviews(int userId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          r.*,
          b.flight_id,
          p.first_name as reviewer_first_name,
          p.last_name as reviewer_last_name,
          p.avatar_url as reviewer_avatar_url
        FROM reviews r
        INNER JOIN bookings b ON r.booking_id = b.id
        INNER JOIN profiles p ON r.reviewer_id = p.id
        WHERE r.reviewed_id = @user_id
        ORDER BY r.created_at DESC
      '''),
      parameters: {'user_id': userId},
    );

    return result.map((row) {
      final map = row.toColumnMap();
      return ReviewModel.fromJson(map);
    }).toList();
  }

  // Получение отзывов по полёту
  Future<List<ReviewModel>> fetchReviewsByFlightId(int flightId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          r.*,
          b.flight_id,
          p.first_name as reviewer_first_name,
          p.last_name as reviewer_last_name,
          p.avatar_url as reviewer_avatar_url
        FROM reviews r
        INNER JOIN bookings b ON r.booking_id = b.id
        INNER JOIN profiles p ON r.reviewer_id = p.id
        WHERE b.flight_id = @flight_id
        ORDER BY r.created_at DESC
      '''),
      parameters: {'flight_id': flightId},
    );

    return result.map((row) {
      final map = row.toColumnMap();
      return ReviewModel.fromJson(map);
    }).toList();
  }

  // Проверка, можно ли оставить отзыв
  Future<bool> canCreateReview({required int bookingId, required int reviewerId}) async {
    // Проверяем, что бронирование существует и подтверждено, и получаем информацию о полёте
    final bookingResult = await _connection.execute(
      Sql.named('''
        SELECT b.*, f.status as flight_status, f.pilot_id
        FROM bookings b
        INNER JOIN flights f ON b.flight_id = f.id
        WHERE b.id = @booking_id AND b.status = 'confirmed'
      '''),
      parameters: {'booking_id': bookingId},
    );

    if (bookingResult.isEmpty) {
      print('❌ [canCreateReview] Бронирование не найдено или не подтверждено: bookingId=$bookingId');
      return false;
    }

    final bookingMap = bookingResult.first.toColumnMap();
    final flightStatus = bookingMap['flight_status'] as String?;
    final pilotId = bookingMap['pilot_id'] as int;
    final passengerId = bookingMap['passenger_id'] as int;

    print('🔍 [canCreateReview] bookingId=$bookingId, reviewerId=$reviewerId, pilotId=$pilotId, passengerId=$passengerId, flightStatus=$flightStatus');

    // Полёт должен быть завершён
    if (flightStatus != 'completed') {
      print('❌ [canCreateReview] Полёт не завершён: status=$flightStatus');
      return false;
    }

    // Проверяем, что reviewerId либо пассажир этого бронирования, либо пилот полёта
    if (reviewerId != passengerId && reviewerId != pilotId) {
      print('❌ [canCreateReview] Пользователь не имеет права оставить отзыв: reviewerId=$reviewerId, passengerId=$passengerId, pilotId=$pilotId');
      return false;
    }

    // Проверяем, что отзыв ещё не оставлен (если был удалён, можно создать новый)
    // Для пилота проверяем по bookingId и reviewerId (пилот может оставить отзыв каждому пассажиру отдельно)
    // Для пассажира проверяем по bookingId и reviewerId (пассажир может оставить только один отзыв пилоту)
    final reviewResult = await _connection.execute(
      Sql.named('SELECT COUNT(*) as count FROM reviews WHERE booking_id = @booking_id AND reviewer_id = @reviewer_id AND reply_to_review_id IS NULL'),
      parameters: {'booking_id': bookingId, 'reviewer_id': reviewerId},
    );

    final reviewCount = reviewResult.first[0] as int;
    print('🔍 [canCreateReview] Существующих отзывов: $reviewCount');

    if (reviewCount > 0) {
      print('❌ [canCreateReview] Отзыв уже существует для этого бронирования и рецензента');
      return false;
    }

    print('✅ [canCreateReview] Можно создать отзыв');
    return true;
  }

  // Создание отзыва
  Future<ReviewModel> createReview({required int bookingId, required int reviewerId, required int reviewedId, int? rating, String? comment, int? replyToReviewId}) async {
    // Если это ответ на отзыв, не проверяем ограничение на количество
    if (replyToReviewId == null) {
      // Для основных отзывов rating обязателен
      if (rating == null) {
        throw Exception('Rating is required for main reviews');
      }

      // Проверяем, что rating в допустимом диапазоне (1-5)
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      // Для основных отзывов проверяем, можно ли оставить отзыв
      final canCreate = await canCreateReview(bookingId: bookingId, reviewerId: reviewerId);
      if (!canCreate) {
        // Получаем детали для более информативного сообщения об ошибке
        final bookingResult = await _connection.execute(
          Sql.named('''
            SELECT b.*, f.status as flight_status, f.pilot_id
            FROM bookings b
            INNER JOIN flights f ON b.flight_id = f.id
            WHERE b.id = @booking_id
          '''),
          parameters: {'booking_id': bookingId},
        );

        if (bookingResult.isEmpty) {
          throw Exception('Booking not found');
        }

        final bookingMap = bookingResult.first.toColumnMap();
        final flightStatus = bookingMap['flight_status'] as String?;
        final bookingStatus = bookingMap['status'] as String?;

        // Проверяем существующие отзывы
        final existingReviewResult = await _connection.execute(
          Sql.named('SELECT COUNT(*) as count FROM reviews WHERE booking_id = @booking_id AND reviewer_id = @reviewer_id AND reply_to_review_id IS NULL'),
          parameters: {'booking_id': bookingId, 'reviewer_id': reviewerId},
        );
        final existingReviewCount = existingReviewResult.first[0] as int;

        String errorMessage = 'Cannot create review: ';
        if (bookingStatus != 'confirmed') {
          errorMessage += 'booking is not confirmed (status: $bookingStatus)';
        } else if (flightStatus != 'completed') {
          errorMessage += 'flight is not completed (status: $flightStatus)';
        } else if (existingReviewCount > 0) {
          errorMessage += 'review already exists for this booking';
        } else {
          errorMessage += 'unknown error';
        }

        throw Exception(errorMessage);
      }
    } else {
      // Для ответов на отзывы проверяем только, что полёт завершён и пользователь имеет право отвечать
      final bookingResult = await _connection.execute(
        Sql.named('''
          SELECT b.*, f.status as flight_status, f.pilot_id
          FROM bookings b
          INNER JOIN flights f ON b.flight_id = f.id
          WHERE b.id = @booking_id AND b.status = 'confirmed'
        '''),
        parameters: {'booking_id': bookingId},
      );

      if (bookingResult.isEmpty) {
        throw Exception('Booking not found or not confirmed');
      }

      final bookingMap = bookingResult.first.toColumnMap();
      final flightStatus = bookingMap['flight_status'] as String?;
      final pilotId = bookingMap['pilot_id'] as int;
      final passengerId = bookingMap['passenger_id'] as int;

      // Полёт должен быть завершён
      if (flightStatus != 'completed') {
        throw Exception('Flight must be completed to reply to review');
      }

      // Проверяем, что reviewerId либо пассажир этого бронирования, либо пилот полёта
      if (reviewerId != passengerId && reviewerId != pilotId) {
        throw Exception('You do not have permission to reply to this review');
      }

      // Проверяем, что отзыв, на который отвечаем, существует
      final parentReviewResult = await _connection.execute(Sql.named('SELECT id FROM reviews WHERE id = @review_id'), parameters: {'review_id': replyToReviewId});

      if (parentReviewResult.isEmpty) {
        throw Exception('Parent review not found');
      }
    }

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO reviews (booking_id, reviewer_id, reviewed_id, rating, comment, reply_to_review_id)
        VALUES (@booking_id, @reviewer_id, @reviewed_id, @rating, @comment, @reply_to_review_id)
        RETURNING *
      '''),
      parameters: {'booking_id': bookingId, 'reviewer_id': reviewerId, 'reviewed_id': reviewedId, 'rating': rating, 'comment': comment, 'reply_to_review_id': replyToReviewId},
    );

    final map = result.first.toColumnMap();
    return ReviewModel.fromJson(map);
  }

  // Обновление отзыва (только владельцем)
  Future<ReviewModel> updateReview({required int reviewId, required int userId, int? rating, String? comment}) async {
    // Проверяем, что отзыв принадлежит пользователю и получаем информацию о типе отзыва
    final reviewResult = await _connection.execute(Sql.named('SELECT reviewer_id, reply_to_review_id FROM reviews WHERE id = @review_id'), parameters: {'review_id': reviewId});

    if (reviewResult.isEmpty) {
      throw Exception('Review not found');
    }

    final reviewData = reviewResult.first.toColumnMap();
    final reviewerId = reviewData['reviewer_id'] as int;
    final replyToReviewId = reviewData['reply_to_review_id'] as int?;

    if (reviewerId != userId) {
      throw Exception('You can only edit your own reviews');
    }

    // Для основных отзывов (не ответов) rating обязателен
    if (replyToReviewId == null && rating == null) {
      throw Exception('Rating is required for main reviews');
    }

    // Если rating указан, проверяем диапазон (1-5)
    if (rating != null && (rating < 1 || rating > 5)) {
      throw Exception('Rating must be between 1 and 5');
    }

    // Для ответов на отзывы rating должен быть NULL
    if (replyToReviewId != null && rating != null) {
      throw Exception('Rating must be null for replies to reviews');
    }

    // Обновляем отзыв
    final result = await _connection.execute(
      Sql.named('''
        UPDATE reviews 
        SET rating = @rating, comment = @comment
        WHERE id = @review_id
        RETURNING *
      '''),
      parameters: {'review_id': reviewId, 'rating': rating, 'comment': comment},
    );

    if (result.isEmpty) {
      throw Exception('Failed to update review');
    }

    final map = result.first.toColumnMap();
    return ReviewModel.fromJson(map);
  }

  // Удаление отзыва (только владельцем)
  Future<bool> deleteReview({required int reviewId, required int userId}) async {
    // Проверяем, что отзыв принадлежит пользователю
    final reviewResult = await _connection.execute(Sql.named('SELECT reviewer_id FROM reviews WHERE id = @review_id'), parameters: {'review_id': reviewId});

    if (reviewResult.isEmpty) {
      throw Exception('Review not found');
    }

    final reviewerId = reviewResult.first[0] as int;
    if (reviewerId != userId) {
      throw Exception('You can only delete your own reviews');
    }

    // Удаляем отзыв и все ответы на него
    await _connection.execute(Sql.named('DELETE FROM reviews WHERE id = @review_id OR reply_to_review_id = @review_id'), parameters: {'review_id': reviewId});

    return true;
  }

  // Получение информации о полёте для уведомления
  Future<Map<String, dynamic>> getFlightInfoForNotification(int bookingId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          f.id as flight_id,
          f.pilot_id,
          f.departure_airport,
          f.arrival_airport,
          f.departure_date,
          p1.name as pilot_name,
          p2.name as passenger_name,
          b.passenger_id
        FROM bookings b
        INNER JOIN flights f ON b.flight_id = f.id
        INNER JOIN profiles p1 ON f.pilot_id = p1.id
        INNER JOIN profiles p2 ON b.passenger_id = p2.id
        WHERE b.id = @booking_id
      '''),
      parameters: {'booking_id': bookingId},
    );

    if (result.isEmpty) {
      throw Exception('Booking not found');
    }

    final row = result.first.toColumnMap();
    return {
      'flight_id': row['flight_id'],
      'pilot_id': row['pilot_id'],
      'passenger_id': row['passenger_id'],
      'departure_airport': row['departure_airport'],
      'arrival_airport': row['arrival_airport'],
      'departure_date': row['departure_date'],
      'pilot_name': row['pilot_name'],
      'passenger_name': row['passenger_name'],
    };
  }

  // Получение информации о пилоте для уведомления
  Future<Map<String, dynamic>> getPilotInfoForNotification(int pilotId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          id,
          name,
          phone,
          email
        FROM profiles
        WHERE id = @pilot_id
      '''),
      parameters: {'pilot_id': pilotId},
    );

    if (result.isEmpty) {
      throw Exception('Pilot not found');
    }

    final row = result.first.toColumnMap();
    return {'id': row['id'], 'name': row['name'], 'phone': row['phone'], 'email': row['email']};
  }

  // Загрузка фотографий к полету
  Future<List<String>> uploadFlightPhotos({
    required int flightId,
    required int uploadedBy,
    required List<String> photoUrls,
  }) async {
    // Вставляем все фотографии
    for (final photoUrl in photoUrls) {
      await _connection.execute(
        Sql.named('''
          INSERT INTO flight_photos (flight_id, photo_url, uploaded_by)
          VALUES (@flight_id, @photo_url, @uploaded_by)
        '''),
        parameters: {
          'flight_id': flightId,
          'photo_url': photoUrl,
          'uploaded_by': uploadedBy,
        },
      );
    }

    // Возвращаем список всех фотографий полета
    final result = await _connection.execute(
      Sql.named('''
        SELECT photo_url
        FROM flight_photos
        WHERE flight_id = @flight_id
        ORDER BY created_at
      '''),
      parameters: {'flight_id': flightId},
    );

    return result.map((row) => row[0] as String).toList();
  }

  // Удаление фотографии полета
  Future<List<String>> deleteFlightPhoto({
    required int flightId,
    required String photoUrl,
    required int userId,
  }) async {
    // Проверяем, что фотография существует и принадлежит пользователю
    final checkResult = await _connection.execute(
      Sql.named('''
        SELECT id, uploaded_by
        FROM flight_photos
        WHERE flight_id = @flight_id AND photo_url = @photo_url
      '''),
      parameters: {
        'flight_id': flightId,
        'photo_url': photoUrl,
      },
    );

    if (checkResult.isEmpty) {
      throw Exception('Photo not found');
    }

    final photoRow = checkResult.first.toColumnMap();
    final uploadedBy = photoRow['uploaded_by'] as int;

    // Проверяем, что пользователь является владельцем фотографии или пилотом полета
    final flight = await fetchFlightById(flightId);
    if (flight == null) {
      throw Exception('Flight not found');
    }

    final isPhotoOwner = uploadedBy == userId;
    final isPilot = flight.pilotId == userId;

    if (!isPhotoOwner && !isPilot) {
      throw Exception('You can only delete your own photos or photos from your flights');
    }

    // Удаляем запись из БД
    await _connection.execute(
      Sql.named('''
        DELETE FROM flight_photos
        WHERE flight_id = @flight_id AND photo_url = @photo_url
      '''),
      parameters: {
        'flight_id': flightId,
        'photo_url': photoUrl,
      },
    );

    // Удаляем файл с диска
    try {
      final filePath = 'public/$photoUrl';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Игнорируем ошибки удаления файла (файл может уже не существовать)
      print('Warning: Failed to delete photo file: $e');
    }

    // Возвращаем обновленный список фотографий
    final result = await _connection.execute(
      Sql.named('''
        SELECT photo_url
        FROM flight_photos
        WHERE flight_id = @flight_id
        ORDER BY created_at
      '''),
      parameters: {'flight_id': flightId},
    );

    return result.map((row) => row[0] as String).toList();
  }
}
