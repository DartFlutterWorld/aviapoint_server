import 'dart:io';

class Config {
  static final String environment = Platform.environment['ENVIRONMENT'] ?? 'local';

  /// Кеш для переменных из .env.local
  static Map<String, String>? _envLocalCache;

  /// Сбрасывает кеш .env.local (полезно при hot reload)
  static void _clearEnvCache() {
    _envLocalCache = null;
  }

  /// Загружает переменные окружения из .env.local файла
  /// Возвращает Map с переменными (с кешированием)
  static Map<String, String> _loadEnvFile() {
    if (_envLocalCache != null) {
      return _envLocalCache!;
    }

    final env = <String, String>{};
    try {
      final envFile = File('.env.local');
      if (envFile.existsSync()) {
        final lines = envFile.readAsLinesSync();
        for (final line in lines) {
          // Пропускаем комментарии и пустые строки
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed.startsWith('#')) {
            continue;
          }

          // Парсим KEY=VALUE
          final index = trimmed.indexOf('=');
          if (index > 0) {
            final key = trimmed.substring(0, index).trim();
            var value = trimmed.substring(index + 1).trim();
            // Убираем кавычки если есть в начале и конце
            if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
              value = value.substring(1, value.length - 1);
            }
            env[key] = value;
          }
        }
        print('✅ Переменные окружения загружены из .env.local');
      }
    } catch (e) {
      print('⚠️ Не удалось загрузить .env.local: $e');
    }
    _envLocalCache = env;
    return env;
  }

  /// Получает значение переменной окружения, сначала из Platform.environment, затем из .env.local
  static String? _getEnv(String key, {String? defaultValue}) {
    // Сначала проверяем Platform.environment (имеет приоритет)
    if (Platform.environment.containsKey(key)) {
      return Platform.environment[key];
    }
    // Затем проверяем .env.local (только для локального окружения)
    if (environment == 'local') {
      final envLocal = _loadEnvFile();
      if (envLocal.containsKey(key)) {
        return envLocal[key];
      }
    }
    return defaultValue;
  }

  static late final String dbHost;
  static late final int dbPort;
  static late final String dbPassword;
  static final int serverPort = 8080;
  static final String database = 'aviapoint';
  static final String username = 'postgres';

  // ЮKassa настройки
  static late final String yookassaShopId;
  static late final String yookassaSecretKey;
  static late final bool yookassaTestMode;

  // Apple In-App Purchase настройки
  static late final String appleIAPKeyId;
  static late final String appleIAPIssuerId;
  static late final String appleIAPPrivateKey;
  static late final String appleBundleId;

  // Период публикации объявлений (в месяцах)
  // Можно настроить через переменную окружения PUBLICATION_DURATION_MONTHS (по умолчанию 1 месяц)
  static int get publicationDurationMonths => int.tryParse(Platform.environment['PUBLICATION_DURATION_MONTHS'] ?? '1') ?? 1;

  static void init() {
    // Сбрасываем кеш при каждой инициализации (для hot reload)
    _clearEnvCache();

    if (environment == 'local') {
      dbHost = _getEnv('POSTGRESQL_HOST', defaultValue: '127.0.0.1') ?? '127.0.0.1';
      dbPort = int.tryParse(_getEnv('POSTGRESQL_PORT', defaultValue: '5432') ?? '5432') ?? 5432;
      dbPassword = _getEnv('POSTGRESQL_PASSWORD', defaultValue: 'password') ?? 'password';
    } else {
      dbHost = Platform.environment['POSTGRESQL_HOST'] ?? '83.166.246.205';
      dbPort = int.tryParse(Platform.environment['POSTGRESQL_PORT'] ?? '5432') ?? 5432;
      dbPassword = Platform.environment['POSTGRESQL_PASSWORD'] ?? 'Metra1983@';
    }

    // ЮKassa настройки
    // Тестовый режим: установите YOOKASSA_TEST_MODE=true для использования тестовых ключей
    yookassaTestMode = _getEnv('YOOKASSA_TEST_MODE')?.toLowerCase() == 'true';

    if (yookassaTestMode) {
      // Тестовые ключи ЮKassa (для тестирования платежей)
      // Получите их в личном кабинете ЮKassa → Настройки → Тестовые ключи
      yookassaShopId = _getEnv('YOOKASSA_SHOP_ID', defaultValue: 'YOUR_TEST_SHOP_ID') ?? 'YOUR_TEST_SHOP_ID';
      yookassaSecretKey = _getEnv('YOOKASSA_SECRET_KEY', defaultValue: 'YOUR_TEST_SECRET_KEY') ?? 'YOUR_TEST_SECRET_KEY';
      print('🔧 ЮKassa: ТЕСТОВЫЙ режим включен');
    } else {
      // Продакшн ключи ЮKassa
      yookassaShopId = _getEnv('YOOKASSA_SHOP_ID', defaultValue: '1214860') ?? '1214860';
      yookassaSecretKey = _getEnv('YOOKASSA_SECRET_KEY', defaultValue: 'live_A8iyj3kBLfq4YUiKwlHoPpvBP0B7BQIBhY3vOPuDisc') ?? 'live_A8iyj3kBLfq4YUiKwlHoPpvBP0B7BQIBhY3vOPuDisc';
      print('🔧 ЮKassa: ПРОДАКШН режим');
    }

    // Apple In-App Purchase настройки
    appleIAPKeyId = _getEnv('APPLE_IAP_KEY_ID', defaultValue: '') ?? '';
    appleIAPIssuerId = _getEnv('APPLE_IAP_ISSUER_ID', defaultValue: '') ?? '';
    appleIAPPrivateKey = _getEnv('APPLE_IAP_PRIVATE_KEY', defaultValue: '') ?? '';
    appleBundleId = _getEnv('APPLE_BUNDLE_ID', defaultValue: 'com.aviapoint.app') ?? 'com.aviapoint.app';
  }

  static bool get isLocal => environment == 'local';
  static bool get isRemote => environment == 'remote';
}
