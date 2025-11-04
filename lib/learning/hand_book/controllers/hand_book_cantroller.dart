import 'dart:async';
import 'dart:convert';

import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/learning/hand_book/repositories/hand_book_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'hand_book_cantroller.g.dart';

class HandBookController {
  final HandBookRepository _handBookRepository;
  HandBookController({required HandBookRepository handBookRepository}) : _handBookRepository = handBookRepository;

  Router get router => _$HandBookControllerRouter(this);

  ///
  /// Hand Book. Получение основных категорий
  ///
  /// Получение всех основных категорий в Hand Book
  ///

  @Route.get('/learning/hand_book/main_categories')
  @OpenApiRoute()
  Future<Response> fetchHandBookCategoties(Request request) async {
    final body = await _handBookRepository.fetchHandBookMainCategoties();

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
  /// Hand Book. Получение категорий для Предполётных процедур
  ///
  /// Hand Book. Получение категорий для Предполётных процедур
  ///

  @Route.get('/learning/hand_book/preflight_inspection_categories')
  @OpenApiRoute()
  Future<Response> fetchPreflightInspectionCaegories(Request request) async {
    final body = await _handBookRepository.fetchPreflightInspectionCategories();

    return wrapResponse(
      () async {
        return Response.ok(
          jsonEncode(body),
          headers: jsonContentHeaders,
        );
      },
    );
    // return wrapResponse(
    //   () async {
    //     return Response.badRequest(
    //       // jsonEncode(body),
    //       headers: jsonContentHeaders,
    //     );
    //   },
    // );
  }

  ///
  /// Hand Book. Получение чек листа в Preflight inspetion
  ///
  /// Hand Book. Получение чек листа для Предполётных процедур
  ///

  @Route.get('/learning/hand_book/preflight_inspection_categories/check_list')
  @OpenApiRoute()
  Future<Response> fetchPreflightInspectionCheckList(Request request) async {
    final body = await _handBookRepository.fetchPreflightInspectionCheckList();

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
  /// Получение конкретной проверки из чеклиста
  ///
  /// Получение конкретной проверки из чеклиста по id
  ///

  @Route.get('/learning/hand_book/preflight_inspection_categories/check_list/<id>')
  @OpenApiRoute()
  Future<Response> fetchPreflightInspectionCheckListById(Request request, String id) async {
    return wrapResponse(
      () async {
        // final id = request.context['id'] as String;
        // final id2 = int.parse(request.params['id']!);

        return Response.ok(
          jsonEncode(await _handBookRepository.fetchPreflightInspectionCheckListById(int.parse(id))),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  ///
  /// Hand Book. Получение категорий для Нормальных процедур
  ///
  /// Hand Book. Получение категорий для Нормальных процедур
  ///

  @Route.get('/learning/hand_book/normal_categories')
  @OpenApiRoute()
  Future<Response> fetchNormalCategories(Request request) async {
    final body = await _handBookRepository.fetchNormalCategories();

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
  /// Hand Book. Получение чек листа в Normal
  ///
  /// Hand Book. Получение чек листа для Предполётных процедур
  ///

  @Route.get('/learning/hand_book/normal_categories/check_list')
  @OpenApiRoute()
  Future<Response> fetchNormalCheckList(Request request) async {
    final body = await _handBookRepository.fetchNormalCheckList();

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
  /// Получение конкретной проверки из чеклиста Normal
  ///
  /// Получение конкретной проверки из чеклиста Normal по id
  ///

  @Route.get('/learning/hand_book/normal_categories/check_list/<id>')
  @OpenApiRoute()
  Future<Response> fetchNormalCheckListById(Request request, String id) async {
    return wrapResponse(
      () async {
        // final id = request.context['id'] as String;
        // final id2 = int.parse(request.params['id']!);

        return Response.ok(
          jsonEncode(await _handBookRepository.fetchNormalCheckListById(int.parse(id))),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  ///
  /// Hand Book. Получение категорий для Аварийных процедур
  ///
  /// Hand Book. Получение категорий для Аварийных процедур
  ///

  @Route.get('/learning/hand_book/emergency_categories')
  @OpenApiRoute()
  Future<Response> fetchEmergencyCategories(Request request) async {
    final body = await _handBookRepository.fetchEmergencyCategories();

    return wrapResponse(
      () async {
        return Response.ok(
          jsonEncode(body),
          headers: jsonContentHeaders,
        );
      },
    );
  }
}
