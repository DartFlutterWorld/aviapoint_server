// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ros_avia_test_cantroller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$RosAviaTestControllerRouter(RosAviaTestController service) {
  final router = Router();
  router.add(
    'GET',
    r'/learning/ros_avia_test/type_sertificates',
    service.fetchTypeSertificates,
  );
  router.add(
    'GET',
    r'/learning/ros_avia_test/type_correct_answers',
    service.fetchTypeCorrectAnswer,
  );
  router.add(
    'GET',
    r'/learning/ros_avia_test/categories/<typeCertificateId>',
    service.fetchRosAviaTestCategories,
  );
  router.add(
    'GET',
    r'/learning/ros_avia_test/<typeCertificateId>',
    service.fetchRosAviaTestCategoryWithQuestions,
  );
  router.add(
    'GET',
    r'/learning/ros_avia_test/questions/<typeCertificateId>',
    service.fetchQuestionsWithAnswersByCategoryAndTypeCertificate,
  );
  return router;
}
