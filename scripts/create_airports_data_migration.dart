#!/usr/bin/env dart

/// Скрипт для создания миграции с данными airports из локальной БД
/// Использование: dart scripts/create_airports_data_migration.dart
/// 
/// Создаст файл migrations/030_insert_airports_data.sql с данными из локальной БД

import 'dart:io';
import 'package:postgres/postgres.dart';

Future<void> main() async {
  print('═══════════════════════════════════════════════════════════');
  print('  Создание миграции с данными airports');
  print('═══════════════════════════════════════════════════════════\n');

  // Параметры подключения к локальной БД
  final connection = await Connection.open(
    Endpoint(
      host: 'localhost',
      port: 5432,
      database: 'aviapoint',
      username: 'postgres',
      password: 'postgres',
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );

  print('✅ Подключение к локальной БД установлено\n');

  try {
    // Получаем данные из локальной БД
    print('1. Получение данных из локальной БД...');
    final result = await connection.execute(
      Sql('SELECT * FROM airports ORDER BY id'),
    );

    if (result.isEmpty) {
      print('⚠️  В локальной БД нет данных в таблице airports');
      await connection.close();
      exit(0);
    }

    print('✅ Найдено записей: ${result.length}');

    // Получаем структуру таблицы
    print('\n2. Получение структуры таблицы...');
    final columnsResult = await connection.execute(
      Sql('''
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'airports' 
        ORDER BY ordinal_position
      '''),
    );

    final columns = columnsResult.map((row) => row[0] as String).toList();
    print('✅ Колонок: ${columns.length}');

    // Создаем SQL файл миграции
    print('\n3. Создание файла миграции...');
    final migrationFile = File('migrations/030_insert_airports_data.sql');
    final writer = migrationFile.openWrite();

    writer.writeln('-- Миграция данных airports из локальной БД');
    writer.writeln('-- Создано: ${DateTime.now().toIso8601String()}');
    writer.writeln('-- Количество записей: ${result.length}');
    writer.writeln('');
    writer.writeln('-- Вставляем данные только если таблица пуста');
    writer.writeln('DO \$\$');
    writer.writeln('DECLARE');
    writer.writeln('    record_count INTEGER;');
    writer.writeln('BEGIN');
    writer.writeln('    SELECT COUNT(*) INTO record_count FROM airports;');
    writer.writeln('    ');
    writer.writeln('    IF record_count = 0 THEN');
    writer.writeln('        -- Вставляем данные');
    writer.writeln('');

    int insertedCount = 0;
    for (final row in result) {
      final rowMap = row.toColumnMap();
      
      // Формируем INSERT только с не-null значениями
      final columnsToInsert = <String>[];
      final values = <String>[];

      for (final column in columns) {
        if (column == 'id') continue; // Пропускаем id, он будет сгенерирован

        final value = rowMap[column];
        if (value != null) {
          columnsToInsert.add(column);
          
          // Форматируем значение в зависимости от типа
          if (value is String) {
            // Экранируем одинарные кавычки
            final escapedValue = value.replaceAll("'", "''");
            values.add("'$escapedValue'");
          } else if (value is bool) {
            values.add(value ? 'TRUE' : 'FALSE');
          } else if (value is DateTime) {
            values.add("'${value.toIso8601String()}'::timestamp");
          } else if (value == null) {
            values.add('NULL');
          } else {
            values.add(value.toString());
          }
        }
      }

      if (columnsToInsert.isNotEmpty) {
        writer.writeln('        INSERT INTO airports (${columnsToInsert.join(', ')})');
        writer.writeln('        VALUES (${values.join(', ')})');
        writer.writeln('        ON CONFLICT (ident) DO NOTHING;');
        writer.writeln('');
        insertedCount++;
      }
    }

    writer.writeln('        RAISE NOTICE \'Вставлено записей: %\', $insertedCount;');
    writer.writeln('    ELSE');
    writer.writeln('        RAISE NOTICE \'Таблица airports уже содержит данные (%), пропускаем вставку\', record_count;');
    writer.writeln('    END IF;');
    writer.writeln('END');
    writer.writeln('\$\$;');

    await writer.close();
    print('✅ Файл миграции создан: ${migrationFile.path}');
    print('   Размер: ${(await migrationFile.length() / 1024).toStringAsFixed(2)} KB');
    print('   Записей для вставки: $insertedCount');

    print('\n═══════════════════════════════════════════════════════════');
    print('✅ Миграция создана!');
    print('═══════════════════════════════════════════════════════════');
    print('\nСледующие шаги:');
    print('1. Добавьте миграцию в MigrationManager (версия 030)');
    print('2. Закоммитьте файл в git');
    print('3. На проде: git pull');
    print('4. Перезапустите сервер - миграция выполнится автоматически');

  } catch (e, stackTrace) {
    print('❌ Ошибка: $e');
    print('Stack trace: $stackTrace');
    await connection.close();
    exit(1);
  } finally {
    await connection.close();
  }
}

