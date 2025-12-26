// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$FeedbackControllerRouter(FeedbackController service) {
  final router = Router();
  router.add(
    'POST',
    r'/api/feedback',
    service.submitFeedback,
  );
  return router;
}
