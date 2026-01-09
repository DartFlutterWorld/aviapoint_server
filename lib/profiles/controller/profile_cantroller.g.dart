// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_cantroller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$ProfileControllerRouter(ProfileController service) {
  final router = Router();
  router.add(
    'POST',
    r'/api/user',
    service.createUser,
  );
  router.add(
    'GET',
    r'/api/profiles',
    service.getUsers,
  );
  router.add(
    'POST',
    r'/api/profile',
    service.getProfile,
  );
  router.add(
    'PUT',
    r'/api/profile',
    service.updateProfile,
  );
  router.add(
    'POST',
    r'/api/profile/photo',
    service.uploadProfilePhoto,
  );
  router.add(
    'POST',
    r'/api/profile/fcm-token',
    service.saveFcmToken,
  );
  router.add(
    'DELETE',
    r'/api/profile',
    service.deleteAccount,
  );
  return router;
}
