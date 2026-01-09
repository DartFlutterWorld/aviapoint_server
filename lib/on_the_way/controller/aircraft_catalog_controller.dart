import 'dart:convert';

import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/on_the_way/repositories/aircraft_catalog_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'aircraft_catalog_controller.g.dart';

class AircraftCatalogController {
  final AircraftCatalogRepository _repository;

  AircraftCatalogController({required AircraftCatalogRepository repository}) : _repository = repository;

  Router get router => _$AircraftCatalogControllerRouter(this);

  /// Получить всех производителей
  @Route.get('/api/aircraft/manufacturers')
  @OpenApiRoute()
  Future<Response> getManufacturers(Request request) async {
    return wrapResponse(() async {
      final manufacturers = await _repository.getManufacturers();

      return Response.ok(jsonEncode(manufacturers.map((m) => m.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить модели самолётов
  @Route.get('/api/aircraft/models')
  @OpenApiRoute()
  Future<Response> getAircraftModels(Request request) async {
    return wrapResponse(() async {
      final manufacturerIdStr = request.url.queryParameters['manufacturer_id'];
      final manufacturerId = manufacturerIdStr != null ? int.tryParse(manufacturerIdStr) : null;

      final searchQuery = request.url.queryParameters['q'];

      print('✈️ [AircraftCatalogController] GET /api/aircraft/models?manufacturer_id=$manufacturerId&q=$searchQuery');

      final models = await _repository.getAircraftModels(manufacturerId: manufacturerId, searchQuery: searchQuery);

      print('✈️ [AircraftCatalogController] Found ${models.length} models');

      return Response.ok(jsonEncode(models.map((m) => m.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить модель самолёта по ID
  @Route.get('/api/aircraft/models/<id>')
  @OpenApiRoute()
  Future<Response> getAircraftModelById(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Model ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid model ID'}), headers: jsonContentHeaders);
      }

      final model = await _repository.getAircraftModelById(id);

      if (model == null) {
        return Response.notFound(jsonEncode({'error': 'Aircraft model not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(model.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Поиск моделей самолётов для автодополнения
  @Route.get('/api/aircraft/search')
  @OpenApiRoute()
  Future<Response> searchAircraftModels(Request request) async {
    return wrapResponse(() async {
      final searchQuery = request.url.queryParameters['q'];
      if (searchQuery == null || searchQuery.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Search query parameter "q" is required'}), headers: jsonContentHeaders);
      }

      final models = await _repository.getAircraftModels(searchQuery: searchQuery);

      return Response.ok(jsonEncode(models.map((m) => m.toJson()).toList()), headers: jsonContentHeaders);
    });
  }
}
