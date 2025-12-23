import 'dart:convert';

import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/on_the_way/repositories/airport_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'airport_controller.g.dart';

class AirportController {
  final AirportRepository _airportRepository;

  AirportController({required AirportRepository airportRepository}) : _airportRepository = airportRepository;

  Router get router => _$AirportControllerRouter(this);

  /// Поиск аэропортов
  @Route.get('/api/airports')
  @OpenApiRoute()
  Future<Response> searchAirports(Request request) async {
    return wrapResponse(() async {
      final query = request.url.queryParameters['q'];
      final country = request.url.queryParameters['country'];
      final type = request.url.queryParameters['type'];
      final limitStr = request.url.queryParameters['limit'];
      final limit = limitStr != null ? int.tryParse(limitStr) : 50;

      final airports = await _airportRepository.searchAirports(query: query, country: country, type: type, limit: limit ?? 50);

      return Response.ok(jsonEncode(airports.map((a) => a.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить аэропорт по коду
  @Route.get('/api/airports/<code>')
  @OpenApiRoute()
  Future<Response> getAirportByCode(Request request) async {
    return wrapResponse(() async {
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
      }

      final airport = await _airportRepository.getAirportByCode(code);

      if (airport == null) {
        return Response.notFound(jsonEncode({'error': 'Аэропорт с кодом $code не найден'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(airport.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Получить все аэропорты страны
  @Route.get('/api/airports/country/<country>')
  @OpenApiRoute()
  Future<Response> getAirportsByCountry(Request request) async {
    return wrapResponse(() async {
      final country = request.params['country'];
      if (country == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Country code is required'}), headers: jsonContentHeaders);
      }

      final limitStr = request.url.queryParameters['limit'];
      final limit = limitStr != null ? int.tryParse(limitStr) : null;

      final airports = await _airportRepository.getAirportsByCountry(country, limit: limit);

      return Response.ok(jsonEncode(airports.map((a) => a.toJson()).toList()), headers: jsonContentHeaders);
    });
  }
}
