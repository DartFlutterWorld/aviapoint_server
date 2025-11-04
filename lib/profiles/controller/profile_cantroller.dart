import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/profiles/api/create_user_request.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
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
            await _profileRepository.createUser(
              // id: 1,
              // name: createTodoRequest.name,
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
  /// Получение профиля
  ///
  /// Получение всех профиля пользователя
  ///

  @Route.post('/profile')
  @OpenApiRoute()
  Future<Response> getProfile(Request request) async {
    // Проверяем аутентификацию в самом методе
    final authHeader = request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
    }

    final token = authHeader.substring(7);
    final payload = getIt.get<TokenService>().validateToken(token);
    if (payload == false) {
      return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
    }

    // final body = await request.readAsString();
    // final json = jsonDecode(body) as Map<String, dynamic>;
    final id = getIt.get<TokenService>().getUserIdFromToken(token);

    // final body = await request.readAsString();
    final result = await _profileRepository.fetchProfileById(int.parse(id ?? ''));

    return wrapResponse(
      () async {
        return Response.ok(
          jsonEncode(result),
          headers: jsonContentHeaders,
        );
      },
    );
  }
}
