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
      WHERE is_active = true
    ''';
    final parameters = <String, dynamic>{};

    if (country != null && country.isNotEmpty) {
      sql += ' AND iso_country = @country';
      parameters['country'] = country;
    }

    if (type != null && type.isNotEmpty) {
      sql += ' AND type = @type';
      parameters['type'] = type;
    }

    if (query != null && query.isNotEmpty) {
      sql += ''' AND (
        ident ILIKE @query OR
        name ILIKE @query OR
        iata_code ILIKE @query OR
        gps_code ILIKE @query OR
        local_code ILIKE @query OR
        municipality ILIKE @query
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
    final result = await _connection.execute(Sql.named('SELECT * FROM airports WHERE ident = @ident AND is_active = true'), parameters: {'ident': ident});

    if (result.isEmpty) return null;

    return AirportModel.fromJson(result.first.toColumnMap());
  }

  /// Получить аэропорт по ID
  Future<AirportModel?> getAirportById(int id) async {
    final result = await _connection.execute(Sql.named('SELECT * FROM airports WHERE id = @id AND is_active = true'), parameters: {'id': id});

    if (result.isEmpty) return null;

    return AirportModel.fromJson(result.first.toColumnMap());
  }

  /// Получить все аэропорты страны
  Future<List<AirportModel>> getAirportsByCountry(String countryCode, {int? limit}) async {
    var sql = '''
      SELECT * FROM airports
      WHERE iso_country = @country AND is_active = true
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
}
