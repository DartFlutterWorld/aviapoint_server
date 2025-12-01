// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$PaymentControllerRouter(PaymentController service) {
  final router = Router();
  router.add(
    'POST',
    r'/payments/create',
    service.createPayment,
  );
  router.add(
    'GET',
    r'/payments/<paymentId>/status',
    service.getPaymentStatus,
  );
  router.add(
    'POST',
    r'/payments/webhook',
    service.webhook,
  );
  return router;
}
