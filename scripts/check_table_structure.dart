#!/usr/bin/env dart

/// Скрипт для проверки структуры таблицы в базе данных
///
/// Использование:
///   dart scripts/check_table_structure.dart airport_ownership_requests

import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:aviapoint_server/core/config/config.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Укажите имя таблицы');
    print('📝 Использование: dart scripts/check_table_structure.dart <table_name>');
    exit(1);
  }

  final tableName = args[0];
  print('📊 Проверка структуры таблицы: $tableName\n');

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
    // Проверяем существование таблицы
    final tableCheck = await connection.execute(
      Sql.named('SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = @table_name)'),
      parameters: {'table_name': tableName},
    );
    
    if (tableCheck.isEmpty || !(tableCheck.first[0] as bool)) {
      print('❌ Таблица $tableName не найдена!');
      exit(1);
    }

    // Получаем структуру таблицы
    final columnsResult = await connection.execute(
      Sql.named('''
        SELECT 
          column_name,
          data_type,
          character_maximum_length,
          is_nullable,
          column_default
        FROM information_schema.columns
        WHERE table_name = @table_name
        ORDER BY ordinal_position
      '''),
      parameters: {'table_name': tableName},
    );

    if (columnsResult.isEmpty) {
      print('⚠️  Таблица $tableName существует, но не содержит колонок');
      exit(1);
    }

    print('📋 Структура таблицы $tableName:\n');
    print('─' * 80);
    print('Колонка'.padRight(30) + 'Тип'.padLeft(20) + 'NULL'.padLeft(10) + 'По умолчанию'.padLeft(20));
    print('─' * 80);

    for (final row in columnsResult) {
      final columnName = row[0] as String;
      final dataType = row[1] as String;
      final maxLength = row[2] as int?;
      final isNullable = row[3] as String;
      final defaultValue = row[4] as String?;

      String typeDisplay = dataType;
      if (maxLength != null) {
        typeDisplay = '$dataType($maxLength)';
      }

      final nullableDisplay = isNullable == 'YES' ? 'YES' : 'NO';
      final defaultDisplay = defaultValue ?? '';

      print(columnName.padRight(30) + typeDisplay.padLeft(20) + nullableDisplay.padLeft(10) + defaultDisplay.padLeft(20));
    }

    print('─' * 80);
    print('\n✅ Всего колонок: ${columnsResult.length}');

    // Проверяем индексы
    final indexesResult = await connection.execute(
      Sql.named('''
        SELECT indexname, indexdef
        FROM pg_indexes
        WHERE tablename = @table_name
        ORDER BY indexname
      '''),
      parameters: {'table_name': tableName},
    );

    if (indexesResult.isNotEmpty) {
      print('\n📑 Индексы:\n');
      for (final row in indexesResult) {
        final indexName = row[0] as String;
        final indexDef = row[1] as String;
        print('  $indexName');
        print('    $indexDef\n');
      }
    }

  } catch (e, stackTrace) {
    print('\n❌ Ошибка при проверке структуры: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  } finally {
    await connection.close();
    print('\n👋 Соединение с БД закрыто');
  }
}

