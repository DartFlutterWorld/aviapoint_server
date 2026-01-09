import 'package:aviapoint_server/app_settings/data/model/app_settings_model.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:postgres/postgres.dart';

class AppSettingsRepository {
  final Connection _connection;

  AppSettingsRepository({required Connection connection}) : _connection = connection;

  /// Получить все настройки приложения
  Future<List<AppSettingsModel>> getAllSettings() async {
    final result = await _connection.execute(
      Sql.named('SELECT * FROM app_settings ORDER BY key'),
    );

    return result.map((row) => AppSettingsModel.fromJson(row.toColumnMap())).toList();
  }

  /// Получить настройку по ключу
  Future<AppSettingsModel?> getSettingByKey(String key) async {
    final result = await _connection.execute(
      Sql.named('SELECT * FROM app_settings WHERE key = @key'),
      parameters: {'key': key},
    );

    if (result.isEmpty) {
      return null;
    }

    return AppSettingsModel.fromJson(result.first.toColumnMap());
  }

  /// Получить значение настройки по ключу (возвращает false, если настройка не найдена)
  Future<bool> getSettingValue(String key) async {
    final setting = await getSettingByKey(key);
    return setting?.value ?? false;
  }

  /// Обновить значение настройки
  Future<AppSettingsModel> updateSetting({
    required String key,
    required bool value,
    String? description,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE app_settings 
        SET value = @value, 
            description = COALESCE(@description, description),
            updated_at = NOW()
        WHERE key = @key
        RETURNING *
      '''),
      parameters: {
        'key': key,
        'value': value,
        'description': description,
      },
    );

    if (result.isEmpty) {
      throw Exception('Setting with key "$key" not found');
    }

    return AppSettingsModel.fromJson(result.first.toColumnMap());
  }

  /// Создать новую настройку
  Future<AppSettingsModel> createSetting({
    required String key,
    required bool value,
    String? description,
  }) async {
    try {
      final result = await _connection.execute(
        Sql.named('''
          INSERT INTO app_settings (key, value, description)
          VALUES (@key, @value, @description)
          RETURNING *
        '''),
        parameters: {
          'key': key,
          'value': value,
          'description': description,
        },
      );

      return AppSettingsModel.fromJson(result.first.toColumnMap());
    } catch (e) {
      logger.severe('Error creating app setting: $e');
      rethrow;
    }
  }
}
