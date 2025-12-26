#!/usr/bin/env dart

/// Скрипт для ручного добавления поля airport_code
///
/// Использование:
///   dart scripts/add_airport_code_manually.dart

import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:aviapoint_server/core/config/config.dart';

Future<void> main(List<String> args) async {
  print('🔧 Ручное добавление поля airport_code в таблицу airport_ownership_requests...\n');

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
      Sql('SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = \'airport_ownership_requests\')'),
    );
    
    if (tableCheck.isEmpty || !(tableCheck.first[0] as bool)) {
      print('❌ Таблица airport_ownership_requests не существует!');
      exit(1);
    }

    // Проверяем, есть ли уже поле airport_code
    final columnCheck = await connection.execute(
      Sql('''
        SELECT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name = 'airport_ownership_requests' AND column_name = 'airport_code'
        )
      '''),
    );
    
    if (columnCheck.isNotEmpty && (columnCheck.first[0] as bool)) {
      print('✅ Поле airport_code уже существует в таблице');
      exit(0);
    }

    print('📝 Добавляем поле airport_code...');
    
    // Добавляем поле
    await connection.execute(
      Sql('ALTER TABLE airport_ownership_requests ADD COLUMN IF NOT EXISTS airport_code VARCHAR(10)'),
    );
    
    print('✅ Поле airport_code добавлено');
    
    // Создаем индекс
    print('📝 Создаем индекс...');
    await connection.execute(
      Sql('CREATE INDEX IF NOT EXISTS idx_airport_ownership_requests_airport_code ON airport_ownership_requests(airport_code) WHERE airport_code IS NOT NULL'),
    );
    
    print('✅ Индекс создан');
    
    // Добавляем комментарий
    print('📝 Добавляем комментарий...');
    await connection.execute(
      Sql("COMMENT ON COLUMN airport_ownership_requests.airport_code IS 'Код ICAO аэропорта'"),
    );
    
    print('✅ Комментарий добавлен');
    
    // Проверяем результат
    final verifyCheck = await connection.execute(
      Sql('''
        SELECT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name = 'airport_ownership_requests' AND column_name = 'airport_code'
        )
      '''),
    );
    
    if (verifyCheck.isNotEmpty && (verifyCheck.first[0] as bool)) {
      print('\n✅ Успешно! Поле airport_code теперь присутствует в таблице');
    } else {
      print('\n❌ Ошибка: поле airport_code не было добавлено');
      exit(1);
    }

  } catch (e, stackTrace) {
    print('\n❌ Ошибка при добавлении поля: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  } finally {
    await connection.close();
    print('\n👋 Соединение с БД закрыто');
  }
}

