import 'dart:io';

class Config {
  static final String environment = Platform.environment['ENVIRONMENT'] ?? 'local';

  static late final String dbHost;
  static late final int dbPort;
  static late final String dbPassword;
  static final int serverPort = 8080;
  static final String database = 'aviapoint';
  static final String username = 'postgres';

  // ЮKassa настройки
  static late final String yookassaShopId;
  static late final String yookassaSecretKey;

  // Apple In-App Purchase настройки
  static late final String appleIAPKeyId;
  static late final String appleIAPIssuerId;
  static late final String appleIAPPrivateKey;
  static late final String appleBundleId;

  // Период публикации объявлений (в месяцах)
  // Можно настроить через переменную окружения PUBLICATION_DURATION_MONTHS (по умолчанию 1 месяц)
  static int get publicationDurationMonths => int.tryParse(Platform.environment['PUBLICATION_DURATION_MONTHS'] ?? '1') ?? 1;

  static void init() {
    if (environment == 'local') {
      dbHost = Platform.environment['POSTGRESQL_HOST'] ?? '127.0.0.1';
      dbPort = int.tryParse(Platform.environment['POSTGRESQL_PORT'] ?? '5432') ?? 5432;
      dbPassword = Platform.environment['POSTGRESQL_PASSWORD'] ?? 'password';
    } else {
      dbHost = Platform.environment['POSTGRESQL_HOST'] ?? '83.166.246.205';
      dbPort = int.tryParse(Platform.environment['POSTGRESQL_PORT'] ?? '5432') ?? 5432;
      dbPassword = Platform.environment['POSTGRESQL_PASSWORD'] ?? 'Metra1983@';
    }

    // ЮKassa настройки
    yookassaShopId = Platform.environment['YOOKASSA_SHOP_ID'] ?? '1214860';
    yookassaSecretKey = Platform.environment['YOOKASSA_SECRET_KEY'] ?? 'live_A8iyj3kBLfq4YUiKwlHoPpvBP0B7BQIBhY3vOPuDisc';

    // Apple In-App Purchase настройки
    appleIAPKeyId = Platform.environment['APPLE_IAP_KEY_ID'] ?? '';
    appleIAPIssuerId = Platform.environment['APPLE_IAP_ISSUER_ID'] ?? '';
    appleIAPPrivateKey = Platform.environment['APPLE_IAP_PRIVATE_KEY'] ?? '';
    appleBundleId = Platform.environment['APPLE_BUNDLE_ID'] ?? 'com.aviapoint.app';
  }

  static bool get isLocal => environment == 'local';
  static bool get isRemote => environment == 'remote';
}
