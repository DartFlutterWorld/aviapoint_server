#!/usr/bin/env dart

/// Скрипт для проверки статуса миграции 030 и данных в airports
/// Использование: dart scripts/check_migration_030_status.dart

import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:aviapoint_server/core/config/config.dart';

Future<void> main() async {
  print('═══════════════════════════════════════════════════════════');
  print('  Проверка статуса миграции 030 и данных airports');
  print('═══════════════════════════════════════════════════════════\n');

  // Инициализируем конфигурацию
  Config.init();
  
  final connection = await Connection.open(
    Endpoint(
      host: Config.dbHost,
      port: Config.dbPort,
      database: Config.database,
      username: Config.username,
      password: Config.dbPassword,
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );

  print('✅ Подключение к БД установлено\n');

  try {
    // Проверяем статус миграции 030
    print('1. Проверка статуса миграции 030...');
    final migrationResult = await connection.execute(
      Sql("SELECT version, name, executed_at FROM schema_migrations WHERE version = '030'"),
    );

    if (migrationResult.isEmpty) {
      print('❌ Миграция 030 НЕ выполнена!');
    } else {
      final migration = migrationResult.first;
      print('✅ Миграция 030 выполнена:');
      print('   Версия: ${migration[0]}');
      print('   Имя: ${migration[1]}');
      print('   Выполнена: ${migration[2]}');
    }

    // Проверяем количество записей в airports
    print('\n2. Проверка данных в таблице airports...');
    final countResult = await connection.execute(
      Sql('SELECT COUNT(*) FROM airports'),
    );
    final count = countResult.first[0] as int;
    print('✅ Записей в таблице airports: $count');

    if (count == 0) {
      print('\n⚠️  Таблица airports пуста!');
      print('   Возможные причины:');
      print('   1. Миграция 030 не выполнилась');
      print('   2. Файл миграции не найден на сервере');
      print('   3. Ошибка при выполнении миграции');
    } else {
      print('\n✅ Данные в таблице airports есть');
      
      // Показываем несколько примеров
      final sampleResult = await connection.execute(
        Sql('SELECT ident, name, type FROM airports LIMIT 5'),
      );
      print('\n   Примеры записей:');
      for (final row in sampleResult) {
        print('   - ${row[0]} | ${row[1]} | ${row[2]}');
      }
    }

    // Проверяем наличие файла миграции
    print('\n3. Проверка файла миграции...');
    final migrationFile = File('migrations/030_insert_airports_data.sql');
    if (await migrationFile.exists()) {
      final fileSize = await migrationFile.length();
      print('✅ Файл миграции существует: ${migrationFile.path}');
      print('   Размер: ${(fileSize / 1024).toStringAsFixed(2)} KB');
    } else {
      print('❌ Файл миграции НЕ найден: ${migrationFile.path}');
    }

  } catch (e, stackTrace) {
    print('❌ Ошибка: $e');
    print('Stack trace: $stackTrace');
  } finally {
    await connection.close();
  }
}

