import 'dart:io';

import 'package:airpoint_server/core/config/config.dart';
import 'package:airpoint_server/core/service_locator.dart/service_locator.dart';
import 'package:airpoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:airpoint_server/learning/hand_book/controllers/hand_book_cantroller.dart';
import 'package:airpoint_server/profiles/controller/profile_cantroller.dart';
import 'package:airpoint_server/learning/video_for_students/controllers/video_for_students_cantroller.dart';
import 'package:airpoint_server/logger/logger.dart';
import 'package:postgres/postgres.dart';
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
  await LoggerSettings.initLogging(instancePrefix: 'Server');

  await setupDependencies();
  await getIt.allReady();

  final handler = Cascade()
      .add(getIt<ProfileController>().router)
      .add(getIt<VideoForStudentsController>().router)
      .add(getIt<HandBookController>().router)
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

  Middleware logDatabaseRequests() {
    return (Handler handler) {
      return (Request request) async {
        final startTime = DateTime.now();
        logger.info('Request started: ${request.method} ${request.url}');
        final response = await handler(request);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        logger.info('Request completed: ${request.method} ${request.url} took ${duration.inMilliseconds}ms');

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
          logger.severe('Error handling request: $e', e, stackTrace);
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
  print('Сервер запущен на http://${server.address.host}:${server.port}');

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

