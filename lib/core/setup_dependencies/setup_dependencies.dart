import 'package:aviapoint_server/auth/controller/auth_controller.dart';
import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/config/config.dart';
import 'package:aviapoint_server/learning/hand_book/controllers/hand_book_cantroller.dart';
import 'package:aviapoint_server/learning/hand_book/repositories/hand_book_repository.dart';
import 'package:aviapoint_server/learning/ros_avia_test/controllers/ros_avia_test_cantroller.dart';
import 'package:aviapoint_server/learning/ros_avia_test/repositories/ros_avia_test_repository.dart';
import 'package:aviapoint_server/learning/video_for_students/controllers/video_for_students_cantroller.dart';
import 'package:aviapoint_server/learning/video_for_students/repositories/video_for_students_repository.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/news/controllers/news_controller.dart';
import 'package:aviapoint_server/news/repositories/news_repository.dart';
import 'package:aviapoint_server/profiles/controller/profile_cantroller.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:aviapoint_server/stories/controllers/stories_controller.dart';
import 'package:aviapoint_server/stories/repositories/stories_repository.dart';
import 'package:aviapoint_server/payments/controllers/payment_controller.dart';
import 'package:aviapoint_server/payments/repositories/payment_repository.dart';
import 'package:aviapoint_server/payments/services/yookassa_service.dart';
import 'package:aviapoint_server/subscriptions/controllers/subscription_controller.dart';
import 'package:aviapoint_server/subscriptions/repositories/subscription_repository.dart';
import 'package:aviapoint_server/telegram/telegram_bot_service.dart';
import 'package:aviapoint_server/on_the_way/controller/airport_controller.dart';
import 'package:aviapoint_server/on_the_way/controller/on_the_way_controller.dart';
import 'package:aviapoint_server/on_the_way/controller/feedback_controller.dart';
import 'package:aviapoint_server/on_the_way/controller/aircraft_catalog_controller.dart';
import 'package:aviapoint_server/on_the_way/repositories/airport_repository.dart';
import 'package:aviapoint_server/on_the_way/repositories/on_the_way_repository.dart';
import 'package:aviapoint_server/on_the_way/repositories/feedback_repository.dart';
import 'package:aviapoint_server/on_the_way/repositories/airport_ownership_repository.dart';
import 'package:aviapoint_server/on_the_way/repositories/aircraft_catalog_repository.dart';
import 'package:aviapoint_server/blog/controller/blog_controller.dart';
import 'package:aviapoint_server/blog/repositories/blog_repository.dart';
import 'package:aviapoint_server/market/controller/market_controller.dart';
import 'package:aviapoint_server/market/repositories/market_repository.dart';
import 'package:aviapoint_server/jobs/controller/jobs_controller.dart';
import 'package:aviapoint_server/jobs/repositories/jobs_repository.dart';
import 'package:aviapoint_server/app_settings/controller/app_settings_controller.dart';
import 'package:aviapoint_server/app_settings/data/repositories/app_settings_repository.dart';
import 'package:aviapoint_server/checko/controller/checko_controller.dart';
import 'package:aviapoint_server/checko/repositories/checko_repository.dart';
import 'package:postgres/postgres.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Регистрируем соединение с базой данных
  getIt.registerSingletonAsync<Connection>(() async {
    logger.info('Starting PostgreSQL connection setup...');
    logger.info('Connecting to PostgreSQL at ${Config.dbHost}, database: ${Config.database}, user: ${Config.username}');

    // Добавляем задержку для инициализации БД
    await Future.delayed(Duration(seconds: 10));
    logger.info('Delay completed, attempting connection...');

    try {
      final connection = await Connection.open(
        Endpoint(host: Config.dbHost, port: Config.dbPort, database: Config.database, username: Config.username, password: Config.dbPassword),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );

      logger.info('Successfully connected to PostgreSQL at ${Config.dbHost}:${Config.dbPort}');
      return connection;
    } catch (error, stackTrace) {
      logger.severe('Failed to connect to PostgreSQL at ${Config.dbHost}:${Config.dbPort}: $error');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
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
      accessTokenExpiry: Duration(hours: 24), // Увеличено до 24 часов для удобства разработки
      refreshTokenExpiry: Duration(days: 30),
    );
  });

  getIt.registerSingletonAsync<AuthController>(() async {
    final profileRepository = await getIt.getAsync<ProfileRepository>();
    return AuthController(profileRepository: profileRepository, tokenService: await getIt.getAsync<TokenService>());
  });

  getIt.registerSingletonAsync<StoriesRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return StoriesRepository(connection: connection);
  });

  getIt.registerSingletonAsync<StoriesController>(() async {
    final storiesRepository = await getIt.getAsync<StoriesRepository>();
    return StoriesController(storiesRepository: storiesRepository);
  });

  getIt.registerSingletonAsync<NewsRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return NewsRepository(connection: connection);
  });
  getIt.registerSingletonAsync<NewsController>(() async {
    final newsRepository = await getIt.getAsync<NewsRepository>();
    return NewsController(newsRepository: newsRepository);
  });

  getIt.registerSingletonAsync<RosAviaTestRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return RosAviaTestRepository(connection: connection);
  });

  getIt.registerSingletonAsync<RosAviaTestController>(() async {
    final rosAviaTestRepository = await getIt.getAsync<RosAviaTestRepository>();
    return RosAviaTestController(rosAviaTestRepository: rosAviaTestRepository);
  });

  // Регистрируем платежные зависимости
  getIt.registerSingleton<YooKassaService>(YooKassaService());

  getIt.registerSingletonAsync<PaymentRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    final yookassaService = getIt.get<YooKassaService>();
    return PaymentRepository(connection: connection, yookassaService: yookassaService);
  });

  getIt.registerSingletonAsync<SubscriptionRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return SubscriptionRepository(connection: connection);
  });

  getIt.registerSingletonAsync<PaymentController>(() async {
    final paymentRepository = await getIt.getAsync<PaymentRepository>();
    final subscriptionRepository = await getIt.getAsync<SubscriptionRepository>();
    return PaymentController(paymentRepository: paymentRepository, subscriptionRepository: subscriptionRepository);
  });

  getIt.registerSingletonAsync<SubscriptionController>(() async {
    final subscriptionRepository = await getIt.getAsync<SubscriptionRepository>();
    return SubscriptionController(subscriptionRepository: subscriptionRepository);
  });

  getIt.registerSingletonAsync<OnTheWayRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return OnTheWayRepository(connection: connection);
  });

  // Airport Repository
  getIt.registerSingletonAsync<AirportRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return AirportRepository(connection: connection);
  });

  // Airport Ownership Repository
  getIt.registerSingletonAsync<AirportOwnershipRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return AirportOwnershipRepository(connection: connection);
  });

  // Airport Controller
  getIt.registerSingletonAsync<AirportController>(() async {
    final airportRepository = await getIt.getAsync<AirportRepository>();
    final ownershipRepository = await getIt.getAsync<AirportOwnershipRepository>();
    final profileRepository = await getIt.getAsync<ProfileRepository>();
    return AirportController(
      airportRepository: airportRepository,
      ownershipRepository: ownershipRepository,
      profileRepository: profileRepository,
    );
  });

  getIt.registerSingletonAsync<OnTheWayController>(() async {
    final onTheWayRepository = await getIt.getAsync<OnTheWayRepository>();
    return OnTheWayController(onTheWayRepository: onTheWayRepository);
  });

  getIt.registerSingletonAsync<FeedbackRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return FeedbackRepository(connection: connection);
  });

  getIt.registerSingletonAsync<FeedbackController>(() async {
    final feedbackRepository = await getIt.getAsync<FeedbackRepository>();
    return FeedbackController(feedbackRepository: feedbackRepository);
  });

  // Aircraft Catalog Repository
  getIt.registerSingletonAsync<AircraftCatalogRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return AircraftCatalogRepository(connection: connection);
  });

  // Aircraft Catalog Controller
  getIt.registerSingletonAsync<AircraftCatalogController>(() async {
    final repository = await getIt.getAsync<AircraftCatalogRepository>();
    return AircraftCatalogController(repository: repository);
  });

  // Blog Repository
  getIt.registerSingletonAsync<BlogRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return BlogRepository(connection: connection);
  });

  // Blog Controller
  getIt.registerSingletonAsync<BlogController>(() async {
    final repository = await getIt.getAsync<BlogRepository>();
    return BlogController(repository: repository);
  });

  // App Settings Repository
  getIt.registerSingletonAsync<AppSettingsRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return AppSettingsRepository(connection: connection);
  });

  // App Settings Controller
  getIt.registerSingletonAsync<AppSettingsController>(() async {
    final repository = await getIt.getAsync<AppSettingsRepository>();
    return AppSettingsController(repository: repository);
  });

  // Market Repository
  getIt.registerSingletonAsync<MarketRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return MarketRepository(connection: connection);
  });

  // Market Controller
  getIt.registerSingletonAsync<MarketController>(() async {
    final repository = await getIt.getAsync<MarketRepository>();
    final tokenService = await getIt.getAsync<TokenService>();
    return MarketController(repository: repository, tokenService: tokenService);
  });

  // Jobs Repository (вакансии и резюме)
  getIt.registerSingletonAsync<JobsRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return JobsRepository(connection: connection);
  });

  // Jobs Controller
  getIt.registerSingletonAsync<JobsController>(() async {
    final repository = await getIt.getAsync<JobsRepository>();
    final tokenService = await getIt.getAsync<TokenService>();
    return JobsController(repository: repository, tokenService: tokenService);
  });

  // Checko Repository (API проверки контрагентов)
  getIt.registerSingletonAsync<CheckoRepository>(() async {
    final connection = await getIt.getAsync<Connection>();
    return CheckoRepository(connection: connection);
  });

  // Checko Controller
  getIt.registerSingletonAsync<CheckoController>(() async {
    final repository = await getIt.getAsync<CheckoRepository>();
    return CheckoController(repository: repository);
  });

  // Инициализируем Telegram бота
  TelegramBotService().init();
  logger.info('Telegram bot service initialized');
}
