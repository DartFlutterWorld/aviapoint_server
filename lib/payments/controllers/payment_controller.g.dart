// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$PaymentControllerRouter(PaymentController service) {
  final router = Router();
  router.add(
    'POST',
    r'/api/payments/create',
    service.createPayment,
  );
  router.add(
    'GET',
    r'/api/payments/<paymentId>/status',
    service.getPaymentStatus,
  );
  router.add(
    'GET',
    r'/api/payments/return',
    service.paymentReturn,
  );
  router.add(
    'GET',
    r'/api/payments/cancel',
    service.paymentCancel,
  );
  router.add(
    'POST',
    r'/api/payments/webhook',
    service.webhook,
  );
  router.add(
    'POST',
    r'/api/payments/verify-iap',
    service.verifyIAP,
  );
  return router;
}
