import 'dart:io';

import 'package:airpoint_server/auth/controller/auth_controller.dart';
import 'package:airpoint_server/auth/token/token_service.dart';
import 'package:airpoint_server/core/config/config.dart';
import 'package:airpoint_server/learning/hand_book/controllers/hand_book_cantroller.dart';
import 'package:airpoint_server/learning/hand_book/repositories/hand_book_repository.dart';
import 'package:airpoint_server/learning/ros_avia_test/controllers/ros_avia_test_cantroller.dart';
import 'package:airpoint_server/learning/ros_avia_test/repositories/ros_avia_test_repository.dart';
import 'package:airpoint_server/learning/video_for_students/controllers/video_for_students_cantroller.dart';
import 'package:airpoint_server/learning/video_for_students/repositories/video_for_students_repository.dart';
import 'package:airpoint_server/logger/logger.dart';
import 'package:airpoint_server/news/controllers/news_controller.dart';
import 'package:airpoint_server/news/repositories/news_repository.dart';
import 'package:airpoint_server/profiles/controller/profile_cantroller.dart';
import 'package:airpoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:airpoint_server/stories/controllers/stories_controller.dart';
import 'package:airpoint_server/stories/repositories/stories_repository.dart';
import 'package:postgres/postgres.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Регистрируем соединение с базой данных
  getIt.registerSingletonAsync<Connection>(() async {
    final connection = await Connection.open(
      Endpoint(
        host: Config.dbHost,
        database: Config.database,
        username: Config.username,
        password: Config.dbPassword,
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    ).catchError((error) {
      logger.severe('Failed to connect to PostgreSQL: $error');
      throw error; // Прерываем выполнение, если соединение не удалось
    });
    logger.info('Connected to PostgreSQL at ${Config.dbHost}');
    return connection;
  });

  // Регистрируем репозитории
  getIt.registerSingletonAsync<ProfileRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return ProfileRepository(connection: connection);
  });

  getIt.registerSingletonAsync<VideoForStudentsRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return VideoForStudentsRepository(connection: connection);
  });
  getIt.registerSingletonAsync<HandBookRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return HandBookRepository(connection: connection);
  });

  // Регистрируем контроллеры
  getIt.registerSingletonAsync<ProfileController>(() async {
    final profileRepository = await getIt.getAsync<ProfileRepository>();
    return ProfileController(profileRepository: profileRepository);
  });

  getIt.registerSingletonAsync<VideoForStudentsController>(() async {
    final videoForStudentsRepository = await getIt.getAsync<VideoForStudentsRepository>();
    return VideoForStudentsController(videoForStudentsRepository: videoForStudentsRepository);
  });
  getIt.registerSingletonAsync<HandBookController>(() async {
    final handBookRepository = await getIt.getAsync<HandBookRepository>();
    return HandBookController(handBookRepository: handBookRepository);
  });
  getIt.registerSingletonAsync<TokenService>(() async {
    return TokenService(
      secretKey: '9032baabbeace5abe5e440798545c0edd21c3c25766637b07942ab70fa922b7b', // Используйте надежный ключ
      accessTokenExpiry: Duration(minutes: 1),
      refreshTokenExpiry: Duration(days: 30),
    );
  });

  getIt.registerSingletonAsync<AuthController>(() async {
    final profileRepository = await getIt.getAsync<ProfileRepository>();
    return AuthController(
      profileRepository: profileRepository,
      tokenService: await getIt.getAsync<TokenService>(),
    );
  });

  getIt.registerSingletonAsync<StoriesRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return StoriesRepository(connection: connection);
  });

  getIt.registerSingletonAsync<StoriesController>(() async {
    final storiesRepository = await getIt.getAsync<StoriesRepository>();
    return StoriesController(
      storiesRepository: storiesRepository,
    );
  });

  getIt.registerSingletonAsync<NewsRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return NewsRepository(connection: connection);
  });
  getIt.registerSingletonAsync<NewsController>(() async {
    final newsRepository = await getIt.getAsync<NewsRepository>();
    return NewsController(
      newsRepository: newsRepository,
    );
  });

  getIt.registerSingletonAsync<RosAviaTestRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return RosAviaTestRepository(connection: connection);
  });

  getIt.registerSingletonAsync<RosAviaTestController>(() async {
    final rosAviaTestRepository = await getIt.getAsync<RosAviaTestRepository>();
    return RosAviaTestController(
      rosAviaTestRepository: rosAviaTestRepository,
    );
  });
}
