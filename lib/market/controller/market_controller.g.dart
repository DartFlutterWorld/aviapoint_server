// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$MarketControllerRouter(MarketController service) {
  final router = Router();
  router.add(
    'GET',
    r'/api/market/categories/main',
    service.getMainCategories,
  );
  router.add(
    'GET',
    r'/api/market/categories',
    service.getAllCategories,
  );
  router.add(
    'GET',
    r'/api/market/categories/<id>',
    service.getCategoryById,
  );
  router.add(
    'GET',
    r'/api/market/aircraft',
    service.getProducts,
  );
  router.add(
    'GET',
    r'/api/market/aircraft/<id>',
    service.getProductById,
  );
  router.add(
    'GET',
    r'/api/market/aircraft/<id>/price-history',
    service.getPriceHistory,
  );
  router.add(
    'POST',
    r'/api/market/aircraft',
    service.createAircraft,
  );
  router.add(
    'POST',
    r'/api/market/aircraft/<id>/favorite',
    service.addToFavorites,
  );
  router.add(
    'DELETE',
    r'/api/market/aircraft/<id>/favorite',
    service.removeFromFavorites,
  );
  router.add(
    'GET',
    r'/api/market/favorites',
    service.getFavorites,
  );
  router.add(
    'PUT',
    r'/api/market/aircraft/<id>',
    service.updateProduct,
  );
  router.add(
    'POST',
    r'/api/market/aircraft/<id>/publish',
    service.publishProduct,
  );
  router.add(
    'POST',
    r'/api/market/aircraft/<id>/unpublish',
    service.unpublishProduct,
  );
  router.add(
    'DELETE',
    r'/api/market/aircraft/<id>',
    service.deleteProduct,
  );
  router.add(
    'POST',
    r'/api/market/products/<id>/main-image',
    service.uploadMainImage,
  );
  router.add(
    'POST',
    r'/api/market/products/<id>/additional-images',
    service.uploadAdditionalImages,
  );
  return router;
}
