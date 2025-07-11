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
    service.fetchPreflightInspectionCaegories,
  );
  router.add(
    'GET',
    r'/learning/hand_book/preflight_inspection_categories/check_list',
    service.fetchPreflightInspectionCheckList,
  );
  router.add(
    'GET',
    r'/learning/hand_book/preflight_inspection_categories/check_list/<id>',
    service.fetchPreflightInspectionCheckListById,
  );
  router.add(
    'GET',
    r'/learning/hand_book/normal_categories',
    service.fetchNormalCategories,
  );
  router.add(
    'GET',
    r'/learning/hand_book/normal_categories/check_list',
    service.fetchNormalCheckList,
  );
  router.add(
    'GET',
    r'/learning/hand_book/normal_categories/check_list/<id>',
    service.fetchNormalCheckListById,
  );
  router.add(
    'GET',
    r'/learning/hand_book/emergency_categories',
    service.fetchEmergencyCategories,
  );
  return router;
}
