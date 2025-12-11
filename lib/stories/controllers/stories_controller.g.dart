// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stories_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$StoriesControllerRouter(StoriesController service) {
  final router = Router();
  router.add(
    'GET',
    r'/api/stories',
    service.getStories,
  );
  router.add(
    'GET',
    r'/api/stories/<id>',
    service.getStory,
  );
  return router;
}
