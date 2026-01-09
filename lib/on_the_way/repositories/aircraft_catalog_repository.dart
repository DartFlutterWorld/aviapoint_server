import 'package:aviapoint_server/on_the_way/data/model/aircraft_manufacturer_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/aircraft_model.dart';
import 'package:postgres/postgres.dart';

class AircraftCatalogRepository {
  final Connection _connection;

  AircraftCatalogRepository({required Connection connection}) : _connection = connection;

  /// Получить всех производителей
  Future<List<AircraftManufacturerModel>> getManufacturers() async {
    final query = 'SELECT id, name FROM aircraft_manufacturers ORDER BY name';

    final result = await _connection.execute(Sql(query));

    return result.map((row) {
      return AircraftManufacturerModel.fromJson(row.toColumnMap());
    }).toList();
  }

  /// Получить модели самолётов
  Future<List<AircraftModel>> getAircraftModels({
    int? manufacturerId,
    String? searchQuery,
    int? limit,
  }) async {
    var query = '''
      SELECT 
        am.id as am_id,
        am.manufacturer_id as am_manufacturer_id,
        am.model_code as am_model_code,
        m.id as m_id,
        m.name as m_name
      FROM aircraft_models am
      INNER JOIN aircraft_manufacturers m ON am.manufacturer_id = m.id
      WHERE 1=1
    ''';

    final parameters = <String, dynamic>{};

    if (manufacturerId != null) {
      query += ' AND am.manufacturer_id = @manufacturer_id';
      parameters['manufacturer_id'] = manufacturerId;
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND (am.model_code ILIKE @search OR m.name ILIKE @search)';
      parameters['search'] = '%$searchQuery%';
    }

    query += ' ORDER BY m.name, am.model_code';

    if (limit != null && limit > 0) {
      query += ' LIMIT @limit';
      parameters['limit'] = limit;
    }

    try {
      final result = await _connection.execute(
        Sql.named(query),
        parameters: parameters,
      );

      return result.map((row) {
        final map = row.toColumnMap();
        // Преобразуем JOIN результат в формат для fromJson
        final jsonMap = <String, dynamic>{
          'id': map['am_id'],
          'manufacturer_id': map['am_manufacturer_id'],
          'model_code': map['am_model_code'],
          // Поля производителя
          'm_id': map['m_id'],
          'm_name': map['m_name'],
        };
        return AircraftModel.fromJson(jsonMap);
      }).toList();
    } catch (e, stack) {
      print('❌ [AircraftCatalogRepository] Error in getAircraftModels: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  /// Получить модель самолёта по ID
  Future<AircraftModel?> getAircraftModelById(int id) async {
    try {
      final result = await _connection.execute(
        Sql.named('''
          SELECT 
            am.id as am_id,
            am.manufacturer_id as am_manufacturer_id,
            am.model_code as am_model_code,
            m.id as m_id,
            m.name as m_name
          FROM aircraft_models am
          INNER JOIN aircraft_manufacturers m ON am.manufacturer_id = m.id
          WHERE am.id = @id
        '''),
        parameters: {'id': id},
      );

      if (result.isEmpty) {
        return null;
      }

      final map = result.first.toColumnMap();
      final jsonMap = <String, dynamic>{
        'id': map['am_id'],
        'manufacturer_id': map['am_manufacturer_id'],
        'model_code': map['am_model_code'],
        'm_id': map['m_id'],
        'm_name': map['m_name'],
      };
      return AircraftModel.fromJson(jsonMap);
    } catch (e, stack) {
      print('❌ [AircraftCatalogRepository] Error in getAircraftModelById: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}

