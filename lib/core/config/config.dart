import 'dart:io';

class Config {
  static final String dbHost = Platform.environment['POSTGRESQL_HOST'] ?? 'localhost';
  static final String dbPassword = Platform.environment['POSTGRESQL_PASSWORD'] ?? 'password';
  static final int serverPort = 8080;
  static final String database = 'aviapoint';
  static final String username = 'postgres';
}
