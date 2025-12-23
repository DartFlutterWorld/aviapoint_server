#!/usr/bin/env dart

/// Скрипт для выполнения миграций базы данных
/// Автоматически отслеживает выполненные миграции и выполняет только новые
///
/// Использование:
///   dart scripts/run_migrations.dart
///   dart scripts/run_migrations.dart --status  # Показать статус миграций
///   dart scripts/run_migrations.dart --rollback  # Откатить последнюю миграцию

import 'dart:io';
import 'package:aviapoint_server/core/config/config.dart';
import 'package:aviapoint_server/core/migrations/migration_manager.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:postgres/postgres.dart';

Future<void> main(List<String> args) async {
  print('🚀 Менеджер миграций базы данных\n');

  // Инициализируем конфигурацию
  Config.init();
  print('📊 Подключение к БД: ${Config.dbHost}:${Config.dbPort}/${Config.database}');

  // Подключаемся к БД
  Connection? connection;
  try {
    connection = await Connection.open(
      Endpoint(host: Config.dbHost, port: Config.dbPort, database: Config.database, username: Config.username, password: Config.dbPassword),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    print('✅ Подключение к БД установлено\n');
  } catch (e) {
    print('❌ Ошибка подключения к БД: $e');
    exit(1);
  }

  try {
    await LoggerSettings.initLogging(instancePrefix: 'Migrations');
    final migrationManager = MigrationManager(connection: connection);

    // Обработка аргументов командной строки
    if (args.contains('--status')) {
      print('📋 Статус миграций:\n');
      final status = await migrationManager.getMigrationStatus();
      if (status.isEmpty) {
        print('   Нет выполненных миграций');
      } else {
        for (final migration in status) {
          print('   ✅ ${migration['version']} - ${migration['name']} (${migration['executed_at']})');
        }
      }
    } else if (args.contains('--rollback')) {
      await migrationManager.rollbackLastMigration();
    } else {
      // Выполняем миграции
      await migrationManager.runMigrations();
    }
  } catch (e, stackTrace) {
    logger.severe('❌ Ошибка при выполнении миграций: $e', e, stackTrace);
    exit(1);
  } finally {
    await connection.close();
    print('\n👋 Соединение с БД закрыто');
  }
}
