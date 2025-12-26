import 'dart:convert';
import 'package:aviapoint_server/on_the_way/data/model/airport_ownership_request_model.dart';
import 'package:postgres/postgres.dart';

class AirportOwnershipRepository {
  final Connection _connection;

  AirportOwnershipRepository({required Connection connection}) : _connection = connection;

  /// Подать заявку на владение аэродромом
  Future<AirportOwnershipRequestModel> submitOwnershipRequest({
    required int userId,
    required int airportId,
    required String airportCode, // Код ICAO аэропорта
    required String email,
    required String phone, // Телефон из профиля
    String? phoneFromRequest, // Телефон из формы заявки
    String? fullName, // ФИО из формы заявки
    String? comment,
    List<String>? documentUrls,
  }) async {
    // Проверяем, нет ли уже активной заявки
    final existingRequest = await _connection.execute(
      Sql.named('''
        SELECT id FROM airport_ownership_requests
        WHERE user_id = @user_id AND airport_id = @airport_id AND status = 'pending'
      '''),
      parameters: {'user_id': userId, 'airport_id': airportId},
    );

    if (existingRequest.isNotEmpty) {
      throw Exception('Заявка на этот аэродром уже подана и находится на рассмотрении');
    }

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO airport_ownership_requests (user_id, airport_id, airport_code, email, phone, phone_from_request, full_name, comment, documents, status)
        VALUES (@user_id, @airport_id, @airport_code, @email, @phone, @phone_from_request, @full_name, @comment, @documents::jsonb, 'pending')
        RETURNING *
      '''),
      parameters: {
        'user_id': userId,
        'airport_id': airportId,
        'airport_code': airportCode,
        'email': email,
        'phone': phone,
        'phone_from_request': phoneFromRequest,
        'full_name': fullName,
        'comment': comment,
        'documents': documentUrls != null && documentUrls.isNotEmpty ? jsonEncode(documentUrls) : null,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create ownership request');
    }

    return AirportOwnershipRequestModel.fromJson(result.first.toColumnMap());
  }

  /// Получить заявку пользователя на аэродром
  Future<AirportOwnershipRequestModel?> getOwnershipRequest(int userId, int airportId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT * FROM airport_ownership_requests
        WHERE user_id = @user_id AND airport_id = @airport_id
        ORDER BY created_at DESC
        LIMIT 1
      '''),
      parameters: {'user_id': userId, 'airport_id': airportId},
    );

    if (result.isEmpty) return null;

    return AirportOwnershipRequestModel.fromJson(result.first.toColumnMap());
  }

  /// Одобрить заявку на владение (добавить аэродром в owned_airports пользователя)
  Future<void> approveOwnershipRequest(int requestId, int reviewedBy) async {
    // Получаем заявку
    final result = await _connection.execute(
      Sql.named('''
        SELECT * FROM airport_ownership_requests
        WHERE id = @id
      '''),
      parameters: {'id': requestId},
    );

    if (result.isEmpty) {
      throw Exception('Request not found');
    }

    final request = AirportOwnershipRequestModel.fromJson(result.first.toColumnMap());

    if (request.status != 'pending') {
      throw Exception('Request is not pending');
    }

    // Начинаем транзакцию
    await _connection.execute(Sql.named('BEGIN'));

    try {
      // Обновляем статус заявки
      await _connection.execute(
        Sql.named('''
          UPDATE airport_ownership_requests
          SET status = 'approved',
              reviewed_at = NOW(),
              reviewed_by = @reviewed_by,
              updated_at = NOW()
          WHERE id = @id
        '''),
        parameters: {'id': requestId, 'reviewed_by': reviewedBy},
      );

      // Получаем текущий список owned_airports пользователя
      final profileResult = await _connection.execute(
        Sql.named('''
          SELECT owned_airports
          FROM profiles
          WHERE id = @user_id
        '''),
        parameters: {'user_id': request.userId},
      );

      List<int> ownedAirports = [];
      if (profileResult.isNotEmpty) {
        final ownedAirportsJson = profileResult.first.toColumnMap()['owned_airports'];
        if (ownedAirportsJson != null) {
          if (ownedAirportsJson is List) {
            ownedAirports = ownedAirportsJson.map((e) => e as int).toList();
          } else if (ownedAirportsJson is String) {
            ownedAirports = (jsonDecode(ownedAirportsJson) as List).map((e) => e as int).toList();
          }
        }
      }

      // Добавляем новый аэродром, если его еще нет
      if (!ownedAirports.contains(request.airportId)) {
        ownedAirports.add(request.airportId);

        // Обновляем профиль пользователя
        await _connection.execute(
          Sql.named('''
            UPDATE profiles
            SET owned_airports = @owned_airports::jsonb
            WHERE id = @user_id
          '''),
          parameters: {
            'user_id': request.userId,
            'owned_airports': jsonEncode(ownedAirports),
          },
        );

        // Обновляем owner_id в таблице airports
        await _connection.execute(
          Sql.named('''
            UPDATE airports
            SET owner_id = @owner_id, updated_at = NOW()
            WHERE id = @airport_id
          '''),
          parameters: {
            'airport_id': request.airportId,
            'owner_id': request.userId,
          },
        );
      }

      await _connection.execute(Sql.named('COMMIT'));
    } catch (e) {
      await _connection.execute(Sql.named('ROLLBACK'));
      rethrow;
    }
  }

  /// Отклонить заявку на владение
  Future<void> rejectOwnershipRequest(int requestId, int reviewedBy, {String? adminNotes}) async {
    await _connection.execute(
      Sql.named('''
        UPDATE airport_ownership_requests
        SET status = 'rejected',
            reviewed_at = NOW(),
            reviewed_by = @reviewed_by,
            admin_notes = @admin_notes,
            updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {
        'id': requestId,
        'reviewed_by': reviewedBy,
        'admin_notes': adminNotes,
      },
    );
  }
}

