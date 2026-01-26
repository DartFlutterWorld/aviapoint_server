import 'dart:convert';
import 'package:aviapoint_server/on_the_way/data/model/airport_model.dart';
import 'package:postgres/postgres.dart';

class AirportRepository {
  final Connection _connection;

  AirportRepository({required Connection connection}) : _connection = connection;

  /// Поиск аэропортов по запросу (код, название, город)
  Future<List<AirportModel>> searchAirports({String? query, String? country, String? type, int? limit = 50}) async {
    var sql = '''
      SELECT * FROM airports
      WHERE 1=1
    ''';
    final parameters = <String, dynamic>{};

    if (country != null && country.isNotEmpty) {
      sql += ' AND (country_code = @country OR country = @country)';
      parameters['country'] = country;
    }

    if (type != null && type.isNotEmpty) {
      sql += ' AND type = @type';
      parameters['type'] = type;
    }

    if (query != null && query.isNotEmpty) {
      sql += ''' AND (
        ident ILIKE @query OR
        ident_ru ILIKE @query OR
        name ILIKE @query OR
        name_eng ILIKE @query OR
        city ILIKE @query OR
        region ILIKE @query
      )''';
      parameters['query'] = '%$query%';
    }

    sql += ' ORDER BY name ASC LIMIT @limit';
    parameters['limit'] = limit;

    final result = await _connection.execute(Sql.named(sql), parameters: parameters);

    return result.map((row) {
      final map = row.toColumnMap();
      return AirportModel.fromJson(map);
    }).toList();
  }

  /// Получить аэропорт по ICAO коду
  Future<AirportModel?> getAirportByCode(String ident) async {
    final result = await _connection.execute(Sql.named('SELECT * FROM airports WHERE ident = @ident'), parameters: {'ident': ident});

    if (result.isEmpty) return null;

    final airportData = result.first.toColumnMap();
    
    // Загружаем фотографии посетителей из отдельной таблицы по airport_id (не по коду, так как код может измениться)
    final airportId = airportData['id'] as int;
    final visitorPhotosResult = await _connection.execute(
      Sql.named('''
        SELECT photo_url FROM airport_visitor_photos
        WHERE airport_id = @airport_id
        ORDER BY uploaded_at DESC
      '''),
      parameters: {'airport_id': airportId},
    );
    
    // Если фотографий нет, будет пустой список
    final visitorPhotoUrls = visitorPhotosResult.map((row) => row.toColumnMap()['photo_url'] as String).toList();
    
    print('📸 [AirportRepository] Загружено фотографий посетителей для airport_id=$airportId (code=$ident): ${visitorPhotoUrls.length}');
    if (visitorPhotoUrls.isNotEmpty) {
      print('📸 [AirportRepository] URL фотографий: $visitorPhotoUrls');
    }
    
    // Обновляем visitor_photos в данных аэропорта перед созданием модели
    // Если фотографий нет, устанавливаем null или пустой массив
    if (visitorPhotoUrls.isNotEmpty) {
      airportData['visitor_photos'] = visitorPhotoUrls;
    } else {
      // Если фотографий нет, устанавливаем null (не пустой массив)
      airportData['visitor_photos'] = null;
    }
    
    print('📸 [AirportRepository] airportData[visitor_photos] перед созданием модели: ${airportData['visitor_photos']}');
    
    final airport = AirportModel.fromJson(airportData);
    
    print('📸 [AirportRepository] После создания модели: airport.visitorPhotos = ${airport.visitorPhotos}');
    
    return airport;
  }

  /// Получить аэропорт по ID
  Future<AirportModel?> getAirportById(int id) async {
    final result = await _connection.execute(Sql.named('SELECT * FROM airports WHERE id = @id'), parameters: {'id': id});

    if (result.isEmpty) return null;

    return AirportModel.fromJson(result.first.toColumnMap());
  }

  /// Получить все аэропорты страны
  Future<List<AirportModel>> getAirportsByCountry(String countryCode, {int? limit}) async {
    var sql = '''
      SELECT * FROM airports
      WHERE (country_code = @country OR country = @country)
      ORDER BY name ASC
    ''';
    final parameters = <String, dynamic>{'country': countryCode};

    if (limit != null) {
      sql += ' LIMIT @limit';
      parameters['limit'] = limit;
    }

    final result = await _connection.execute(Sql.named(sql), parameters: parameters);

    return result.map((row) {
      final map = row.toColumnMap();
      return AirportModel.fromJson(map);
    }).toList();
  }

  /// Обновить услуги аэропорта
  Future<AirportModel?> updateAirportServices(int id, Map<String, dynamic> services) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE airports
        SET services = @services::jsonb, updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': id, 'services': jsonEncode(services)},
    );

    if (result.isEmpty) return null;

    return AirportModel.fromJson(result.first.toColumnMap());
  }

  /// Установить владельца аэропорта
  Future<AirportModel?> setAirportOwner(int id, int? ownerId) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE airports
        SET owner_id = @owner_id, updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': id, 'owner_id': ownerId},
    );

    if (result.isEmpty) return null;

    return AirportModel.fromJson(result.first.toColumnMap());
  }

  /// Проверить, является ли пользователь владельцем аэропорта
  Future<bool> isAirportOwner(int userId, String airportCode) async {
    // Получаем ID аэропорта по коду
    final airport = await getAirportByCode(airportCode);
    if (airport == null) return false;

    // Проверяем в профиле пользователя
    final result = await _connection.execute(
      Sql.named('''
        SELECT owned_airports
        FROM profiles
        WHERE id = @user_id
      '''),
      parameters: {'user_id': userId},
    );

    if (result.isEmpty) return false;

    final ownedAirports = result.first.toColumnMap()['owned_airports'];
    if (ownedAirports == null) return false;

    // Парсим JSONB массив
    List<dynamic> airportsList;
    if (ownedAirports is List) {
      airportsList = ownedAirports;
    } else if (ownedAirports is String) {
      airportsList = jsonDecode(ownedAirports) as List;
    } else {
      return false;
    }

    // Проверяем, есть ли ID аэропорта в списке
    return airportsList.any((id) => id == airport.id);
  }

  /// Обновить данные аэропорта (только для владельца)
  Future<AirportModel?> updateAirport({
    required int userId,
    required String airportCode,
    String? name,
    String? nameEng,
    String? city,
    String? region,
    String? email,
    String? website,
    String? notes,
    int? runwayLength,
    int? runwayWidth,
    String? runwaySurface,
    String? runwayName,
    Map<String, dynamic>? services,
  }) async {
    // Проверяем, является ли пользователь владельцем
    final isOwner = await isAirportOwner(userId, airportCode);
    if (!isOwner) {
      throw Exception('User is not the owner of this airport');
    }

    // Получаем аэропорт
    final airport = await getAirportByCode(airportCode);
    if (airport == null) {
      throw Exception('Airport not found');
    }

    // Формируем SQL запрос для обновления только переданных полей
    final updates = <String>[];
    final parameters = <String, dynamic>{'id': airport.id};

    if (name != null) {
      updates.add('name = @name');
      parameters['name'] = name;
    }
    if (nameEng != null) {
      updates.add('name_eng = @name_eng');
      parameters['name_eng'] = nameEng;
    }
    if (city != null) {
      updates.add('city = @city');
      parameters['city'] = city;
    }
    if (region != null) {
      updates.add('region = @region');
      parameters['region'] = region;
    }
    if (email != null) {
      updates.add('email = @email');
      parameters['email'] = email;
    }
    if (website != null) {
      updates.add('website = @website');
      parameters['website'] = website;
    }
    if (notes != null) {
      updates.add('notes = @notes');
      parameters['notes'] = notes;
    }
    if (runwayLength != null) {
      updates.add('runway_length = @runway_length');
      parameters['runway_length'] = runwayLength;
    }
    if (runwayWidth != null) {
      updates.add('runway_width = @runway_width');
      parameters['runway_width'] = runwayWidth;
    }
    if (runwaySurface != null) {
      updates.add('runway_surface = @runway_surface');
      parameters['runway_surface'] = runwaySurface;
    }
    if (runwayName != null) {
      updates.add('runway_name = @runway_name');
      parameters['runway_name'] = runwayName;
    }
    if (services != null) {
      updates.add('services = @services::jsonb');
      parameters['services'] = jsonEncode(services);
    }

    if (updates.isEmpty) {
      return airport; // Нет изменений
    }

    updates.add('updated_at = NOW()');

    final sql = '''
      UPDATE airports
      SET ${updates.join(', ')}
      WHERE id = @id
      RETURNING *
    ''';

    final result = await _connection.execute(Sql.named(sql), parameters: parameters);

    if (result.isEmpty) return null;

    return AirportModel.fromJson(result.first.toColumnMap());
  }

  /// Сохранить обратную связь об аэропорте и добавить фотографии в таблицу airports
  Future<void> submitAirportFeedback({
    required String airportCode,
    String? email,
    String? comment,
    List<String>? photoUrls,
  }) async {
    // Сохраняем обратную связь в airport_feedback (для истории)
    await _connection.execute(
      Sql.named('''
        INSERT INTO airport_feedback (airport_code, email, comment, photos, status)
        VALUES (@airport_code, @email, @comment, @photos::jsonb, 'pending')
      '''),
      parameters: {
        'airport_code': airportCode,
        'email': email,
        'comment': comment,
        'photos': photoUrls != null && photoUrls.isNotEmpty ? jsonEncode(photoUrls) : null,
      },
    );

    // Если есть фотографии, добавляем их в таблицу airports
    if (photoUrls != null && photoUrls.isNotEmpty) {
      // Получаем текущий список фотографий аэропорта
      final airport = await getAirportByCode(airportCode);
      if (airport != null) {
        // Парсим существующие фотографии
        List<String> existingPhotos = [];
        if (airport.photos != null && airport.photos is List) {
          existingPhotos = (airport.photos as List).map((e) => e.toString()).toList();
        } else if (airport.photos != null && airport.photos is String) {
          try {
            final parsed = jsonDecode(airport.photos as String) as List;
            existingPhotos = parsed.map((e) => e.toString()).toList();
          } catch (e) {
            // Если не удалось распарсить, начинаем с пустого списка
            existingPhotos = [];
          }
        }

        // Добавляем новые фотографии к существующим (без дубликатов)
        final updatedPhotos = <String>[...existingPhotos];
        for (final photoUrl in photoUrls) {
          if (!updatedPhotos.contains(photoUrl)) {
            updatedPhotos.add(photoUrl);
          }
        }

        // Обновляем фотографии в таблице airports
        await _connection.execute(
          Sql.named('''
            UPDATE airports
            SET photos = @photos::jsonb, updated_at = NOW()
            WHERE ident = @ident
          '''),
          parameters: {
            'ident': airportCode,
            'photos': jsonEncode(updatedPhotos),
          },
        );
      }
    }
  }

  /// Загрузить фотографии аэропорта
  Future<void> uploadAirportPhotos({
    required String airportCode,
    required List<String> photoUrls,
  }) async {
    // Получаем текущий список фотографий аэропорта
    final airport = await getAirportByCode(airportCode);
    if (airport == null) {
      throw Exception('Airport not found');
    }

    // Парсим существующие фотографии
    List<String> existingPhotos = [];
    if (airport.photos != null && airport.photos is List) {
      existingPhotos = (airport.photos as List).map((e) => e.toString()).toList();
    } else if (airport.photos != null && airport.photos is String) {
      try {
        final parsed = jsonDecode(airport.photos as String) as List;
        existingPhotos = parsed.map((e) => e.toString()).toList();
      } catch (e) {
        existingPhotos = [];
      }
    }

    // Добавляем новые фотографии к существующим (без дубликатов)
    final updatedPhotos = <String>[...existingPhotos];
    for (final photoUrl in photoUrls) {
      if (!updatedPhotos.contains(photoUrl)) {
        updatedPhotos.add(photoUrl);
      }
    }

    // Обновляем список фотографий в БД
    await _connection.execute(
      Sql.named('''
        UPDATE airports
        SET photos = @photos::jsonb, updated_at = NOW()
        WHERE ident = @airport_code
      '''),
      parameters: {
        'airport_code': airportCode,
        'photos': jsonEncode(updatedPhotos),
      },
    );
  }

  /// Удалить фотографию аэропорта
  Future<void> deleteAirportPhoto({
    required String airportCode,
    required String photoUrl,
  }) async {
    // Получаем текущий список фотографий аэропорта
    final airport = await getAirportByCode(airportCode);
    if (airport == null) {
      throw Exception('Airport not found');
    }

    // Парсим существующие фотографии
    List<String> existingPhotos = [];
    if (airport.photos != null && airport.photos is List) {
      existingPhotos = (airport.photos as List).map((e) => e.toString()).toList();
    } else if (airport.photos != null && airport.photos is String) {
      try {
        final parsed = jsonDecode(airport.photos as String) as List;
        existingPhotos = parsed.map((e) => e.toString()).toList();
      } catch (e) {
        existingPhotos = [];
      }
    }

    // Удаляем фотографию из списка
    existingPhotos.remove(photoUrl);

    // Обновляем список фотографий в БД
    await _connection.execute(
      Sql.named('''
        UPDATE airports
        SET photos = @photos::jsonb, updated_at = NOW()
        WHERE ident = @airport_code
      '''),
      parameters: {
        'airport_code': airportCode,
        'photos': existingPhotos.isNotEmpty ? jsonEncode(existingPhotos) : null,
      },
    );
  }

  /// Загрузить фотографии посетителей аэропорта
  Future<void> uploadVisitorPhotos({
    required String airportCode,
    required List<Map<String, dynamic>> photoDataList, // Список с метаданными: url, user_id, phone, uploaded_at
  }) async {
    // Получаем аэропорт для получения ID
    final airport = await getAirportByCode(airportCode);
    if (airport == null) {
      throw Exception('Airport not found');
    }

    // Сохраняем каждую фотографию в отдельную таблицу
    for (final photoData in photoDataList) {
      final photoUrl = photoData['url'] as String;
      final userId = photoData['user_id'] as int;
      final userPhone = photoData['phone'] as String;
      final uploadedAt = photoData['uploaded_at'] as String? ?? DateTime.now().toIso8601String();
      final label = photoData['label'] as String?;

      // Проверяем, не существует ли уже такая фотография (по airport_id, а не по коду)
      final existing = await _connection.execute(
        Sql.named('''
          SELECT id FROM airport_visitor_photos
          WHERE airport_id = @airport_id AND photo_url = @photo_url
        '''),
        parameters: {
          'airport_id': airport.id,
          'photo_url': photoUrl,
        },
      );

      // Если фотография уже существует, пропускаем
      if (existing.isNotEmpty) continue;

      // Вставляем новую запись в отдельную таблицу
      await _connection.execute(
        Sql.named('''
          INSERT INTO airport_visitor_photos 
            (airport_code, airport_id, photo_url, user_id, user_phone, label, uploaded_at)
          VALUES 
            (@airport_code, @airport_id, @photo_url, @user_id, @user_phone, @label, @uploaded_at::timestamp with time zone)
        '''),
        parameters: {
          'airport_code': airportCode,
          'airport_id': airport.id,
          'photo_url': photoUrl,
          'user_id': userId,
          'user_phone': userPhone,
          'label': label,
          'uploaded_at': uploadedAt,
        },
      );
    }
    
    // Фотографии посетителей хранятся ТОЛЬКО в отдельной таблице airport_visitor_photos
    // Не обновляем поле visitor_photos в таблице airports
  }

  /// Получить метаданные фотографии посетителя по URL
  Future<Map<String, dynamic>?> getVisitorPhotoByUrl(int airportId, String photoUrl) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT id, user_id, user_phone, label, uploaded_at
        FROM airport_visitor_photos
        WHERE airport_id = @airport_id AND photo_url = @photo_url
      '''),
      parameters: {
        'airport_id': airportId,
        'photo_url': photoUrl,
      },
    );

    if (result.isEmpty) return null;

    final row = result.first.toColumnMap();
    return {
      'id': row['id'] as int,
      'user_id': row['user_id'] as int,
      'user_phone': row['user_phone'] as String,
      'label': row['label'] as String?,
      'uploaded_at': row['uploaded_at'] as DateTime?,
    };
  }

  /// Удалить фотографию посетителя
  Future<void> deleteVisitorPhoto(int airportId, String photoUrl) async {
    await _connection.execute(
      Sql.named('''
        DELETE FROM airport_visitor_photos
        WHERE airport_id = @airport_id AND photo_url = @photo_url
      '''),
      parameters: {
        'airport_id': airportId,
        'photo_url': photoUrl,
      },
    );
  }

  // ========== AIRPORT REVIEWS ==========

  /// Получить все отзывы об аэропорте
  Future<List<Map<String, dynamic>>> getAirportReviews(String airportCode) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          ar.id,
          ar.airport_code,
          ar.reviewer_id,
          ar.rating,
          ar.comment,
          ar.photo_urls,
          ar.reply_to_review_id,
          ar.created_at,
          ar.updated_at,
          p.first_name AS reviewer_first_name,
          p.last_name AS reviewer_last_name,
          p.avatar_url AS reviewer_avatar_url
        FROM airport_reviews ar
        LEFT JOIN profiles p ON ar.reviewer_id = p.id
        WHERE ar.airport_code = @airport_code
        ORDER BY ar.created_at DESC
      '''),
      parameters: {'airport_code': airportCode},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Создать отзыв об аэропорте
  Future<Map<String, dynamic>> createAirportReview({
    required String airportCode,
    required int reviewerId,
    required int rating,
    String? comment,
    List<String>? photoUrls,
    int? replyToReviewId,
  }) async {
    // Валидация: если reply_to_review_id указан, проверяем что он существует и принадлежит тому же аэропорту
    if (replyToReviewId != null) {
      final replyCheck = await _connection.execute(
        Sql.named('SELECT id, airport_code FROM airport_reviews WHERE id = @reply_id'),
        parameters: {'reply_id': replyToReviewId},
      );
      if (replyCheck.isEmpty) {
        throw Exception('Reply review not found');
      }
      final replyData = replyCheck.first.toColumnMap();
      if (replyData['airport_code'] != airportCode) {
        throw Exception('Reply review does not belong to the same airport');
      }
    }

    // Проверяем существование аэропорта
    final airportCheck = await _connection.execute(
      Sql.named('SELECT id FROM airports WHERE ident = @code'),
      parameters: {'code': airportCode},
    );
    if (airportCheck.isEmpty) {
      throw Exception('Airport not found');
    }

    final photoUrlsJson = photoUrls != null && photoUrls.isNotEmpty ? jsonEncode(photoUrls) : null;

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO airport_reviews 
          (airport_code, reviewer_id, rating, comment, photo_urls, reply_to_review_id, created_at, updated_at)
        VALUES 
          (@airport_code, @reviewer_id, @rating, @comment, @photo_urls::jsonb, @reply_to_review_id, NOW(), NOW())
        RETURNING id, airport_code, reviewer_id, rating, comment, photo_urls, reply_to_review_id, created_at, updated_at
      '''),
      parameters: {
        'airport_code': airportCode,
        'reviewer_id': reviewerId,
        'rating': rating,
        'comment': comment,
        'photo_urls': photoUrlsJson,
        'reply_to_review_id': replyToReviewId,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create review');
    }

    final reviewData = result.first.toColumnMap();

    // Получаем данные о рецензенте
    final profileResult = await _connection.execute(
      Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @reviewer_id'),
      parameters: {'reviewer_id': reviewerId},
    );

    if (profileResult.isNotEmpty) {
      final profileData = profileResult.first.toColumnMap();
      reviewData['reviewer_first_name'] = profileData['first_name'];
      reviewData['reviewer_last_name'] = profileData['last_name'];
      reviewData['reviewer_avatar_url'] = profileData['avatar_url'];
    }

    return reviewData;
  }

  /// Обновить отзыв об аэропорте
  Future<Map<String, dynamic>> updateAirportReview({
    required int reviewId,
    required int rating,
    String? comment,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE airport_reviews
        SET rating = @rating, comment = @comment, updated_at = NOW()
        WHERE id = @review_id
        RETURNING id, airport_code, reviewer_id, rating, comment, photo_urls, reply_to_review_id, created_at, updated_at
      '''),
      parameters: {
        'review_id': reviewId,
        'rating': rating,
        'comment': comment,
      },
    );

    if (result.isEmpty) {
      throw Exception('Review not found');
    }

    final reviewData = result.first.toColumnMap();

    // Получаем данные о рецензенте
    final reviewerId = reviewData['reviewer_id'] as int;
    final profileResult = await _connection.execute(
      Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @reviewer_id'),
      parameters: {'reviewer_id': reviewerId},
    );

    if (profileResult.isNotEmpty) {
      final profileData = profileResult.first.toColumnMap();
      reviewData['reviewer_first_name'] = profileData['first_name'];
      reviewData['reviewer_last_name'] = profileData['last_name'];
      reviewData['reviewer_avatar_url'] = profileData['avatar_url'];
    }

    return reviewData;
  }

  /// Удалить отзыв об аэропорте
  Future<void> deleteAirportReview(int reviewId) async {
    final result = await _connection.execute(
      Sql.named('DELETE FROM airport_reviews WHERE id = @review_id'),
      parameters: {'review_id': reviewId},
    );

    if (result.affectedRows == 0) {
      throw Exception('Review not found');
    }
  }

  /// Добавить фотографии к отзыву
  Future<Map<String, dynamic>> addAirportReviewPhotos({
    required int reviewId,
    required List<String> photoUrls,
  }) async {
    // Получаем текущие фотографии
    final currentResult = await _connection.execute(
      Sql.named('SELECT photo_urls FROM airport_reviews WHERE id = @review_id'),
      parameters: {'review_id': reviewId},
    );

    if (currentResult.isEmpty) {
      throw Exception('Review not found');
    }

    final currentData = currentResult.first.toColumnMap();
    final currentPhotoUrls = _parsePhotoUrls(currentData['photo_urls']);

    // Объединяем старые и новые фотографии
    final allPhotoUrls = <String>[...?currentPhotoUrls, ...photoUrls];

    // Обновляем отзыв
    final updateResult = await _connection.execute(
      Sql.named('''
        UPDATE airport_reviews
        SET photo_urls = @photo_urls::jsonb, updated_at = NOW()
        WHERE id = @review_id
        RETURNING id, airport_code, reviewer_id, rating, comment, photo_urls, reply_to_review_id, created_at, updated_at
      '''),
      parameters: {
        'review_id': reviewId,
        'photo_urls': jsonEncode(allPhotoUrls),
      },
    );

    if (updateResult.isEmpty) {
      throw Exception('Failed to update review');
    }

    final reviewData = updateResult.first.toColumnMap();

    // Получаем данные о рецензенте
    final reviewerId = reviewData['reviewer_id'] as int;
    final profileResult = await _connection.execute(
      Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @reviewer_id'),
      parameters: {'reviewer_id': reviewerId},
    );

    if (profileResult.isNotEmpty) {
      final profileData = profileResult.first.toColumnMap();
      reviewData['reviewer_first_name'] = profileData['first_name'];
      reviewData['reviewer_last_name'] = profileData['last_name'];
      reviewData['reviewer_avatar_url'] = profileData['avatar_url'];
    }

    return reviewData;
  }

  /// Удалить фотографию из отзыва
  Future<Map<String, dynamic>> deleteAirportReviewPhoto({
    required int reviewId,
    required String photoUrl,
  }) async {
    // Получаем текущие фотографии
    final currentResult = await _connection.execute(
      Sql.named('SELECT photo_urls FROM airport_reviews WHERE id = @review_id'),
      parameters: {'review_id': reviewId},
    );

    if (currentResult.isEmpty) {
      throw Exception('Review not found');
    }

    final currentData = currentResult.first.toColumnMap();
    final currentPhotoUrls = _parsePhotoUrls(currentData['photo_urls']);

    // Удаляем фотографию из списка
    currentPhotoUrls?.remove(photoUrl);

    // Обновляем отзыв
    final updateResult = await _connection.execute(
      Sql.named('''
        UPDATE airport_reviews
        SET photo_urls = @photo_urls::jsonb, updated_at = NOW()
        WHERE id = @review_id
        RETURNING id, airport_code, reviewer_id, rating, comment, photo_urls, reply_to_review_id, created_at, updated_at
      '''),
      parameters: {
        'review_id': reviewId,
        'photo_urls': currentPhotoUrls != null && currentPhotoUrls.isNotEmpty ? jsonEncode(currentPhotoUrls) : null,
      },
    );

    if (updateResult.isEmpty) {
      throw Exception('Failed to update review');
    }

    final reviewData = updateResult.first.toColumnMap();

    // Получаем данные о рецензенте
    final reviewerId = reviewData['reviewer_id'] as int;
    final profileResult = await _connection.execute(
      Sql.named('SELECT first_name, last_name, avatar_url FROM profiles WHERE id = @reviewer_id'),
      parameters: {'reviewer_id': reviewerId},
    );

    if (profileResult.isNotEmpty) {
      final profileData = profileResult.first.toColumnMap();
      reviewData['reviewer_first_name'] = profileData['first_name'];
      reviewData['reviewer_last_name'] = profileData['last_name'];
      reviewData['reviewer_avatar_url'] = profileData['avatar_url'];
    }

    return reviewData;
  }

  /// Проверить, является ли пользователь автором отзыва
  Future<bool> isReviewAuthor(int reviewId, int userId) async {
    final result = await _connection.execute(
      Sql.named('SELECT reviewer_id FROM airport_reviews WHERE id = @review_id'),
      parameters: {'review_id': reviewId},
    );

    if (result.isEmpty) return false;

    final reviewData = result.first.toColumnMap();
    return reviewData['reviewer_id'] == userId;
  }

  /// Вспомогательный метод для парсинга photo_urls
  List<String>? _parsePhotoUrls(dynamic photoUrlsJson) {
    if (photoUrlsJson == null) return null;
    if (photoUrlsJson is List) {
      return photoUrlsJson.map((e) => e.toString()).toList();
    }
    if (photoUrlsJson is String) {
      try {
        final decoded = jsonDecode(photoUrlsJson);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
