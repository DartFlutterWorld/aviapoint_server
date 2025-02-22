import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:airpoint_server/api/create_user_request.dart';
import 'package:airpoint_server/data/profile_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_cantroller.g.dart';

class ProfileController {
  final ProfileRepository _profileRepository;
  ProfileController({required ProfileRepository profileRepository}) : _profileRepository = profileRepository;

  Router get router => _$ProfileControllerRouter(this);

  @protected
  Map<String, String> get jsonContentHeaders => const {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        'X-Powered-By': 'shmr_server.io api',
      };

  ///
  /// Создание пользователя
  ///
  /// Возвращает в ответе данные пользователя
  ///
  @Route.post('/user')
  @OpenApiRoute()
  Future<Response> createUser(Request request) async {
    final body = await request.readAsString();
    final createTodoRequest = CreateUserRequest.fromJson(
      jsonDecode(body),
    );

    return _wrapResponse(
      () async {
        final userId = request.context['user_id'] as String;

        return Response.ok(
          jsonEncode(
            await _profileRepository.create(
              id: 1,
              name: createTodoRequest.name,
              phone: createTodoRequest.email,
            ),
          ),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  ///
  /// Получение профилей пользователей
  ///
  /// Получение всех профилей пользователей
  ///

  @Route.get('/profiles')
  @OpenApiRoute()
  Future<Response> getUsers(Request request) async {
    final body = await _profileRepository.fetchProiles();

    return _wrapResponse(
      () async {
        return Response.ok(
          jsonEncode(body),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  ///
  /// Удаление пользователя
  ///
  /// Удаление пользователя по userId
  ///
  @Route.delete('/user/<userId>')
  @OpenApiRoute()
  Future<Response> deleteUser(Request request) async => Response.ok('');

  Future<Response> _wrapResponse(FutureOr<Response> Function() createBody) async {
    try {
      final result = await createBody();

      return result;
    } on Object catch (e, s) {
      return Response.badRequest(
        body: jsonEncode({'error': e.toString(), 'stack_trace': s.toString()}),
        headers: jsonContentHeaders,
      );
    }
  }
}
