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
  router.add(
    'POST',
    r'/api/airports/<code>/feedback',
    service.submitAirportFeedback,
  );
  router.add(
    'POST',
    r'/api/airports/<code>/photos',
    service.uploadAirportPhotos,
  );
  router.add(
    'DELETE',
    r'/api/airports/<code>/photos',
    service.deleteAirportPhoto,
  );
  router.add(
    'POST',
    r'/api/airports/<code>/visitor-photos',
    service.uploadVisitorPhotos,
  );
  router.add(
    'DELETE',
    r'/api/airports/<code>/visitor-photos',
    service.deleteVisitorPhoto,
  );
  router.add(
    'GET',
    r'/api/airports/<code>/is-owner',
    service.checkIsOwner,
  );
  router.add(
    'PUT',
    r'/api/airports/<code>',
    service.updateAirport,
  );
  router.add(
    'POST',
    r'/api/airports/<code>/ownership-request',
    service.submitOwnershipRequest,
  );
  return router;
}
