#!/usr/bin/env dart

/// Скрипт для проверки статуса миграций
///
/// Использование:
///   dart scripts/check_migration_status.dart

import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:aviapoint_server/core/config/config.dart';
import 'package:aviapoint_server/core/migrations/migration_manager.dart';

Future<void> main(List<String> args) async {
  print('📊 Проверка статуса миграций...\n');

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
    final migrationManager = MigrationManager(connection: connection);
    
    // Получаем статус миграций
    final status = await migrationManager.getMigrationStatus();
    
    print('📋 Выполненные миграции:\n');
    print('─' * 70);
    print('Версия'.padRight(10) + 'Название'.padRight(40) + 'Выполнена'.padLeft(20));
    print('─' * 70);
    
    if (status.isEmpty) {
      print('⚠️  Нет выполненных миграций');
    } else {
      for (final migration in status) {
        final version = migration['version'] as String;
        final name = migration['name'] as String;
        final executedAt = migration['executed_at'] as DateTime;
        print(version.padRight(10) + name.padRight(40) + executedAt.toString().padLeft(20));
      }
    }
    
    print('─' * 70);
    print('\n✅ Всего выполнено миграций: ${status.length}');
    
    // Проверяем конкретную миграцию
    final migration018 = status.where((m) => m['version'] == '018').toList();
    if (migration018.isEmpty) {
      print('\n⚠️  Миграция 018 (add_missing_fields_to_airport_ownership_requests) НЕ выполнена!');
      print('   Запустите миграции: dart scripts/run_migrations.dart');
    } else {
      print('\n✅ Миграция 018 выполнена: ${migration018.first['executed_at']}');
    }
    
    // Проверяем наличие поля airport_code в таблице
    print('\n🔍 Проверка структуры таблицы airport_ownership_requests...\n');
    
    final tableCheck = await connection.execute(
      Sql('SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = \'airport_ownership_requests\')'),
    );
    
    if (tableCheck.isEmpty || !(tableCheck.first[0] as bool)) {
      print('❌ Таблица airport_ownership_requests не существует!');
    } else {
      final columnsResult = await connection.execute(
        Sql('''
          SELECT column_name, data_type, is_nullable
          FROM information_schema.columns
          WHERE table_name = 'airport_ownership_requests'
          ORDER BY ordinal_position
        '''),
      );
      
      print('📋 Колонки в таблице airport_ownership_requests:\n');
      final columns = columnsResult.map((row) => row[0] as String).toList();
      
      final requiredFields = ['id', 'user_id', 'airport_id', 'airport_code', 'email', 'phone', 'phone_from_request', 'full_name', 'comment', 'documents', 'status'];
      
      for (final field in requiredFields) {
        if (columns.contains(field)) {
          print('  ✅ $field');
        } else {
          print('  ❌ $field - ОТСУТСТВУЕТ!');
        }
      }
      
      print('\n📊 Всего колонок: ${columns.length}');
      print('📋 Все колонки: ${columns.join(", ")}');
      
      // Проверяем конкретно airport_code
      if (columns.contains('airport_code')) {
        print('\n✅ Поле airport_code присутствует в таблице');
      } else {
        print('\n❌ Поле airport_code ОТСУТСТВУЕТ в таблице!');
        print('   Нужно выполнить миграцию 018');
      }
    }

  } catch (e, stackTrace) {
    print('\n❌ Ошибка при проверке: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  } finally {
    await connection.close();
    print('\n👋 Соединение с БД закрыто');
  }
}

