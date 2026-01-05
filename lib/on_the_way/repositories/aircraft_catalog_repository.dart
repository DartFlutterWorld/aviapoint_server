import 'package:aviapoint_server/on_the_way/data/model/aircraft_manufacturer_model.dart';
import 'package:aviapoint_server/on_the_way/data/model/aircraft_model.dart';
import 'package:postgres/postgres.dart';

class AircraftCatalogRepository {
  final Connection _connection;

  AircraftCatalogRepository({required Connection connection}) : _connection = connection;

  /// Получить всех производителей
  Future<List<AircraftManufacturerModel>> getManufacturers({bool activeOnly = true}) async {
    final query = activeOnly
        ? 'SELECT id, name, country, website, description, is_active, created_at, updated_at FROM manufacturers WHERE is_active = true ORDER BY name'
        : 'SELECT id, name, country, website, description, is_active, created_at, updated_at FROM manufacturers ORDER BY name';

    final result = await _connection.execute(Sql(query));

    return result.map((row) {
      return AircraftManufacturerModel.fromJson(row.toColumnMap());
    }).toList();
  }

  /// Получить модели самолётов
  Future<List<AircraftModel>> getAircraftModels({
    int? manufacturerId,
    String? category,
    String? engineType,
    bool activeOnly = true,
    String? searchQuery,
    int? limit,
  }) async {
    var query = '''
      SELECT 
        am.id as am_id,
        am.manufacturer_id as am_manufacturer_id,
        am.model_code as am_model_code,
        am.full_name as am_full_name,
        am.category as am_category,
        am.engine_type as am_engine_type,
        am.engine_count as am_engine_count,
        am.is_active as am_is_active,
        am.created_at as am_created_at,
        am.updated_at as am_updated_at,
        m.id as m_id,
        m.name as m_name,
        m.country as m_country,
        m.website as m_website,
        m.description as m_description,
        m.is_active as m_is_active,
        m.created_at as m_created_at,
        m.updated_at as m_updated_at
      FROM aircraft_models am
      INNER JOIN manufacturers m ON am.manufacturer_id = m.id
      WHERE 1=1
    ''';

    final parameters = <String, dynamic>{};

    if (activeOnly) {
      query += ' AND am.is_active = true AND m.is_active = true';
    }

    if (manufacturerId != null) {
      query += ' AND am.manufacturer_id = @manufacturer_id';
      parameters['manufacturer_id'] = manufacturerId;
    }

    if (category != null && category.isNotEmpty) {
      query += ' AND am.category = @category';
      parameters['category'] = category;
    }

    if (engineType != null && engineType.isNotEmpty) {
      query += ' AND am.engine_type = @engine_type';
      parameters['engine_type'] = engineType;
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND (am.full_name ILIKE @search OR am.model_code ILIKE @search OR m.name ILIKE @search)';
      parameters['search'] = '%$searchQuery%';
    }

    query += ' ORDER BY m.name, am.full_name';

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
          'full_name': map['am_full_name'],
          'category': map['am_category'],
          'engine_type': map['am_engine_type'],
          'engine_count': map['am_engine_count'],
          'is_active': map['am_is_active'],
          'created_at': map['am_created_at'],
          'updated_at': map['am_updated_at'],
          // Поля производителя
          'm_id': map['m_id'],
          'm_name': map['m_name'],
          'm_country': map['m_country'],
          'm_website': map['m_website'],
          'm_description': map['m_description'],
          'm_is_active': map['m_is_active'],
          'm_created_at': map['m_created_at'],
          'm_updated_at': map['m_updated_at'],
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
            am.full_name as am_full_name,
            am.category as am_category,
            am.engine_type as am_engine_type,
            am.engine_count as am_engine_count,
            am.is_active as am_is_active,
            am.created_at as am_created_at,
            am.updated_at as am_updated_at,
            m.id as m_id,
            m.name as m_name,
            m.country as m_country,
            m.website as m_website,
            m.description as m_description,
            m.is_active as m_is_active,
            m.created_at as m_created_at,
            m.updated_at as m_updated_at
          FROM aircraft_models am
          INNER JOIN manufacturers m ON am.manufacturer_id = m.id
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
        'full_name': map['am_full_name'],
        'category': map['am_category'],
        'engine_type': map['am_engine_type'],
        'engine_count': map['am_engine_count'],
        'is_active': map['am_is_active'],
        'created_at': map['am_created_at'],
        'updated_at': map['am_updated_at'],
        'm_id': map['m_id'],
        'm_name': map['m_name'],
        'm_country': map['m_country'],
        'm_website': map['m_website'],
        'm_description': map['m_description'],
        'm_is_active': map['m_is_active'],
        'm_created_at': map['m_created_at'],
        'm_updated_at': map['m_updated_at'],
      };
      return AircraftModel.fromJson(jsonMap);
    } catch (e, stack) {
      print('❌ [AircraftCatalogRepository] Error in getAircraftModelById: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}

