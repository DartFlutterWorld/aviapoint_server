import 'dart:io';

import 'package:aviapoint_server/auth/controller/auth_controller.dart';
import 'package:aviapoint_server/core/config/config.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/learning/hand_book/controllers/hand_book_cantroller.dart';
import 'package:aviapoint_server/learning/ros_avia_test/controllers/ros_avia_test_cantroller.dart';
import 'package:aviapoint_server/news/controllers/news_controller.dart';
import 'package:aviapoint_server/profiles/controller/profile_cantroller.dart';
import 'package:aviapoint_server/learning/video_for_students/controllers/video_for_students_cantroller.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/stories/controllers/stories_controller.dart';
import 'package:aviapoint_server/payments/controllers/payment_controller.dart';
import 'package:aviapoint_server/subscriptions/controllers/subscription_controller.dart';
import 'package:aviapoint_server/core/migrations/migration_manager.dart';
import 'package:aviapoint_server/on_the_way/controller/airport_controller.dart';
import 'package:aviapoint_server/on_the_way/controller/on_the_way_controller.dart';
import 'package:aviapoint_server/on_the_way/controller/feedback_controller.dart';
import 'package:aviapoint_server/on_the_way/repositories/on_the_way_repository.dart';
import 'package:aviapoint_server/on_the_way/services/flight_status_service.dart';
import 'package:aviapoint_server/push_notifications/fcm_service.dart';
import 'package:aviapoint_server/telegram/telegram_bot_service.dart';
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
  final talker = Talker(settings: TalkerSettings(useConsoleLogs: true, useHistory: true, maxHistoryItems: 100));

  // Регистрируем Talker в GetIt для использования в приложении
  getIt.registerSingleton<Talker>(talker);

  // Инициализация конфигурации (выбор локальной или удалённой БД)
  Config.init();
  talker.info('Environment: ${Config.environment} (Host: ${Config.dbHost}:${Config.dbPort})');

  await LoggerSettings.initLogging(instancePrefix: 'Server');

  await setupDependencies();
  logger.info('Waiting for all dependencies to be ready...');
  await getIt.allReady();
  logger.info('All dependencies are ready');

  // Инициализация Telegram бота
  TelegramBotService().init();
  logger.info('Telegram bot service initialized');

  // Инициализация FCM сервиса для push-уведомлений
  FcmService().init();
  logger.info('FCM service initialized');

  // Запускаем сервис автоматического управления статусами полётов
  final onTheWayRepository = await getIt.getAsync<OnTheWayRepository>();
  final flightStatusService = FlightStatusService(repository: onTheWayRepository);
  flightStatusService.start();
  logger.info('✅ Flight status service started (auto-complete after 24h, notifications after 12h)');

  // Убеждаемся, что контроллеры загружены
  await getIt.getAsync<AirportController>();
  await getIt.getAsync<FeedbackController>();

  // Проверяем что соединение с БД установлено
  Connection? connection;
  try {
    connection = await getIt.getAsync<Connection>();
    logger.info('Database connection verified: host=${Config.dbHost}, database=${Config.database}');

    // Выполняем миграции при старте сервера (опционально, можно отключить)
    // Раскомментируйте следующую строку, если хотите автоматические миграции при старте:
    final migrationManager = MigrationManager(connection: connection);
    await migrationManager.runMigrations();
  } catch (e) {
    logger.severe('Failed to get database connection: $e');
    rethrow;
  }

  // Middleware для логирования статических запросов
  Handler logStaticRequests(Handler handler) {
    return (Request request) async {
      final path = request.url.path;
      // Логируем только запросы к статическим файлам (не API)
      if (!path.startsWith('/api/') && (path.startsWith('/profiles/') || path.startsWith('/stories/') || path.startsWith('/news/'))) {
        logger.info('📁 Static file request: ${request.method} ${request.url}');
      }
      final response = await handler(request);
      if (response.statusCode == 404 && !path.startsWith('/api/')) {
        logger.info('⚠️ Static file not found: ${request.url}');
      }
      return response;
    };
  }

  final staticHandler = createStaticHandler('public/', listDirectories: true);

  final handler = Cascade()
      .add(getIt<ProfileController>().router)
      .add(getIt<VideoForStudentsController>().router)
      .add(getIt<HandBookController>().router)
      .add(getIt<AuthController>().router)
      .add(getIt<StoriesController>().router)
      .add(getIt<NewsController>().router)
      .add(getIt<RosAviaTestController>().router)
      .add(getIt<PaymentController>().router)
      .add(getIt<SubscriptionController>().router)
      .add(getIt<OnTheWayController>().router)
      .add(getIt<AirportController>().router)
      .add(getIt<FeedbackController>().router)
      .add(logStaticRequests(staticHandler))
      .add(Router()..mount('/api/openapi', SwaggerUI('public/open_api.yaml', docExpansion: DocExpansion.list, syntaxHighlightTheme: SyntaxHighlightTheme.tomorrowNight, title: 'Swagger AviaPoint')))
      .handler;

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

  final pipeline = Pipeline().addMiddleware(logRequests()).addMiddleware(cors.corsHeaders()).addMiddleware(handleErrors()).addMiddleware(logDatabaseRequests()).addHandler(handler);

  HttpServer server;
  try {
    logger.info('Попытка запуска HTTP сервера на порту ${Config.serverPort}...');
    server = await serve(pipeline, InternetAddress.anyIPv4, Config.serverPort);
    logger.info('Сервер успешно запущен на ${server.address.host}:${server.port}');
    print('Сервер запущен на ${server.address.host}:${server.port}');
  } on SocketException catch (e, stackTrace) {
    if (e.osError?.errorCode == 48) {
      logger.severe(
        'Порт ${Config.serverPort} уже занят другим процессом.\n'
        'Чтобы найти процесс, используйте: lsof -i :${Config.serverPort}\n'
        'Чтобы остановить процесс, используйте: kill <PID>',
      );
    } else {
      logger.severe('Ошибка при запуске сервера: $e');
      logger.severe('Код ошибки ОС: ${e.osError?.errorCode}');
      logger.severe('Сообщение ОС: ${e.osError?.message}');
      logger.severe('Stack trace: $stackTrace');
    }
    rethrow;
  } catch (e, stackTrace) {
    logger.severe('Неожиданная ошибка при запуске сервера: $e');
    logger.severe('Stack trace: $stackTrace');
    rethrow;
  }

  // Сохраняем ссылку на сервис для корректного завершения
  final flightStatusServiceRef = flightStatusService;

  ProcessSignal.sigint.watch().listen((_) async {
    try {
      flightStatusServiceRef.stop();
      final connection = await getIt.getAsync<Connection>();
      await connection.close();
      logger.info('Connection to PostgreSQL closed');
    } catch (e) {
      logger.info('Ошибка при закрытии подключения: $e');
    }
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
