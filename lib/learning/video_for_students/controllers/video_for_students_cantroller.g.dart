// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_for_students_cantroller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$VideoForStudentsControllerRouter(VideoForStudentsController service) {
  final router = Router();
  router.add(
    'GET',
    r'/learning/video_for_students',
    service.getVideoForStudents,
  );
  router.add(
    'GET',
    r'/learning/video_for_students/<id>',
    service.getVideoById,
  );
  return router;
}
