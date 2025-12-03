import 'dart:convert';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/subscriptions/repositories/subscription_repository.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'subscription_controller.g.dart';

class SubscriptionController {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionController({
    required SubscriptionRepository subscriptionRepository,
  }) : _subscriptionRepository = subscriptionRepository;

  Router get router => _$SubscriptionControllerRouter(this);

  ///
  /// Получение статуса подписки текущего пользователя
  ///
  /// Проверяет наличие активной подписки у пользователя
  ///
  @Route.get('/subscriptions/status')
  @OpenApiRoute()
  Future<Response> getSubscriptionStatus(Request request) async {
    return wrapResponse(
      () async {
        // Получаем user_id из токена
        final authHeader = request.headers['Authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized(
            jsonEncode({'error': 'Unauthorized'}),
            headers: jsonContentHeaders,
          );
        }

        final token = authHeader.substring(7);
        final userIdStr = getIt.get<TokenService>().getUserIdFromToken(token);
        if (userIdStr == null) {
          return Response.unauthorized(
            jsonEncode({'error': 'Invalid token'}),
            headers: jsonContentHeaders,
          );
        }

        final userId = int.parse(userIdStr);
        final hasActive = await _subscriptionRepository.hasActiveSubscription(userId);

        return Response.ok(
          jsonEncode({
            'has_active_subscription': hasActive,
          }),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  ///
  /// Получение всех активных подписок пользователя
  ///
  /// Возвращает список всех активных подписок пользователя.
  /// Использует токен авторизации для определения пользователя.
  /// Возвращает 404, если активных подписок нет.
  ///
  @Route.get('/subscriptions/active')
  @OpenApiRoute()
  Future<Response> getActiveSubscription(Request request) async {
    return wrapResponse(
      () async {
        // Проверяем авторизацию
        final authHeader = request.headers['Authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized(
            jsonEncode({'error': 'Unauthorized'}),
            headers: jsonContentHeaders,
          );
        }

        final token = authHeader.substring(7);
        final tokenService = getIt.get<TokenService>();

        // Валидация токена
        final isValid = tokenService.validateToken(token);
        if (!isValid) {
          logger.severe('Invalid token in getActiveSubscription');
          return Response.unauthorized(
            jsonEncode({'error': 'Invalid token'}),
            headers: jsonContentHeaders,
          );
        }

        // Получаем user_id из токена
        final userIdStr = tokenService.getUserIdFromToken(token);
        if (userIdStr == null || userIdStr.isEmpty) {
          logger.severe('Cannot extract user ID from token');
          return Response.unauthorized(
            jsonEncode({'error': 'Invalid token: no user ID'}),
            headers: jsonContentHeaders,
          );
        }

        final userId = int.parse(userIdStr);

        // Получаем все активные подписки
        final subscriptions = await _subscriptionRepository.getActiveSubscription(userId);

        // Возвращаем 404, если подписок нет
        if (subscriptions.isEmpty) {
          return Response.notFound(
            jsonEncode({
              'error': 'No active subscription found',
              'message': 'User does not have an active subscription',
            }),
            headers: jsonContentHeaders,
          );
        }

        // Возвращаем список активных подписок
        return Response.ok(
          jsonEncode({
            'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
          }),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  ///
  /// Получение всех подписок пользователя
  ///
  /// Возвращает историю всех подписок пользователя
  ///
  @Route.get('/subscriptions/history')
  @OpenApiRoute()
  Future<Response> getSubscriptionHistory(Request request) async {
    return wrapResponse(
      () async {
        // Получаем user_id из токена
        final authHeader = request.headers['Authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized(
            jsonEncode({'error': 'Unauthorized'}),
            headers: jsonContentHeaders,
          );
        }

        final token = authHeader.substring(7);
        final userIdStr = getIt.get<TokenService>().getUserIdFromToken(token);
        if (userIdStr == null) {
          return Response.unauthorized(
            jsonEncode({'error': 'Invalid token'}),
            headers: jsonContentHeaders,
          );
        }

        final userId = int.parse(userIdStr);
        final subscriptions = await _subscriptionRepository.getUserSubscriptions(userId);

        return Response.ok(
          jsonEncode({
            'subscriptions': subscriptions
                .map((s) => {
                      'id': s.id,
                      'payment_id': s.paymentId,
                      'period_days': s.periodDays,
                      'start_date': s.startDate.toIso8601String(),
                      'end_date': s.endDate.toIso8601String(),
                      'is_active': s.isActive,
                      'created_at': s.createdAt.toIso8601String(),
                    })
                .toList(),
          }),
          headers: jsonContentHeaders,
        );
      },
    );
  }
}
