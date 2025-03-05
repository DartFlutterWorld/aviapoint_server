// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hand_book_cantroller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$HandBookControllerRouter(HandBookController service) {
  final router = Router();
  router.add(
    'GET',
    r'/learning/hand_book/main_categories',
    service.fetchHandBookCategoties,
  );
  router.add(
    'GET',
    r'/learning/hand_book/preflight_inspection_categories',
    service.fetchPreflightInspectionCaegoriesModel,
  );
  return router;
}
