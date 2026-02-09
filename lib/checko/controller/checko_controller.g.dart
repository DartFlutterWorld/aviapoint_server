// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checko_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$CheckoControllerRouter(CheckoController service) {
  final router = Router();
  router.add(
    'GET',
    r'/api/checko/company',
    service.getCompany,
  );
  router.add(
    'GET',
    r'/api/checko/entrepreneur',
    service.getEntrepreneur,
  );
  router.add(
    'GET',
    r'/api/checko/by-inn',
    service.getByInn,
  );
  return router;
}
