import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/auth/controller/auth_controller.dart';
import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/config/config.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/learning/hand_book/controllers/hand_book_cantroller.dart';
import 'package:aviapoint_server/learning/ros_avia_test/controllers/ros_avia_test_cantroller.dart';
import 'package:aviapoint_server/news/controllers/news_controller.dart';
import 'package:aviapoint_server/profiles/controller/profile_cantroller.dart';
import 'package:aviapoint_server/learning/video_for_students/controllers/video_for_students_cantroller.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/stories/controllers/stories_controller.dart';
import 'package:postgres/postgres.dart';
import 'package:talker/talker.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as cors;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

// http://localhost:8080/open_api.yaml
// http://localhost:8080/openapi/
// http://localhost:8082/?pgsql=db&username=postgres

Future<void> main() async {
  // Инициализация Talker
  final talker = Talker(
    settings: TalkerSettings(
      useConsoleLogs: true,
      useHistory: true,
      maxHistoryItems: 100,
    ),
  );

  // Регистрируем Talker в GetIt для использования в приложении
  getIt.registerSingleton<Talker>(talker);

  // Инициализация конфигурации (выбор локальной или удалённой БД)
  Config.init();
  talker.info('Environment: ${Config.environment} (Host: ${Config.dbHost})');

  await LoggerSettings.initLogging(instancePrefix: 'Server');
  print('=== Logger initialized ===');

  await setupDependencies();
  print('=== setupDependencies completed ===');
  logger.info('Waiting for all dependencies to be ready...');
  print('=== Waiting for allReady ===');
  await getIt.allReady();
  print('=== allReady completed ===');
  logger.info('All dependencies are ready');

  // Проверяем что соединение с БД установлено
  try {
    await getIt.getAsync<Connection>();
    print('=== Database connection verified: host=${Config.dbHost}, database=${Config.database} ===');
    logger.info('Database connection verified: host=${Config.dbHost}, database=${Config.database}');
  } catch (e) {
    logger.severe('Failed to get database connection: $e');
    rethrow;
  }

  final handler = Cascade()
      .add(getIt<ProfileController>().router)
      .add(getIt<VideoForStudentsController>().router)
      .add(getIt<HandBookController>().router)
      .add(getIt<AuthController>().router)
      .add(getIt<StoriesController>().router)
      .add(getIt<NewsController>().router)
      .add(getIt<RosAviaTestController>().router)
      .add(createStaticHandler('public/', listDirectories: true))
      .add(
        Router()
          ..mount(
            '/openapi',
            SwaggerUI(
              'public/open_api.yaml',
              docExpansion: DocExpansion.list,
              syntaxHighlightTheme: SyntaxHighlightTheme.tomorrowNight,
              title: 'Swagger AviaPoint',
            ),
          ),
      )
      .handler;

  Middleware checkAuth() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Здесь проверяем аутентификацию
        // Например, проверяем заголовок Authorization
        final authHeader = request.headers['Authorization'];

        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
        }

        // Извлекаем токен
        final token = authHeader.substring(7);

        // Здесь должна быть логика проверки токена (например, через JWT)
        // Это пример - замените на свою реальную проверку

        final isValid = getIt.get<TokenService>().validateToken(token); // Ваша функция проверки токена

        if (!isValid) {
          return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
        }

        // Если всё ок, передаем запрос дальше
        return innerHandler(request);
      };
    };
  }

  Middleware logDatabaseRequests() {
    return (Handler handler) {
      return (Request request) async {
        final startTime = DateTime.now();
        final talker = getIt<Talker>();

        talker.info('Request started: ${request.method} ${request.url}');
        final response = await handler(request);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        talker.info('Request completed: ${request.method} ${request.url} took ${duration.inMilliseconds}ms');

        return response;
      };
    };
  }

  Middleware handleErrors() {
    return (Handler handler) {
      return (Request request) async {
        try {
          return await handler(request);
        } catch (e, stackTrace) {
          final talker = getIt<Talker>();
          talker.error('Error handling request: $e', e, stackTrace);
          return Response.internalServerError(body: 'Internal Server Error');
        }
      };
    };
  }

  final pipeline = Pipeline()
      .addMiddleware(
        logRequests(),
      )
      .addMiddleware(
        cors.corsHeaders(),
      )
      .addMiddleware(
        handleErrors(),
      )
      .addMiddleware(
        logDatabaseRequests(),
      )
      .addHandler(
        handler,
      );

  final server = await serve(pipeline, InternetAddress.anyIPv4, Config.serverPort);
  print('Сервер запущен на ${server.address.host}:${server.port}');

  ProcessSignal.sigint.watch().listen((_) {
    final connection = getIt<Connection>();
    connection.close();
    logger.info('Connection to PostgreSQL closed');
    exit(0);
  });
}

// Future<Response> _jsonHendler(Request request) async {
//   final oauthToken = request.headers[HttpHeaders.authorizationHeader];
//   await _checkAuthentication(oauthToken);
//   print('1');
//   return Response.ok(jsonEncode({'operation_details': 10}), headers: {'Content-Type': 'aplication/json'});
// }

// Future<void> _checkAuthentication(String? token) async {
//   if (token?.contains('Bearer') ?? false) {
//     return;
//   }
//   throw AuthenticationException();
// }
