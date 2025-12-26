#!/usr/bin/env dart

/// Скрипт для получения статистики по аэродромам и вертодромам
///
/// Использование:
///   dart scripts/get_airports_statistics.dart

import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:aviapoint_server/core/config/config.dart';

Future<void> main(List<String> args) async {
  print('📊 Получение статистики по аэродромам и вертодромам...\n');

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
      print('📝 Сначала выполните миграцию: migrations/recreate_airports_table_aopa.sql');
      exit(1);
    }

    // Общая статистика
    print('📈 ОБЩАЯ СТАТИСТИКА\n');
    print('─' * 50);

    // Всего записей
    final totalResult = await connection.execute(Sql('SELECT COUNT(*) FROM airports'));
    final total = totalResult.first[0] as int;
    print('Всего записей в базе: $total\n');

    // Действующие vs недействующие
    final activeResult = await connection.execute(Sql('SELECT COUNT(*) FROM airports WHERE is_active = true'));
    final active = activeResult.first[0] as int;
    final inactive = total - active;
    print('✅ Действующих: $active');
    print('❌ Недействующих: $inactive\n');

    // Статистика по типам
    print('📋 СТАТИСТИКА ПО ТИПАМ\n');
    print('─' * 50);

    final typeStatsResult = await connection.execute(Sql('''
      SELECT 
        type,
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE is_active = true) as active,
        COUNT(*) FILTER (WHERE is_active = false) as inactive
      FROM airports
      GROUP BY type
      ORDER BY total DESC
    '''));

    if (typeStatsResult.isEmpty) {
      print('⚠️  Нет данных в таблице airports');
    } else {
      print('Тип'.padRight(30) + 'Всего'.padLeft(10) + 'Действующих'.padLeft(15) + 'Недействующих'.padLeft(18));
      print('─' * 73);
      
      for (final row in typeStatsResult) {
        final type = row[0] as String;
        final total = row[1] as int;
        final active = row[2] as int;
        final inactive = row[3] as int;
        
        print(type.padRight(30) + total.toString().padLeft(10) + active.toString().padLeft(15) + inactive.toString().padLeft(18));
      }
    }

    // Детальная статистика по действующим аэродромам и вертодромам
    print('\n\n🎯 ДЕЙСТВУЮЩИЕ АЭРОДРОМЫ И ВЕРТОДРОМЫ\n');
    print('─' * 50);

    final activeTypeResult = await connection.execute(Sql('''
      SELECT 
        type,
        COUNT(*) as count
      FROM airports
      WHERE is_active = true
      GROUP BY type
      ORDER BY count DESC
    '''));

    if (activeTypeResult.isEmpty) {
      print('⚠️  Нет действующих аэродромов/вертодромов');
    } else {
      int totalActive = 0;
      for (final row in activeTypeResult) {
        final type = row[0] as String;
        final count = row[1] as int;
        totalActive += count;
        print('$type: $count');
      }
      print('\nВсего действующих: $totalActive');
    }

    // Статистика по регионам (топ-10)
    print('\n\n🌍 ТОП-10 РЕГИОНОВ ПО КОЛИЧЕСТВУ ДЕЙСТВУЮЩИХ\n');
    print('─' * 50);

    final regionStatsResult = await connection.execute(Sql('''
      SELECT 
        region,
        COUNT(*) as count
      FROM airports
      WHERE is_active = true AND region IS NOT NULL
      GROUP BY region
      ORDER BY count DESC
      LIMIT 10
    '''));

    if (regionStatsResult.isEmpty) {
      print('⚠️  Нет данных по регионам');
    } else {
      for (final row in regionStatsResult) {
        final region = row[0] as String;
        final count = row[1] as int;
        print('$region: $count');
      }
    }

    // Статистика по странам
    print('\n\n🌐 СТАТИСТИКА ПО СТРАНАМ\n');
    print('─' * 50);

    final countryStatsResult = await connection.execute(Sql('''
      SELECT 
        COALESCE(country, country_code, 'Не указано') as country_name,
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE is_active = true) as active
      FROM airports
      GROUP BY country_name
      ORDER BY total DESC
    '''));

    if (countryStatsResult.isEmpty) {
      print('⚠️  Нет данных по странам');
    } else {
      print('Страна'.padRight(40) + 'Всего'.padLeft(10) + 'Действующих'.padLeft(15));
      print('─' * 65);
      
      for (final row in countryStatsResult) {
        final country = row[0] as String;
        final total = row[1] as int;
        final active = row[2] as int;
        print(country.padRight(40) + total.toString().padLeft(10) + active.toString().padLeft(15));
      }
    }

    // Статистика по международным
    print('\n\n✈️  МЕЖДУНАРОДНЫЕ АЭРОДРОМЫ\n');
    print('─' * 50);

    final internationalResult = await connection.execute(Sql('''
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE is_active = true) as active
      FROM airports
      WHERE is_international = true
    '''));

    if (internationalResult.isNotEmpty) {
      final total = internationalResult.first[0] as int;
      final active = internationalResult.first[1] as int;
      print('Всего международных: $total');
      print('Действующих международных: $active');
    }

  } catch (e, stackTrace) {
    print('\n❌ Ошибка при получении статистики: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  } finally {
    await connection.close();
    print('\n\n👋 Соединение с БД закрыто');
  }
}

