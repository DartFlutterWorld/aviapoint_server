import 'dart:async';
import 'dart:convert';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/profiles/api/create_user_request.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
    return wrapResponse(
      () async {
        // Проверяем аутентификацию в самом методе
        final authHeader = request.headers['Authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
        }

        final token = authHeader.substring(7);
        final tokenService = getIt.get<TokenService>();

        // Валидация токена
        final isValid = tokenService.validateToken(token);
        if (!isValid) {
          logger.severe('Invalid token received. Token: ${token.substring(0, 20)}...');
          // Проверяем, истек ли токен или он невалидный по другой причине
          try {
            final payload = JwtDecoder.decode(token);
            final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
            final now = DateTime.now();
            if (now.isAfter(expiry)) {
              // Токен истек - возвращаем специальный код для обновления
              return Response.unauthorized(
                jsonEncode({'error': 'Token expired', 'code': 'TOKEN_EXPIRED', 'message': 'Access token has expired. Please refresh your token using the refresh_token.'}),
                headers: {
                  ...jsonContentHeaders,
                  'X-Token-Status': 'expired',
                },
              );
            }
          } catch (e) {
            // Токен невалидный по другой причине
          }
          return Response.unauthorized(
            jsonEncode({
              'error': 'Invalid token',
              'code': 'INVALID_TOKEN',
            }),
            headers: {
              ...jsonContentHeaders,
              'X-Token-Status': 'invalid',
            },
          );
        }

        // Получаем ID пользователя из токена
        final id = tokenService.getUserIdFromToken(token);
        if (id == null || id.isEmpty) {
          logger.severe('Cannot extract user ID from token');
          return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
        }

        final result = await _profileRepository.fetchProfileById(int.parse(id));

        return Response.ok(
          jsonEncode(result),
          headers: jsonContentHeaders,
        );
      },
    );
  }
}
