// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$NewsControllerRouter(NewsController service) {
  final router = Router();
  router.add(
    'GET',
    r'/api/category_news',
    service.getCategoryNews,
  );
  router.add(
    'GET',
    r'/api/news',
    service.getnews,
  );
  router.add(
    'GET',
    r'/api/news/<id>',
    service.getNewsById,
  );
  router.add(
    'GET',
    r'/api/news/category/<id>',
    service.getNewsByCategory,
  );
  return router;
}
