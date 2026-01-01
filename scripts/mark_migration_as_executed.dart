#!/usr/bin/env dart

/// Скрипт для пометки миграции как выполненной в schema_migrations
/// Использование: dart scripts/mark_migration_as_executed.dart <version> <name>
/// Пример: dart scripts/mark_migration_as_executed.dart 001 create_payments_table

import 'dart:io';
import 'package:postgres/postgres.dart';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print('Использование: dart scripts/mark_migration_as_executed.dart <version> <name>');
    print('Пример: dart scripts/mark_migration_as_executed.dart 001 create_payments_table');
    exit(1);
  }

  final version = args[0];
  final name = args[1];

  // Получаем параметры подключения из переменных окружения
  final dbHost = Platform.environment['DB_HOST'] ?? 'localhost';
  final dbPort = int.tryParse(Platform.environment['DB_PORT'] ?? '5432') ?? 5432;
  final database = Platform.environment['DATABASE'] ?? 'aviapoint';
  final username = Platform.environment['DB_USER'] ?? 'postgres';
  final password = Platform.environment['DB_PASSWORD'] ?? 'postgres';

  print('Подключение к БД: $dbHost:$dbPort/$database');

  try {
    final connection = await Connection.open(
      Endpoint(
        host: dbHost,
        port: dbPort,
        database: database,
        username: username,
        password: password,
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );

    print('✅ Подключение установлено');

    // Проверяем, существует ли запись
    final checkResult = await connection.execute(
      Sql.named('SELECT version FROM schema_migrations WHERE version = @version'),
      parameters: {'version': version},
    );

    if (checkResult.isNotEmpty) {
      print('⚠️  Миграция $version ($name) уже помечена как выполненная');
      await connection.close();
      exit(0);
    }

    // Добавляем запись
    await connection.execute(
      Sql.named('''
        INSERT INTO schema_migrations (version, name)
        VALUES (@version, @name)
        ON CONFLICT (version) DO NOTHING
      '''),
      parameters: {'version': version, 'name': name},
    );

    print('✅ Миграция $version ($name) помечена как выполненная');

    await connection.close();
  } catch (e, stackTrace) {
    print('❌ Ошибка: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}


