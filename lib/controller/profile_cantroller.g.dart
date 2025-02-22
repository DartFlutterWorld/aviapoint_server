// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_cantroller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$ProfileControllerRouter(ProfileController service) {
  final router = Router();
  router.add(
    'POST',
    r'/user',
    service.createUser,
  );
  router.add(
    'GET',
    r'/profiles',
    service.getUsers,
  );
  router.add(
    'DELETE',
    r'/user/<userId>',
    service.deleteUser,
  );
  return router;
}
