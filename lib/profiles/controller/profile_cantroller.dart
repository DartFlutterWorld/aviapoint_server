import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:airpoint_server/profiles/api/create_user_request.dart';
import 'package:airpoint_server/core/wrap_response.dart';
import 'package:airpoint_server/profiles/data/repositories/profile_repository.dart';
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

    return wrapResponse(
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
  /// Удаление пользователя
  ///
  /// Удаление пользователя по userId
  ///
  @Route.delete('/user/<userId>')
  @OpenApiRoute()
  Future<Response> deleteUser(Request request) async => Response.ok('');
}
