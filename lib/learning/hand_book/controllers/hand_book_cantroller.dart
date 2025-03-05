import 'dart:async';
import 'dart:convert';

import 'package:airpoint_server/core/wrap_response.dart';
import 'package:airpoint_server/learning/hand_book/repositories/hand_book_repository.dart';
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
  Future<Response> fetchPreflightInspectionCaegoriesModel(Request request) async {
    final body = await _handBookRepository.fetchPreflightInspectionCategoriesModel();

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
  // /// Получение конкретной проверки из чеклиста
  // ///
  // /// Получение конкретной проверки из чеклиста по id
  // ///

  // @Route.get('/learning/check_list/{id}')
  // @OpenApiRoute()
  // Future<Response> fetchCheckListById(Request request) async {
  //   return wrapResponse(
  //     () async {
  //       // final id = request.context['id'] as String;
  //       final id = int.parse(request.params['id']!);

  //       return Response.ok(
  //         jsonEncode(await _checkListRepository.fetchCheckListById(id)),
  //         headers: jsonContentHeaders,
  //       );
  //     },
  //   );
  // }
}
