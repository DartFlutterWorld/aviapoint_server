#!/usr/bin/env dart

/// Скрипт для загрузки аэропортов из АОПА-Россия (maps.aopa.ru) в базу данных
///
/// Использование:
///   dart scripts/load_airports_from_aopa.dart --csv path/to/aopa_export.csv
///
/// Формат данных АОПА может отличаться, скрипт будет адаптирован под фактический формат экспорта

import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:aviapoint_server/core/config/config.dart';

Future<void> main(List<String> args) async {
  print('🚀 Начинаем загрузку аэропортов из АОПА-Россия...\n');

  // Определяем путь к CSV файлу
  String? csvPath;
  if (args.isNotEmpty && args.contains('--csv')) {
    final index = args.indexOf('--csv');
    if (index + 1 < args.length) {
      csvPath = args[index + 1];
    }
  }

  if (csvPath == null) {
    print('❌ Не указан путь к файлу экспорта!');
    print('📥 Использование: dart scripts/load_airports_from_aopa.dart --csv /path/to/aopa_export.csv');
    print('   Получите файл экспорта на: https://maps.aopa.ru/user/export/');
    exit(1);
  }

  // Проверяем существование файла
  final csvFile = File(csvPath);
  if (!await csvFile.exists()) {
    print('❌ Файл $csvPath не найден!');
    print('📥 Получите файл экспорта на: https://maps.aopa.ru/user/export/');
    exit(1);
  }

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
    final tableCheck = await connection.execute(Sql('SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = \'airports\')'));
    if (tableCheck.isEmpty || !(tableCheck.first[0] as bool)) {
      print('❌ Таблица airports не найдена!');
      print('📝 Сначала выполните миграцию: migrations/create_airports_table.sql');
      exit(1);
    }

    // Читаем CSV файл
    print('📖 Читаем файл $csvPath...');
    final lines = await csvFile.readAsLines();
    print('📊 Найдено строк: ${lines.length}\n');

    if (lines.isEmpty) {
      print('❌ Файл пуст!');
      exit(1);
    }

    // Парсим заголовки (первая строка) с учетом кавычек
    final headers = _parseCsvLine(lines[0]).map((h) => h?.trim().replaceAll('"', '') ?? '').toList();
    print('📋 Заголовки: ${headers.take(10).join(", ")}...\n');
    print('⚠️  ВНИМАНИЕ: Скрипт требует адаптации под фактический формат экспорта АОПА!');
    print('   Пожалуйста, проверьте структуру данных и обновите скрипт при необходимости.\n');

    // TODO: Адаптировать под фактический формат экспорта АОПА
    // Нужно определить:
    // - Какие колонки есть в экспорте
    // - Как они соответствуют полям таблицы airports
    // - Какие поля обязательны, какие опциональны

    print('📝 Для продолжения необходимо:');
    print('   1. Изучить структуру экспорта АОПА');
    print('   2. Определить соответствие колонок полям БД');
    print('   3. Обновить скрипт для правильного парсинга данных');
    print('\n💡 Пример структуры таблицы airports см. в AIRPORTS_SETUP.md');
  } finally {
    await connection.close();
    print('\n👋 Соединение с БД закрыто');
  }
}

/// Парсит CSV строку, учитывая кавычки и запятые внутри значений
List<String?> _parseCsvLine(String line) {
  final result = <String?>[];
  final buffer = StringBuffer();
  bool inQuotes = false;

  for (int i = 0; i < line.length; i++) {
    final char = line[i];

    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        // Экранированная кавычка
        buffer.write('"');
        i++; // Пропускаем следующую кавычку
      } else {
        // Начало/конец кавычек
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      // Конец поля
      result.add(buffer.isEmpty ? null : buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }

  // Добавляем последнее поле
  result.add(buffer.isEmpty ? null : buffer.toString());

  return result;
}
