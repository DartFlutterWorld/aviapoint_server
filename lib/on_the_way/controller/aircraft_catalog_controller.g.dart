// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aircraft_catalog_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$AircraftCatalogControllerRouter(AircraftCatalogController service) {
  final router = Router();
  router.add(
    'GET',
    r'/api/aircraft/manufacturers',
    service.getManufacturers,
  );
  router.add(
    'GET',
    r'/api/aircraft/models',
    service.getAircraftModels,
  );
  router.add(
    'GET',
    r'/api/aircraft/models/<id>',
    service.getAircraftModelById,
  );
  router.add(
    'GET',
    r'/api/aircraft/search',
    service.searchAircraftModels,
  );
  return router;
}
