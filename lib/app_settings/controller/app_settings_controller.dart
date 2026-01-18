import 'dart:convert';

import 'package:aviapoint_server/app_settings/data/repositories/app_settings_repository.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'app_settings_controller.g.dart';

class AppSettingsController {
  final AppSettingsRepository _repository;

  AppSettingsController({required AppSettingsRepository repository}) : _repository = repository;

  Router get router => _$AppSettingsControllerRouter(this);

  /// Получить все настройки приложения
  @Route.get('/api/app-settings')
  @OpenApiRoute()
  Future<Response> getAllSettings(Request request) async {
    return wrapResponse(() async {
      final settings = await _repository.getAllSettings();
      return Response.ok(
        jsonEncode(settings.map((s) => s.toJson()).toList()),
        headers: jsonContentHeaders,
      );
    });
  }

  /// Получить настройку по ключу
  @Route.get('/api/app-settings/<key>')
  @OpenApiRoute()
  Future<Response> getSettingByKey(Request request) async {
    return wrapResponse(() async {
      final key = request.params['key'];
      if (key == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Key parameter is required'}),
          headers: jsonContentHeaders,
        );
      }
      final setting = await _repository.getSettingByKey(key);
      if (setting == null) {
        return Response.notFound(
          jsonEncode({'error': 'Setting not found'}),
          headers: jsonContentHeaders,
        );
      }
      return Response.ok(jsonEncode(setting.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Получить значение настройки по ключу (упрощенный endpoint, возвращает только значение)
  @Route.get('/api/app-settings/<key>/value')
  @OpenApiRoute()
  Future<Response> getSettingValue(Request request) async {
    return wrapResponse(() async {
      final key = request.params['key'];
      if (key == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Key parameter is required'}),
          headers: jsonContentHeaders,
        );
      }
      final value = await _repository.getSettingValue(key);
      print('🔵 [AppSettingsController] getSettingValue: key=$key, value=$value, type=${value.runtimeType}');
      final response = {'key': key, 'value': value};
      print('🔵 [AppSettingsController] Response JSON: ${jsonEncode(response)}');
      return Response.ok(
        jsonEncode(response),
        headers: jsonContentHeaders,
      );
    });
  }
}
