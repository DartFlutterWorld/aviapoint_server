import 'dart:async';
import 'dart:convert';

import 'package:airpoint_server/core/wrap_response.dart';
import 'package:airpoint_server/learning/ros_avia_test/repositories/ros_avia_test_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'ros_avia_test_cantroller.g.dart';

class RosAviaTestController {
  final RosAviaTestRepository _rosAviaTestRepository;
  RosAviaTestController({required RosAviaTestRepository rosAviaTestRepository}) : _rosAviaTestRepository = rosAviaTestRepository;

  Router get router => _$RosAviaTestControllerRouter(this);

  ///
  /// РосАвиаТест. Получение типов свидетельтв
  ///
  /// Получение всех Получение типов свидетельтв в РосАвиаТест
  ///

  @Route.get('/learning/ros_avia_test/type_sertificates')
  @OpenApiRoute()
  Future<Response> fetchTypeSertificates(Request request) async {
    final body = await _rosAviaTestRepository.fetchTypeSertificates();

    return wrapResponse(
      () async {
        return Response.ok(
          jsonEncode(body),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  ///
  /// РосАвиаТест. Получение типов корректности ответа
  ///
  /// Получение всех Получение типов корректности ответа
  ///

  @Route.get('/learning/ros_avia_test/type_correct_answers')
  @OpenApiRoute()
  Future<Response> fetchTypeCorrectAnswer(Request request) async {
    final body = await _rosAviaTestRepository.fetchTypeCorrectAnswer();

    return wrapResponse(
      () async {
        return Response.ok(
          jsonEncode(body),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  // ///
  // /// РосАвиаТест. Получение категорий для Частного пилота (самолёт)
  // ///
  // /// РосАвиаТест. Получение категорий для Частного пилота (самолёт)
  // ///

  @Route.get('/learning/ros_avia_test/categories/<typeCertificateId>')
  @OpenApiRoute()
  Future<Response> fetchRosAviaTestCategories(Request request) async {
    final id = request.params['typeCertificateId']!;
    final body = await _rosAviaTestRepository.fetchRosAviaTestCategories(int.parse(id));

    return wrapResponse(
      () async {
        return Response.ok(
          jsonEncode(body),
          headers: jsonContentHeaders,
        );
      },
    );
  }
  // ///
  // /// РосАвиаТест. Получение категорий для Частного пилота (самолёт)
  // ///
  // /// РосАвиаТест. Получение категорий для Частного пилота (самолёт)
  // ///

  @Route.get('/learning/ros_avia_test/<typeCertificateId>')
  @OpenApiRoute()
  Future<Response> fetchRosAviaTestCategoryWithQuestions(Request request) async {
    final id = request.params['typeCertificateId']!;
    final body = await _rosAviaTestRepository.fetchRosAviaTestCategoryWithQuestions(int.parse(id));

    return wrapResponse(
      () async {
        return Response.ok(
          jsonEncode(body),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  // ///
  // /// РосАвиаТест. Получение чек листа в Preflight inspetion
  // ///
  // /// РосАвиаТест. Получение чек листа для Предполётных процедур
  // ///

  // @Route.get('/learning/hand_book/preflight_inspection_categories/check_list')
  // @OpenApiRoute()
  // Future<Response> fetchPreflightInspectionCheckList(Request request) async {
  //   final body = await _rosAviaTestRepository.fetchPreflightInspectionCheckList();

  //   return wrapResponse(
  //     () async {
  //       return Response.ok(
  //         jsonEncode(body),
  //         headers: jsonContentHeaders,
  //       );
  //     },
  //   );
  // }

  // ///
  // /// Получение конкретной проверки из чеклиста
  // ///
  // /// Получение конкретной проверки из чеклиста по id
  // ///

  // @Route.get('/learning/hand_book/preflight_inspection_categories/check_list/<id>')
  // @OpenApiRoute()
  // Future<Response> fetchPreflightInspectionCheckListById(Request request, String id) async {
  //   return wrapResponse(
  //     () async {
  //       // final id = request.context['id'] as String;
  //       // final id2 = int.parse(request.params['id']!);

  //       return Response.ok(
  //         jsonEncode(await _rosAviaTestRepository.fetchPreflightInspectionCheckListById(int.parse(id))),
  //         headers: jsonContentHeaders,
  //       );
  //     },
  //   );
  // }

  // ///
  // /// РосАвиаТест. Получение категорий для Нормальных процедур
  // ///
  // /// РосАвиаТест. Получение категорий для Нормальных процедур
  // ///

  // @Route.get('/learning/hand_book/normal_categories')
  // @OpenApiRoute()
  // Future<Response> fetchNormalCategories(Request request) async {
  //   final body = await _rosAviaTestRepository.fetchNormalCategories();

  //   return wrapResponse(
  //     () async {
  //       return Response.ok(
  //         jsonEncode(body),
  //         headers: jsonContentHeaders,
  //       );
  //     },
  //   );
  // }

  // ///
  // /// РосАвиаТест. Получение чек листа в Normal
  // ///
  // /// РосАвиаТест. Получение чек листа для Предполётных процедур
  // ///

  // @Route.get('/learning/hand_book/normal_categories/check_list')
  // @OpenApiRoute()
  // Future<Response> fetchNormalCheckList(Request request) async {
  //   final body = await _rosAviaTestRepository.fetchNormalCheckList();

  //   return wrapResponse(
  //     () async {
  //       return Response.ok(
  //         jsonEncode(body),
  //         headers: jsonContentHeaders,
  //       );
  //     },
  //   );
  // }

  // ///
  // /// Получение конкретной проверки из чеклиста Normal
  // ///
  // /// Получение конкретной проверки из чеклиста Normal по id
  // ///

  // @Route.get('/learning/hand_book/normal_categories/check_list/<id>')
  // @OpenApiRoute()
  // Future<Response> fetchNormalCheckListById(Request request, String id) async {
  //   return wrapResponse(
  //     () async {
  //       // final id = request.context['id'] as String;
  //       // final id2 = int.parse(request.params['id']!);

  //       return Response.ok(
  //         jsonEncode(await _rosAviaTestRepository.fetchNormalCheckListById(int.parse(id))),
  //         headers: jsonContentHeaders,
  //       );
  //     },
  //   );
  // }

  // ///
  // /// РосАвиаТест. Получение категорий для Аварийных процедур
  // ///
  // /// РосАвиаТест. Получение категорий для Аварийных процедур
  // ///

  // @Route.get('/learning/hand_book/emergency_categories')
  // @OpenApiRoute()
  // Future<Response> fetchEmergencyCategories(Request request) async {
  //   final body = await _rosAviaTestRepository.fetchEmergencyCategories();

  //   return wrapResponse(
  //     () async {
  //       return Response.ok(
  //         jsonEncode(body),
  //         headers: jsonContentHeaders,
  //       );
  //     },
  //   );
  // }
}
