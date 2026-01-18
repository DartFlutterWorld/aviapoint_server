import 'dart:io';
import 'package:aviapoint_server/on_the_way/data/model/booking_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/flight_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/flight_waypoint_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/review_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/flight_question_model.dart';
import 'package:postgres/postgres.dart';

class OnTheWayRepository {
  final Connection _connection;

  OnTheWayRepository({required Connection connection}) : _connection = connection;

  // Получение списка полетов с фильтрами и вычислением свободных мест на лету
  Future<List<FlightModel>> fetchFlights({String? airport, String? departureAirport, String? arrivalAirport, DateTime? dateFrom, DateTime? dateTo, int? pilotId}) async {
    var query = '''
      SELECT 
        f.id,
        f.pilot_id,
        -- departure_airport и arrival_airport теперь получаем из flight_waypoints
        (SELECT airport_code FROM flight_waypoints WHERE flight_id = f.id AND sequence_order = 1 LIMIT 1) AS departure_airport,
        (SELECT airport_code FROM flight_waypoints WHERE flight_id = f.id ORDER BY sequence_order DESC LIMIT 1) AS arrival_airport,
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
        -- Информация об аэропорте отправления (из первой точки waypoints)
        dep_airport.name AS departure_airport_name,
        dep_airport.city AS departure_airport_city,
        dep_airport.region AS departure_airport_region,
        dep_airport.type AS departure_airport_type,
        dep_airport.ident_ru AS departure_airport_ident_ru,
        -- Информация об аэропорте прибытия (из последней точки waypoints)
        arr_airport.name AS arrival_airport_name,
        arr_airport.city AS arrival_airport_city,
        arr_airport.region AS arrival_airport_region,
        arr_airport.type AS arrival_airport_type,
        arr_airport.ident_ru AS arrival_airport_ident_ru
      FROM flights f
      LEFT JOIN profiles p ON f.pilot_id = p.id
      LEFT JOIN flight_waypoints dep_wp ON dep_wp.flight_id = f.id AND dep_wp.sequence_order = 1
      LEFT JOIN airports dep_airport ON dep_wp.airport_code = dep_airport.ident
      LEFT JOIN (
        SELECT flight_id, airport_code, sequence_order 
        FROM flight_waypoints w
        WHERE w.sequence_order = (SELECT MAX(sequence_order) FROM flight_waypoints WHERE flight_id = w.flight_id)
      ) arr_wp ON arr_wp.flight_id = f.id
      LEFT JOIN airports arr_airport ON arr_wp.airport_code = arr_airport.ident
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

    // Если указан один аэропорт (airport), ищем его во всех точках маршрута
    if (airport != null && airport.isNotEmpty) {
      query += ''' AND EXISTS (
        SELECT 1 FROM flight_waypoints w 
        WHERE w.flight_id = f.id 
        AND w.airport_code = @airport
      )''';
      parameters['airport'] = airport;
    } else {
      // Старая логика для обратной совместимости (departureAirport и arrivalAirport)
      if (departureAirport != null && departureAirport.isNotEmpty) {
        // Ищем по departure_airport в flight_waypoints (первая точка)
        query += ''' AND EXISTS (
          SELECT 1 FROM flight_waypoints w 
          WHERE w.flight_id = f.id 
          AND w.airport_code = @departure_airport 
          AND w.sequence_order = 1
        )''';
        parameters['departure_airport'] = departureAirport;
      }

      if (arrivalAirport != null && arrivalAirport.isNotEmpty) {
        // Ищем по arrival_airport в flight_waypoints (последняя точка)
        query += ''' AND EXISTS (
          SELECT 1 FROM flight_waypoints w 
          WHERE w.flight_id = f.id 
          AND w.airport_code = @arrival_airport 
          AND w.sequence_order = (
            SELECT MAX(sequence_order) FROM flight_waypoints WHERE flight_id = f.id
          )
        )''';
        parameters['arrival_airport'] = arrivalAirport;
      }

      // Поиск по промежуточным точкам (если указаны оба аэропорта, ищем маршруты, проходящие через оба)
      if (departureAirport != null && arrivalAirport != null && departureAirport.isNotEmpty && arrivalAirport.isNotEmpty) {
        // Ищем маршруты, где есть оба аэропорта в правильном порядке
        query += ''' AND EXISTS (
          SELECT 1 FROM flight_waypoints w1, flight_waypoints w2
          WHERE w1.flight_id = f.id 
          AND w2.flight_id = f.id
          AND w1.airport_code = @departure_airport
          AND w2.airport_code = @arrival_airport
          AND w1.sequence_order < w2.sequence_order
        )''';
      }
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

    // Парсим результаты запроса
    final flightsData = result.map((row) => row.toColumnMap()).toList();

    // Загружаем waypoints для каждого полета
    // ВСЕ точки маршрута хранятся в flight_waypoints
    final flightsWithWaypoints = <FlightModel>[];
    for (final map in flightsData) {
      final flightId = map['id'] as int;
      final waypoints = await fetchFlightWaypoints(flightId);

      if (waypoints.isEmpty) {
        // Пропускаем полеты без waypoints (не должны быть после очистки БД)
        continue;
      }

      // Получаем первую и последнюю точку для departure_airport и arrival_airport
      final firstWaypoint = waypoints.first;
      final lastWaypoint = waypoints.last;

      // Все полеты должны иметь waypoints (после очистки БД)
      flightsWithWaypoints.add(
        FlightModel(
          id: flightId,
          pilotId: map['pilot_id'] as int,
          departureAirport: firstWaypoint.airportCode,
          arrivalAirport: lastWaypoint.airportCode,
          departureAirportName: firstWaypoint.airportName,
          departureAirportCity: firstWaypoint.airportCity,
          departureAirportRegion: firstWaypoint.airportRegion,
          departureAirportType: firstWaypoint.airportType,
          departureAirportIdentRu: firstWaypoint.airportIdentRu,
          arrivalAirportName: lastWaypoint.airportName,
          arrivalAirportCity: lastWaypoint.airportCity,
          arrivalAirportRegion: lastWaypoint.airportRegion,
          arrivalAirportType: lastWaypoint.airportType,
          arrivalAirportIdentRu: lastWaypoint.airportIdentRu,
          departureDate: map['departure_date'] as DateTime,
          availableSeats: map['available_seats'] as int,
          totalSeats: map['total_seats'] as int?,
          pricePerSeat: _parseDouble(map['price_per_seat']) ?? 0.0,
          aircraftType: map['aircraft_type'] as String?,
          description: map['description'] as String?,
          status: map['status'] as String? ?? 'active',
          createdAt: map['created_at'] as DateTime?,
          updatedAt: map['updated_at'] as DateTime?,
          pilotFirstName: map['pilot_first_name'] as String?,
          pilotLastName: map['pilot_last_name'] as String?,
          pilotAvatarUrl: map['pilot_avatar_url'] as String?,
          pilotAverageRating: _parseDouble(map['pilot_average_rating']),
          photos: map['photos'] != null ? List<String>.from((map['photos'] as List).map((e) => e.toString())) : null,
          waypoints: waypoints, // Все точки маршрута из flight_waypoints
        ),
      );
    }

    print('🔵 [OnTheWayRepository] fetchFlights returned ${flightsWithWaypoints.length} flights');

    return flightsWithWaypoints;
  }

  // Получение полета по ID с вычислением свободных мест на лету
  Future<FlightModel?> fetchFlightById(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          f.id,
          f.pilot_id,
          -- departure_airport и arrival_airport теперь получаем из flight_waypoints
          (SELECT airport_code FROM flight_waypoints WHERE flight_id = f.id AND sequence_order = 1 LIMIT 1) AS departure_airport,
          (SELECT airport_code FROM flight_waypoints WHERE flight_id = f.id ORDER BY sequence_order DESC LIMIT 1) AS arrival_airport,
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
          -- Информация об аэропорте отправления (из первой точки waypoints)
          dep_airport.name AS departure_airport_name,
          dep_airport.city AS departure_airport_city,
          dep_airport.region AS departure_airport_region,
          dep_airport.type AS departure_airport_type,
          dep_airport.ident_ru AS departure_airport_ident_ru,
          -- Информация об аэропорте прибытия (из последней точки waypoints)
          arr_airport.name AS arrival_airport_name,
          arr_airport.city AS arrival_airport_city,
          arr_airport.region AS arrival_airport_region,
          arr_airport.type AS arrival_airport_type,
          arr_airport.ident_ru AS arrival_airport_ident_ru
        FROM flights f
        LEFT JOIN profiles p ON f.pilot_id = p.id
        LEFT JOIN flight_waypoints dep_wp ON dep_wp.flight_id = f.id AND dep_wp.sequence_order = 1
        LEFT JOIN airports dep_airport ON dep_wp.airport_code = dep_airport.ident
        LEFT JOIN (
          SELECT flight_id, airport_code, sequence_order 
          FROM flight_waypoints w
          WHERE w.sequence_order = (SELECT MAX(sequence_order) FROM flight_waypoints WHERE flight_id = w.flight_id)
        ) arr_wp ON arr_wp.flight_id = f.id
        LEFT JOIN airports arr_airport ON arr_wp.airport_code = arr_airport.ident
        WHERE f.id = @id
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      return null;
    }

    final map = result.first.toColumnMap();
    final flight = FlightModel.fromJson(map);

    // Загружаем waypoints для этого полета
    final waypoints = await fetchFlightWaypoints(id);
    if (waypoints.isNotEmpty) {
      // Создаем новый FlightModel с waypoints
      return FlightModel(
        id: flight.id,
        pilotId: flight.pilotId,
        departureAirport: flight.departureAirport,
        arrivalAirport: flight.arrivalAirport,
        departureAirportName: flight.departureAirportName,
        departureAirportCity: flight.departureAirportCity,
        departureAirportRegion: flight.departureAirportRegion,
        departureAirportType: flight.departureAirportType,
        departureAirportIdentRu: flight.departureAirportIdentRu,
        arrivalAirportName: flight.arrivalAirportName,
        arrivalAirportCity: flight.arrivalAirportCity,
        arrivalAirportRegion: flight.arrivalAirportRegion,
        arrivalAirportType: flight.arrivalAirportType,
        arrivalAirportIdentRu: flight.arrivalAirportIdentRu,
        departureDate: flight.departureDate,
        availableSeats: flight.availableSeats,
        totalSeats: flight.totalSeats,
        pricePerSeat: flight.pricePerSeat,
        aircraftType: flight.aircraftType,
        description: flight.description,
        status: flight.status,
        createdAt: flight.createdAt,
        updatedAt: flight.updatedAt,
        pilotFirstName: flight.pilotFirstName,
        pilotLastName: flight.pilotLastName,
        pilotAvatarUrl: flight.pilotAvatarUrl,
        pilotAverageRating: flight.pilotAverageRating,
        photos: flight.photos,
        waypoints: waypoints,
      );
    }

    // Все полеты должны иметь waypoints (после очистки БД)
    // Если waypoints пустой - это ошибка
    return FlightModel(
      id: flight.id,
      pilotId: flight.pilotId,
      departureAirport: flight.departureAirport,
      arrivalAirport: flight.arrivalAirport,
      departureAirportName: flight.departureAirportName,
      departureAirportCity: flight.departureAirportCity,
      departureAirportRegion: flight.departureAirportRegion,
      departureAirportType: flight.departureAirportType,
      departureAirportIdentRu: flight.departureAirportIdentRu,
      arrivalAirportName: flight.arrivalAirportName,
      arrivalAirportCity: flight.arrivalAirportCity,
      arrivalAirportRegion: flight.arrivalAirportRegion,
      arrivalAirportType: flight.arrivalAirportType,
      arrivalAirportIdentRu: flight.arrivalAirportIdentRu,
      departureDate: flight.departureDate,
      availableSeats: flight.availableSeats,
      totalSeats: flight.totalSeats,
      pricePerSeat: flight.pricePerSeat,
      aircraftType: flight.aircraftType,
      description: flight.description,
      status: flight.status,
      createdAt: flight.createdAt,
      updatedAt: flight.updatedAt,
      pilotFirstName: flight.pilotFirstName,
      pilotLastName: flight.pilotLastName,
      pilotAvatarUrl: flight.pilotAvatarUrl,
      pilotAverageRating: flight.pilotAverageRating,
      photos: flight.photos,
      waypoints: waypoints, // Может быть пустым, но это нормально для новых полетов
    );
  }

  // Получение waypoints для полета
  Future<List<FlightWaypointModel>> fetchFlightWaypoints(int flightId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          w.id,
          w.flight_id,
          w.airport_code,
          w.sequence_order,
          w.arrival_time,
          w.departure_time,
          w.comment,
          w.created_at,
          a.name AS airport_name,
          a.city AS airport_city,
          a.region AS airport_region,
          a.type AS airport_type,
          a.ident_ru AS airport_ident_ru
        FROM flight_waypoints w
        LEFT JOIN airports a ON w.airport_code = a.ident
        WHERE w.flight_id = @flight_id
        ORDER BY w.sequence_order ASC
      '''),
      parameters: {'flight_id': flightId},
    );

    return result.map((row) {
      final map = row.toColumnMap();
      return FlightWaypointModel.fromJson(map);
    }).toList();
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
    List<Map<String, dynamic>>? waypoints, // Список waypoints: [{airport_code, sequence_order, arrival_time?, departure_time?, comment?}]
  }) async {
    // ВАЖНО: В БД поле price_per_seat имеет тип INTEGER, поэтому округляем до int
    final priceAsInt = pricePerSeat.round().toInt();

    // ВАЖНО: departure_airport и arrival_airport удалены из таблицы flights
    // Все точки маршрута теперь хранятся в flight_waypoints
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO flights (
          pilot_id, departure_date,
          available_seats, price_per_seat, aircraft_type, description
        ) VALUES (
          @pilot_id, @departure_date,
          @available_seats, @price_per_seat, @aircraft_type, @description
        ) RETURNING 
          id, pilot_id, departure_date,
          available_seats AS total_seats,
          available_seats,
          price_per_seat, aircraft_type, description, status, created_at, updated_at
      '''),
      parameters: {
        'pilot_id': pilotId,
        'departure_date': departureDate,
        'available_seats': availableSeats,
        'price_per_seat': priceAsInt, // Передаем как int
        'aircraft_type': aircraftType,
        'description': description,
      },
    );

    final map = result.first.toColumnMap();
    // Создаем базовый FlightModel без departure_airport и arrival_airport (они удалены из таблицы)
    final flight = FlightModel(
      id: map['id'] as int,
      pilotId: map['pilot_id'] as int,
      departureAirport: '', // Будет заполнено из waypoints
      arrivalAirport: '', // Будет заполнено из waypoints
      departureDate: (map['departure_date'] as DateTime),
      availableSeats: map['available_seats'] as int,
      totalSeats: map['total_seats'] as int?,
      pricePerSeat: _parseDouble(map['price_per_seat']) ?? 0.0,
      aircraftType: map['aircraft_type'] as String?,
      description: map['description'] as String?,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] as DateTime?,
      updatedAt: map['updated_at'] as DateTime?,
      pilotFirstName: null,
      pilotLastName: null,
      pilotAvatarUrl: null,
      pilotAverageRating: null,
      photos: null,
      waypoints: null,
    );

    // Создаем waypoints - ВСЕ точки маршрута сохраняются в flight_waypoints
    if (waypoints == null || waypoints.isEmpty) {
      throw Exception('Waypoints are required. All route points (including departure and arrival) must be provided in waypoints.');
    }

    // Валидация: минимум 2 точки
    if (waypoints.length < 2) {
      throw Exception('Route must have at least 2 waypoints (departure and arrival)');
    }

    // Валидация: первая точка должна быть departure_airport, последняя - arrival_airport
    if (waypoints.first['airport_code'] != departureAirport) {
      throw Exception('First waypoint must match departure_airport');
    }
    if (waypoints.last['airport_code'] != arrivalAirport) {
      throw Exception('Last waypoint must match arrival_airport');
    }

    // Примечание: departure_time и arrival_time являются опциональными полями

    // Создаем waypoints
    for (final waypoint in waypoints) {
      await _connection.execute(
        Sql.named('''
          INSERT INTO flight_waypoints (
            flight_id, airport_code, sequence_order, arrival_time, departure_time, comment
          ) VALUES (
            @flight_id, @airport_code, @sequence_order, 
            @arrival_time::timestamp with time zone, 
            @departure_time::timestamp with time zone, 
            @comment
          )
        '''),
        parameters: {
          'flight_id': flight.id,
          'airport_code': waypoint['airport_code'] as String,
          'sequence_order': waypoint['sequence_order'] as int,
          'arrival_time': _parseDateTime(waypoint['arrival_time']),
          'departure_time': _parseDateTime(waypoint['departure_time']),
          'comment': waypoint['comment'] as String?,
        },
      );
    }

    // Загружаем созданные waypoints с информацией об аэропортах
    final createdWaypoints = await fetchFlightWaypoints(flight.id);

    // Получаем первую и последнюю точку для departure_airport и arrival_airport
    final firstWaypoint = createdWaypoints.first;
    final lastWaypoint = createdWaypoints.last;

    // Загружаем информацию о пилоте
    final pilotResult = await _connection.execute(Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @pilot_id'), parameters: {'pilot_id': pilotId});

    final pilotData = pilotResult.isNotEmpty ? pilotResult.first.toColumnMap() : null;

    return FlightModel(
      id: flight.id,
      pilotId: flight.pilotId,
      departureAirport: firstWaypoint.airportCode,
      arrivalAirport: lastWaypoint.airportCode,
      departureAirportName: firstWaypoint.airportName,
      departureAirportCity: firstWaypoint.airportCity,
      departureAirportRegion: firstWaypoint.airportRegion,
      departureAirportType: firstWaypoint.airportType,
      departureAirportIdentRu: firstWaypoint.airportIdentRu,
      arrivalAirportName: lastWaypoint.airportName,
      arrivalAirportCity: lastWaypoint.airportCity,
      arrivalAirportRegion: lastWaypoint.airportRegion,
      arrivalAirportType: lastWaypoint.airportType,
      arrivalAirportIdentRu: lastWaypoint.airportIdentRu,
      departureDate: flight.departureDate,
      availableSeats: flight.availableSeats,
      totalSeats: flight.totalSeats,
      pricePerSeat: flight.pricePerSeat,
      aircraftType: flight.aircraftType,
      description: flight.description,
      status: flight.status,
      createdAt: flight.createdAt,
      updatedAt: flight.updatedAt,
      pilotFirstName: pilotData?['first_name'] as String?,
      pilotLastName: pilotData?['last_name'] as String?,
      pilotAvatarUrl: pilotData?['avatar_url'] as String?,
      pilotAverageRating: null, // Можно загрузить отдельным запросом если нужно
      photos: null,
      waypoints: createdWaypoints,
    );
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
    List<Map<String, dynamic>>? waypoints, // Если передан, заменяет все waypoints
  }) async {
    final updates = <String>[];
    final parameters = <String, dynamic>{'id': id};

    // departure_airport и arrival_airport удалены из таблицы flights
    // Они теперь управляются через waypoints
    if (departureAirport != null || arrivalAirport != null) {
      print('⚠️ [OnTheWayRepository] updateFlight: departure_airport и arrival_airport теперь управляются через waypoints. Используйте параметр waypoints для изменения маршрута.');
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

    if (updates.isEmpty && waypoints == null) {
      final existingFlight = await fetchFlightById(id);
      if (existingFlight == null) {
        throw Exception('Flight not found');
      }
      return existingFlight;
    }

    // Обновляем waypoints, если они переданы (делаем это до обновления flights)
    if (waypoints != null) {
      // Валидация: минимум 2 точки
      if (waypoints.length < 2) {
        throw Exception('Route must have at least 2 waypoints (departure and arrival)');
      }

      // Примечание: departure_time и arrival_time являются опциональными полями

      // Удаляем старые waypoints
      await _connection.execute(Sql.named('DELETE FROM flight_waypoints WHERE flight_id = @flight_id'), parameters: {'flight_id': id});

      // Создаем новые waypoints
      for (final waypoint in waypoints) {
        await _connection.execute(
          Sql.named('''
            INSERT INTO flight_waypoints (
              flight_id, airport_code, sequence_order, arrival_time, departure_time, comment
            ) VALUES (
              @flight_id, @airport_code, @sequence_order, 
              @arrival_time::timestamp with time zone, 
              @departure_time::timestamp with time zone, 
              @comment
            )
          '''),
          parameters: {
            'flight_id': id,
            'airport_code': waypoint['airport_code'] as String,
            'sequence_order': waypoint['sequence_order'] as int,
            'arrival_time': _parseDateTime(waypoint['arrival_time']),
            'departure_time': _parseDateTime(waypoint['departure_time']),
            'comment': waypoint['comment'] as String?,
          },
        );
      }
    }

    // Обновляем данные полета, если есть изменения
    if (updates.isNotEmpty) {
      final query = 'UPDATE flights SET ${updates.join(', ')} WHERE id = @id';
      await _connection.execute(Sql.named(query), parameters: parameters);
    }

    // Загружаем обновленный полет с waypoints
    final updatedFlight = await fetchFlightById(id);
    if (updatedFlight == null) {
      throw Exception('Flight not found after update');
    }
    return updatedFlight;
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
    await _connection.execute(Sql.named('UPDATE flights SET status = @status WHERE id = @id'), parameters: {'id': id, 'status': 'cancelled'});

    // Загружаем обновленный полет через fetchFlightById, чтобы получить все необходимые поля
    final cancelledFlight = await fetchFlightById(id);
    if (cancelledFlight == null) {
      throw Exception('Flight not found or could not be cancelled');
    }

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
        ), 0) AS passenger_average_rating,
        f.departure_date AS flight_departure_date,
        (SELECT airport_code FROM flight_waypoints WHERE flight_id = f.id AND sequence_order = 1 LIMIT 1) AS flight_departure_airport,
        (SELECT airport_code FROM flight_waypoints WHERE flight_id = f.id ORDER BY sequence_order DESC LIMIT 1) AS flight_arrival_airport,
        COALESCE((
          SELECT json_agg(airport_code ORDER BY sequence_order)
          FROM flight_waypoints
          WHERE flight_id = f.id
        ), '[]'::json) AS flight_waypoints
      FROM bookings b
      LEFT JOIN profiles p ON b.passenger_id = p.id
      LEFT JOIN flights f ON b.flight_id = f.id
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
          p.phone AS passenger_phone,
          p.email AS passenger_email,
          p.telegram AS passenger_telegram,
          p.max AS passenger_max,
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
    // Получаем только нужные поля, без departure_airport и arrival_airport (они удалены из таблицы)
    // Не используем FlightModel.fromJson, чтобы избежать проблем с отсутствующими полями
    final flightResult = await _connection.execute(
      Sql.named('''
        SELECT 
          id,
          pilot_id,
          available_seats,
          price_per_seat
        FROM flights 
        WHERE id = @flight_id 
        FOR UPDATE
      '''),
      parameters: {'flight_id': flightId},
    );

    if (flightResult.isEmpty) {
      throw Exception('Flight not found');
    }

    final flightMap = flightResult.first.toColumnMap();
    final availableSeats = flightMap['available_seats'] as int;
    final pricePerSeat = _parseDouble(flightMap['price_per_seat']) ?? 0.0;

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
    final remainingSeats = availableSeats - bookedSeats;

    if (seatsCount > remainingSeats) {
      throw Exception('Not enough available seats');
    }

    final totalPrice = (seatsCount * pricePerSeat).round(); // Округляем до целого числа
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

    // При создании бронирования не загружаем данные пассажира через JOIN
    // Они будут загружены позже при получении списка бронирований
    // Это упрощает код и избегает проблем с NULL значениями

    // Устанавливаем null для полей пассажира (они будут загружены позже)
    map['passenger_first_name'] = null;
    map['passenger_last_name'] = null;
    map['passenger_avatar_url'] = null;
    map['passenger_average_rating'] = null;

    // Убеждаемся, что status не null (по умолчанию должно быть 'pending')
    if (map['status'] == null) {
      map['status'] = 'pending';
    }

    print('🔵 [OnTheWayRepository] createBooking final map: $map');
    final booking = BookingModel.fromJson(map);
    print('✅ [OnTheWayRepository] createBooking BookingModel created successfully');
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
          throw Exception('Бронирование не найдено');
        }

        final bookingMap = bookingResult.first.toColumnMap();
        final flightStatus = bookingMap['flight_status'] as String?;
        final bookingStatus = bookingMap['status'] as String?;
        final pilotId = bookingMap['pilot_id'] as int?;
        final passengerId = bookingMap['passenger_id'] as int?;

        // Проверяем существующие отзывы
        final existingReviewResult = await _connection.execute(
          Sql.named('SELECT COUNT(*) as count FROM reviews WHERE booking_id = @booking_id AND reviewer_id = @reviewer_id AND reply_to_review_id IS NULL'),
          parameters: {'booking_id': bookingId, 'reviewer_id': reviewerId},
        );
        final existingReviewCount = existingReviewResult.first[0] as int;

        String errorMessage = 'Не удалось создать отзыв: ';
        if (bookingStatus != 'confirmed') {
          errorMessage += 'бронирование не подтверждено (статус: $bookingStatus)';
        } else if (flightStatus != 'completed') {
          errorMessage += 'полёт не завершён (статус: $flightStatus)';
        } else if (reviewerId != passengerId && reviewerId != pilotId) {
          errorMessage += 'у вас нет прав для создания отзыва (вы не являетесь пассажиром или пилотом этого полёта)';
        } else if (existingReviewCount > 0) {
          errorMessage += 'отзыв уже существует для этого бронирования';
        } else {
          errorMessage += 'неизвестная ошибка';
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

    // Проверяем права: владелец или администратор
    final isOwner = reviewerId == userId;
    if (!isOwner) {
      final adminCheck = await _connection.execute(Sql.named('SELECT is_admin FROM profiles WHERE id = @id'), parameters: {'id': userId});
      final isAdmin = adminCheck.isNotEmpty && (adminCheck.first.toColumnMap()['is_admin'] as bool? ?? false);

      if (!isAdmin) {
        throw Exception('You can only edit your own reviews');
      }
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

    // Проверяем права: владелец или администратор
    final isOwner = reviewerId == userId;
    if (!isOwner) {
      final adminCheck = await _connection.execute(Sql.named('SELECT is_admin FROM profiles WHERE id = @id'), parameters: {'id': userId});
      final isAdmin = adminCheck.isNotEmpty && (adminCheck.first.toColumnMap()['is_admin'] as bool? ?? false);

      if (!isAdmin) {
        throw Exception('You can only delete your own reviews');
      }
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
          -- departure_airport и arrival_airport теперь получаем из flight_waypoints
          (SELECT airport_code FROM flight_waypoints WHERE flight_id = f.id AND sequence_order = 1 LIMIT 1) AS departure_airport,
          (SELECT airport_code FROM flight_waypoints WHERE flight_id = f.id ORDER BY sequence_order DESC LIMIT 1) AS arrival_airport,
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

  /// Получение информации о полете для уведомления о подтверждении бронирования
  /// Использует flight_id вместо booking_id
  Future<Map<String, dynamic>> getFlightInfoForBookingNotificationByFlightId(int flightId) async {
    // Получаем информацию о полете и waypoints
    final flightResult = await _connection.execute(
      Sql.named('''
        SELECT 
          f.id,
          f.pilot_id,
          f.departure_date,
          -- Получаем все waypoints отсортированные по sequence_order
          COALESCE(
            json_agg(
              json_build_object(
                'airport_code', fw.airport_code,
                'sequence_order', fw.sequence_order
              ) ORDER BY fw.sequence_order
            ) FILTER (WHERE fw.airport_code IS NOT NULL),
            '[]'::json
          ) AS waypoints
        FROM flights f
        LEFT JOIN flight_waypoints fw ON fw.flight_id = f.id
        WHERE f.id = @flight_id
        GROUP BY f.id, f.pilot_id, f.departure_date
      '''),
      parameters: {'flight_id': flightId},
    );

    if (flightResult.isEmpty) {
      throw Exception('Flight not found');
    }

    final row = flightResult.first.toColumnMap();
    final waypointsJson = row['waypoints'];

    // Парсим waypoints из JSON
    List<String> waypoints = [];
    if (waypointsJson != null) {
      try {
        final waypointsList = waypointsJson as List;
        waypoints = waypointsList.map((wp) => wp['airport_code'] as String).toList();
      } catch (e) {
        print('⚠️ Ошибка парсинга waypoints: $e');
      }
    }

    // Форматируем дату для текста уведомления
    final departureDate = row['departure_date'] as DateTime?;
    String formattedDate = '';
    if (departureDate != null) {
      // Формат: "15.03.2024"
      formattedDate = '${departureDate.day.toString().padLeft(2, '0')}.${departureDate.month.toString().padLeft(2, '0')}.${departureDate.year}';
    }

    return {'flight_id': row['id'], 'pilot_id': row['pilot_id'], 'departure_date': departureDate, 'formatted_date': formattedDate, 'waypoints': waypoints, 'waypoints_text': waypoints.join(' → ')};
  }

  // Получение информации о пилоте для уведомления
  Future<Map<String, dynamic>> getPilotInfoForNotification(int pilotId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          id,
          first_name,
          last_name,
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
    final firstName = row['first_name'] as String? ?? '';
    final lastName = row['last_name'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();

    // Получаем все FCM токены пользователя (из новой таблицы)
    final tokensResult = await _connection.execute(
      Sql.named('''
        SELECT fcm_token, platform
        FROM user_fcm_tokens
        WHERE user_id = @pilot_id
        ORDER BY updated_at DESC
      '''),
      parameters: {'pilot_id': pilotId},
    );

    // Берем первый доступный токен (или null если токенов нет)
    String? fcmToken;
    if (tokensResult.isNotEmpty) {
      fcmToken = tokensResult.first.toColumnMap()['fcm_token'] as String?;
    } else {
      // Fallback на старое поле для обратной совместимости
      final oldTokenResult = await _connection.execute(Sql.named('SELECT fcm_token FROM profiles WHERE id = @pilot_id'), parameters: {'pilot_id': pilotId});
      if (oldTokenResult.isNotEmpty) {
        fcmToken = oldTokenResult.first.toColumnMap()['fcm_token'] as String?;
      }
    }

    return {'id': row['id'], 'name': fullName.isNotEmpty ? fullName : 'Пилот', 'first_name': firstName, 'last_name': lastName, 'phone': row['phone'], 'email': row['email'], 'fcm_token': fcmToken};
  }

  /// Получение информации о полете для уведомления о бронировании
  /// Возвращает данные полета, включая все точки маршрута (waypoints) и дату
  Future<Map<String, dynamic>> getFlightInfoForBookingNotification(int flightId) async {
    // Получаем информацию о полете и waypoints
    final flightResult = await _connection.execute(
      Sql.named('''
        SELECT 
          f.id,
          f.pilot_id,
          f.departure_date,
          -- Получаем все waypoints отсортированные по sequence_order
          COALESCE(
            json_agg(
              json_build_object(
                'airport_code', fw.airport_code,
                'sequence_order', fw.sequence_order
              ) ORDER BY fw.sequence_order
            ) FILTER (WHERE fw.airport_code IS NOT NULL),
            '[]'::json
          ) AS waypoints
        FROM flights f
        LEFT JOIN flight_waypoints fw ON fw.flight_id = f.id
        WHERE f.id = @flight_id
        GROUP BY f.id, f.pilot_id, f.departure_date
      '''),
      parameters: {'flight_id': flightId},
    );

    if (flightResult.isEmpty) {
      throw Exception('Flight not found');
    }

    final row = flightResult.first.toColumnMap();
    final waypointsJson = row['waypoints'];

    // Парсим waypoints из JSON
    List<String> waypoints = [];
    if (waypointsJson != null) {
      try {
        final waypointsList = waypointsJson as List;
        waypoints = waypointsList.map((wp) => wp['airport_code'] as String).toList();
      } catch (e) {
        print('⚠️ Ошибка парсинга waypoints: $e');
      }
    }

    // Форматируем дату для текста уведомления
    final departureDate = row['departure_date'] as DateTime?;
    String formattedDate = '';
    if (departureDate != null) {
      // Формат: "15.03.2024"
      formattedDate = '${departureDate.day.toString().padLeft(2, '0')}.${departureDate.month.toString().padLeft(2, '0')}.${departureDate.year}';
    }

    return {'flight_id': row['id'], 'pilot_id': row['pilot_id'], 'departure_date': departureDate, 'formatted_date': formattedDate, 'waypoints': waypoints, 'waypoints_text': waypoints.join(' → ')};
  }

  // Загрузка фотографий к полету
  Future<List<String>> uploadFlightPhotos({required int flightId, required int uploadedBy, required List<String> photoUrls}) async {
    // Вставляем все фотографии
    for (final photoUrl in photoUrls) {
      await _connection.execute(
        Sql.named('''
          INSERT INTO flight_photos (flight_id, photo_url, uploaded_by)
          VALUES (@flight_id, @photo_url, @uploaded_by)
        '''),
        parameters: {'flight_id': flightId, 'photo_url': photoUrl, 'uploaded_by': uploadedBy},
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
  Future<List<String>> deleteFlightPhoto({required int flightId, required String photoUrl, required int userId}) async {
    // Проверяем, что фотография существует и принадлежит пользователю
    final checkResult = await _connection.execute(
      Sql.named('''
        SELECT id, uploaded_by
        FROM flight_photos
        WHERE flight_id = @flight_id AND photo_url = @photo_url
      '''),
      parameters: {'flight_id': flightId, 'photo_url': photoUrl},
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
      // Проверяем, является ли пользователь администратором
      final adminCheck = await _connection.execute(Sql.named('SELECT is_admin FROM profiles WHERE id = @user_id'), parameters: {'user_id': userId});
      final isAdmin = adminCheck.isNotEmpty && (adminCheck.first.toColumnMap()['is_admin'] as bool? ?? false);
      if (!isAdmin) {
        throw Exception('You can only delete your own photos or photos from your flights');
      }
    }

    // Удаляем запись из БД
    await _connection.execute(
      Sql.named('''
        DELETE FROM flight_photos
        WHERE flight_id = @flight_id AND photo_url = @photo_url
      '''),
      parameters: {'flight_id': flightId, 'photo_url': photoUrl},
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

  /// Безопасно парсит DateTime из разных типов (DateTime, String, null)
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Безопасно парсит double из разных типов (num, String, null)
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ========== FLIGHT QUESTIONS ==========

  // Получение вопросов по полёту (сортировка от старой к новой)
  Future<List<FlightQuestionModel>> fetchQuestionsByFlightId(int flightId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          q.*,
          author.first_name as author_first_name,
          author.last_name as author_last_name,
          author.avatar_url as author_avatar_url,
          answered_by.first_name as answered_by_first_name,
          answered_by.last_name as answered_by_last_name,
          answered_by.avatar_url as answered_by_avatar_url
        FROM flight_questions q
        LEFT JOIN profiles author ON q.author_id = author.id
        LEFT JOIN profiles answered_by ON q.answered_by_id = answered_by.id
        WHERE q.flight_id = @flight_id
        ORDER BY q.created_at ASC
      '''),
      parameters: {'flight_id': flightId},
    );

    return result.map((row) {
      final map = row.toColumnMap();
      return FlightQuestionModel.fromJson(map);
    }).toList();
  }

  // Создание вопроса
  Future<FlightQuestionModel> createQuestion({required int flightId, int? authorId, required String questionText}) async {
    // Проверяем, что полёт существует
    final flightResult = await _connection.execute(Sql.named('SELECT id FROM flights WHERE id = @flight_id'), parameters: {'flight_id': flightId});

    if (flightResult.isEmpty) {
      throw Exception('Flight not found');
    }

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO flight_questions (flight_id, author_id, question_text)
        VALUES (@flight_id, @author_id, @question_text)
        RETURNING *
      '''),
      parameters: {'flight_id': flightId, 'author_id': authorId, 'question_text': questionText},
    );

    final map = result.first.toColumnMap();

    // Загружаем данные автора, если есть
    if (authorId != null) {
      final authorResult = await _connection.execute(Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @author_id'), parameters: {'author_id': authorId});

      if (authorResult.isNotEmpty) {
        final authorMap = authorResult.first.toColumnMap();
        map['author_first_name'] = authorMap['first_name'];
        map['author_last_name'] = authorMap['last_name'];
        map['author_avatar_url'] = authorMap['avatar_url'];
      }
    }

    return FlightQuestionModel.fromJson(map);
  }

  // Обновление вопроса (автор может обновить вопрос, пилот может обновить ответ)
  Future<FlightQuestionModel> updateQuestion({required int questionId, required int userId, String? questionText, String? answerText}) async {
    // Получаем информацию о вопросе и полёте
    final questionResult = await _connection.execute(
      Sql.named('''
        SELECT q.*, f.pilot_id
        FROM flight_questions q
        INNER JOIN flights f ON q.flight_id = f.id
        WHERE q.id = @question_id
      '''),
      parameters: {'question_id': questionId},
    );

    if (questionResult.isEmpty) {
      throw Exception('Question not found');
    }

    final questionMap = questionResult.first.toColumnMap();
    final authorId = questionMap['author_id'] as int?;
    final pilotId = questionMap['pilot_id'] as int;

    // Проверяем, является ли пользователь администратором
    final adminCheck = await _connection.execute(Sql.named('SELECT is_admin FROM profiles WHERE id = @id'), parameters: {'id': userId});
    final isAdmin = adminCheck.isNotEmpty && (adminCheck.first.toColumnMap()['is_admin'] as bool? ?? false);

    // Проверяем права: автор может обновить вопрос, пилот может обновить ответ, администратор может всё
    if (questionText != null && authorId != userId && !isAdmin) {
      throw Exception('You can only edit your own questions');
    }

    if (answerText != null && pilotId != userId && !isAdmin) {
      throw Exception('Only the pilot can answer questions');
    }

    // Обновляем вопрос
    final updates = <String>[];
    final parameters = <String, dynamic>{'question_id': questionId};

    if (questionText != null) {
      updates.add('question_text = @question_text');
      parameters['question_text'] = questionText;
    }

    if (answerText != null) {
      updates.add('answer_text = @answer_text');
      updates.add('answered_by_id = @answered_by_id');
      updates.add('answered_at = NOW()');
      parameters['answer_text'] = answerText;
      parameters['answered_by_id'] = userId;
    }

    if (updates.isEmpty) {
      throw Exception('Nothing to update');
    }

    updates.add('updated_at = NOW()');

    final result = await _connection.execute(
      Sql.named('''
        UPDATE flight_questions 
        SET ${updates.join(', ')}
        WHERE id = @question_id
        RETURNING *
      '''),
      parameters: parameters,
    );

    if (result.isEmpty) {
      throw Exception('Failed to update question');
    }

    final map = result.first.toColumnMap();

    // Загружаем данные автора и пилота
    if (authorId != null) {
      final authorResult = await _connection.execute(Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @author_id'), parameters: {'author_id': authorId});

      if (authorResult.isNotEmpty) {
        final authorMap = authorResult.first.toColumnMap();
        map['author_first_name'] = authorMap['first_name'];
        map['author_last_name'] = authorMap['last_name'];
        map['author_avatar_url'] = authorMap['avatar_url'];
      }
    }

    if (map['answered_by_id'] != null) {
      final answeredByResult = await _connection.execute(
        Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @answered_by_id'),
        parameters: {'answered_by_id': map['answered_by_id']},
      );

      if (answeredByResult.isNotEmpty) {
        final answeredByMap = answeredByResult.first.toColumnMap();
        map['answered_by_first_name'] = answeredByMap['first_name'];
        map['answered_by_last_name'] = answeredByMap['last_name'];
        map['answered_by_avatar_url'] = answeredByMap['avatar_url'];
      }
    }

    return FlightQuestionModel.fromJson(map);
  }

  // Ответ на вопрос (только создатель полёта)
  Future<FlightQuestionModel> answerQuestion({required int questionId, required int userId, required String answerText}) async {
    // Получаем информацию о вопросе и полёте
    final questionResult = await _connection.execute(
      Sql.named('''
        SELECT q.*, f.pilot_id
        FROM flight_questions q
        INNER JOIN flights f ON q.flight_id = f.id
        WHERE q.id = @question_id
      '''),
      parameters: {'question_id': questionId},
    );

    if (questionResult.isEmpty) {
      throw Exception('Question not found');
    }

    final questionMap = questionResult.first.toColumnMap();
    final pilotId = questionMap['pilot_id'] as int;

    // Проверяем права: только создатель полёта может отвечать
    if (pilotId != userId) {
      throw Exception('Only the flight creator can answer questions');
    }

    // Обновляем вопрос с ответом
    final result = await _connection.execute(
      Sql.named('''
        UPDATE flight_questions 
        SET answer_text = @answer_text,
            answered_by_id = @answered_by_id,
            answered_at = NOW(),
            updated_at = NOW()
        WHERE id = @question_id
        RETURNING *
      '''),
      parameters: {'question_id': questionId, 'answer_text': answerText, 'answered_by_id': userId},
    );

    if (result.isEmpty) {
      throw Exception('Failed to answer question');
    }

    final map = result.first.toColumnMap();
    final authorId = map['author_id'] as int?;

    // Загружаем данные автора и пилота
    if (authorId != null) {
      final authorResult = await _connection.execute(Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @author_id'), parameters: {'author_id': authorId});

      if (authorResult.isNotEmpty) {
        final authorMap = authorResult.first.toColumnMap();
        map['author_first_name'] = authorMap['first_name'];
        map['author_last_name'] = authorMap['last_name'];
        map['author_avatar_url'] = authorMap['avatar_url'];
      }
    }

    // Загружаем данные пилота, который ответил
    final answeredByResult = await _connection.execute(Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @answered_by_id'), parameters: {'answered_by_id': userId});

    if (answeredByResult.isNotEmpty) {
      final answeredByMap = answeredByResult.first.toColumnMap();
      map['answered_by_first_name'] = answeredByMap['first_name'];
      map['answered_by_last_name'] = answeredByMap['last_name'];
      map['answered_by_avatar_url'] = answeredByMap['avatar_url'];
    }

    return FlightQuestionModel.fromJson(map);
  }

  // Удаление вопроса (автор или пилот)
  Future<bool> deleteQuestion({required int questionId, required int userId}) async {
    // Получаем информацию о вопросе и полёте
    final questionResult = await _connection.execute(
      Sql.named('''
        SELECT q.author_id, f.pilot_id
        FROM flight_questions q
        INNER JOIN flights f ON q.flight_id = f.id
        WHERE q.id = @question_id
      '''),
      parameters: {'question_id': questionId},
    );

    if (questionResult.isEmpty) {
      throw Exception('Question not found');
    }

    final questionMap = questionResult.first.toColumnMap();
    final authorId = questionMap['author_id'] as int?;
    final pilotId = questionMap['pilot_id'] as int;

    // Проверяем права: автор, пилот или администратор могут удалить
    final isAuthor = authorId != null && authorId == userId;
    final isPilot = pilotId == userId;

    if (!isAuthor && !isPilot) {
      // Проверяем, является ли пользователь администратором
      final adminCheck = await _connection.execute(Sql.named('SELECT is_admin FROM profiles WHERE id = @id'), parameters: {'id': userId});
      final isAdmin = adminCheck.isNotEmpty && (adminCheck.first.toColumnMap()['is_admin'] as bool? ?? false);

      if (!isAdmin) {
        throw Exception('You can only delete your own questions or questions on your flights');
      }
    }

    // Удаляем вопрос
    await _connection.execute(Sql.named('DELETE FROM flight_questions WHERE id = @question_id'), parameters: {'question_id': questionId});

    return true;
  }
}
