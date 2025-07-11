// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$AuthControllerRouter(AuthController service) {
  final router = Router();
  router.add(
    'POST',
    r'/auth/sms',
    service.sendSms,
  );
  router.add(
    'POST',
    r'/auth/login',
    service.login,
  );
  router.add(
    'POST',
    r'/auth/refresh',
    service.refreshToken,
  );
  return router;
}
