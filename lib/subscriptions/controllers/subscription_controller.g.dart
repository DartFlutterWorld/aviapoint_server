// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$SubscriptionControllerRouter(SubscriptionController service) {
  final router = Router();
  router.add(
    'GET',
    r'/subscriptions/status',
    service.getSubscriptionStatus,
  );
  router.add(
    'GET',
    r'/subscriptions/active',
    service.getActiveSubscription,
  );
  router.add(
    'GET',
    r'/subscriptions/history',
    service.getSubscriptionHistory,
  );
  router.add(
    'GET',
    r'/subscriptions/types',
    service.getSubscriptionTypes,
  );
  return router;
}
