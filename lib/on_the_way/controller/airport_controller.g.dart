// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$AirportControllerRouter(AirportController service) {
  final router = Router();
  router.add(
    'GET',
    r'/api/airports',
    service.searchAirports,
  );
  router.add(
    'GET',
    r'/api/airports/<code>',
    service.getAirportByCode,
  );
  router.add(
    'GET',
    r'/api/airports/country/<country>',
    service.getAirportsByCountry,
  );
  return router;
}
