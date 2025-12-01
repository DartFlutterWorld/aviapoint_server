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
  }

  static bool get isLocal => environment == 'local';
  static bool get isRemote => environment == 'remote';
}
