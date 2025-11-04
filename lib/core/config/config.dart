import 'dart:io';

class Config {
  static final String environment = Platform.environment['ENVIRONMENT'] ?? 'local';

  static late final String dbHost;
  static late final String dbPassword;
  static final int serverPort = 8080;
  static final String database = 'aviapoint';
  static final String username = 'postgres';

  static void init() {
    if (environment == 'local') {
      dbHost = Platform.environment['POSTGRESQL_HOST'] ?? '127.0.0.1';
      dbPassword = Platform.environment['POSTGRESQL_PASSWORD'] ?? 'password';
    } else {
      dbHost = Platform.environment['POSTGRESQL_HOST'] ?? '83.166.246.205';
      dbPassword = Platform.environment['POSTGRESQL_PASSWORD'] ?? 'Metra1983@';
    }
  }

  static bool get isLocal => environment == 'local';
  static bool get isRemote => environment == 'remote';
}
