// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$BlogControllerRouter(BlogController service) {
  final router = Router();
  router.add(
    'GET',
    r'/api/blog/categories',
    service.getCategories,
  );
  router.add(
    'GET',
    r'/api/blog/articles',
    service.getArticles,
  );
  router.add(
    'GET',
    r'/api/blog/articles/<id>',
    service.getArticleById,
  );
  router.add(
    'GET',
    r'/api/blog/tags',
    service.getTags,
  );
  router.add(
    'POST',
    r'/api/blog/articles',
    service.createArticle,
  );
  router.add(
    'PUT',
    r'/api/blog/articles/<id>',
    service.updateArticle,
  );
  router.add(
    'DELETE',
    r'/api/blog/articles/<id>',
    service.deleteArticle,
  );
  router.add(
    'POST',
    r'/api/blog/articles/<id>/content-images',
    service.uploadContentImage,
  );
  router.add(
    'POST',
    r'/api/blog/articles/content-images/upload',
    service.uploadContentImageTemporary,
  );
  return router;
}
