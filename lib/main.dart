import 'dart:convert';
import 'dart:io';

import 'package:airpoint_server/common/authentication_exception.dart';
import 'package:airpoint_server/controller/profile_cantroller.dart';
import 'package:airpoint_server/data/profile_repository.dart';
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
Future<void> main() async {
  await LoggerSettings.initLogging(instancePrefix: 'Server');
  final connectionHost = Platform.environment['POSTGRESQL_HOST'];
  logger.info('Postgresql connection Host is $connectionHost');

  final connection = await Connection.open(
    Endpoint(
      // host: Platform.environment['POSTGRESQL_HOST'] ?? 'postgresql',
      host: 'localhost',
      database: 'aviapoint',
      username: 'postgres',
      password: Platform.environment['POSTGRESQL_PASSWORD'] ?? 'password',
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );
  // print('Connetion: ${connection.isOpen}');
  final profileRepository = ProfileRepository(connection: connection);

  final handler = Cascade()
      .add(ProfileController(profileRepository: profileRepository).router)
      .add(createStaticHandler('public/'))
      .add(
        Router()
          ..mount(
            '/openapi',
            SwaggerUI(
              'public/open_api.yaml',
              docExpansion: DocExpansion.list,
              syntaxHighlightTheme: SyntaxHighlightTheme.tomorrowNight,
              title: 'Swagger CTF',
            ),
          ),
      )
      .handler;

  final pipeline = Pipeline()
      .addMiddleware(
        logRequests(),
      )
      .addMiddleware(
        cors.corsHeaders(),
      )
      .addHandler(
        handler,
      );

  await serve(pipeline, InternetAddress.anyIPv4, 8080);
}

Future<Response> _jsonHendler(Request request) async {
  final oauthToken = request.headers[HttpHeaders.authorizationHeader];
  await _checkAuthentication(oauthToken);
  print('1');
  return Response.ok(jsonEncode({'operation_details': 10}), headers: {'Content-Type': 'aplications/json'});
}

Future<void> _checkAuthentication(String? token) async {
  if (token?.contains('Bearer') ?? false) {
    return;
  }
  throw AuthenticationException();
}
