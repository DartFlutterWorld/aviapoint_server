// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$AppSettingsControllerRouter(AppSettingsController service) {
  final router = Router();
  router.add(
    'GET',
    r'/api/app-settings',
    service.getAllSettings,
  );
  router.add(
    'GET',
    r'/api/app-settings/<key>',
    service.getSettingByKey,
  );
  router.add(
    'GET',
    r'/api/app-settings/<key>/value',
    service.getSettingValue,
  );
  return router;
}
