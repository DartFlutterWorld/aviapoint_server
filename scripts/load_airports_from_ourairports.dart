#!/usr/bin/env dart

/// Скрипт для загрузки аэропортов из OurAirports в базу данных
/// Загружает только аэропорты из России (iso_country = 'RU')
///
/// Использование:
///   dart scripts/load_airports_from_ourairports.dart
///
/// Или с указанием файла:
///   dart scripts/load_airports_from_ourairports.dart --csv path/to/airports.csv

import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:aviapoint_server/core/config/config.dart';

Future<void> main(List<String> args) async {
  print('🚀 Начинаем загрузку аэропортов из OurAirports...\n');

  // Определяем путь к CSV файлу
  String csvPath = 'airports.csv';
  if (args.isNotEmpty && args.contains('--csv')) {
    final index = args.indexOf('--csv');
    if (index + 1 < args.length) {
      csvPath = args[index + 1];
    }
  }

  // Проверяем существование файла
  final csvFile = File(csvPath);
  if (!await csvFile.exists()) {
    print('❌ Файл $csvPath не найден!');
    print('📥 Скачайте airports.csv с https://ourairports.com/data/');
    print('   Или укажите путь: dart scripts/load_airports_from_ourairports.dart --csv /path/to/airports.csv');
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

    // Находим индексы нужных колонок
    final identIndex = headers.indexWhere((h) => h == 'ident');
    final typeIndex = headers.indexWhere((h) => h == 'type');
    final nameIndex = headers.indexWhere((h) => h == 'name');
    final latitudeIndex = headers.indexWhere((h) => h == 'latitude_deg');
    final longitudeIndex = headers.indexWhere((h) => h == 'longitude_deg');
    final elevationIndex = headers.indexWhere((h) => h == 'elevation_ft');
    final continentIndex = headers.indexWhere((h) => h == 'continent');
    final isoCountryIndex = headers.indexWhere((h) => h == 'iso_country');
    final isoRegionIndex = headers.indexWhere((h) => h == 'iso_region');
    final municipalityIndex = headers.indexWhere((h) => h == 'municipality');
    final scheduledServiceIndex = headers.indexWhere((h) => h == 'scheduled_service');
    final gpsCodeIndex = headers.indexWhere((h) => h == 'gps_code');
    final iataCodeIndex = headers.indexWhere((h) => h == 'iata_code');
    final localCodeIndex = headers.indexWhere((h) => h == 'local_code');

    // Проверяем, что все нужные колонки найдены
    final requiredColumns = {'ident': identIndex, 'type': typeIndex, 'name': nameIndex, 'latitude_deg': latitudeIndex, 'longitude_deg': longitudeIndex, 'iso_country': isoCountryIndex};

    for (final entry in requiredColumns.entries) {
      if (entry.value == -1) {
        print('❌ Колонка "${entry.key}" не найдена в CSV файле!');
        exit(1);
      }
    }

    // Фильтруем только российские аэропорты и парсим данные
    print('🔍 Фильтруем аэропорты России (iso_country = RU)...');
    final russianAirports = <Map<String, dynamic>>[];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;

      // Парсим CSV строку (учитываем кавычки и запятые внутри значений)
      final values = _parseCsvLine(line).map((v) => v?.trim().replaceAll('"', '') ?? '').toList();

      if (values.length <= isoCountryIndex) continue;

      final isoCountry = values[isoCountryIndex].trim();
      if (isoCountry != 'RU') continue;

      // Извлекаем данные
      final ident = values[identIndex].trim();
      final type = values[typeIndex].trim();
      final name = values[nameIndex].trim();
      final latitudeStr = values[latitudeIndex].trim();
      final longitudeStr = values[longitudeIndex].trim();

      if (ident.isEmpty || type.isEmpty || name.isEmpty || latitudeStr.isEmpty || longitudeStr.isEmpty) {
        continue;
      }

      final latitude = double.tryParse(latitudeStr);
      final longitude = double.tryParse(longitudeStr);

      if (latitude == null || longitude == null) continue;

      final airport = <String, dynamic>{
        'ident': ident,
        'type': type,
        'name': name,
        'latitude_deg': latitude,
        'longitude_deg': longitude,
        'elevation_ft': values.length > elevationIndex && elevationIndex >= 0 && values[elevationIndex].isNotEmpty ? int.tryParse(values[elevationIndex]) : null,
        'continent': values.length > continentIndex && continentIndex >= 0 && values[continentIndex].isNotEmpty ? values[continentIndex] : null,
        'iso_country': 'RU',
        'iso_region': values.length > isoRegionIndex && isoRegionIndex >= 0 && values[isoRegionIndex].isNotEmpty ? values[isoRegionIndex] : null,
        'municipality': values.length > municipalityIndex && municipalityIndex >= 0 && values[municipalityIndex].isNotEmpty ? values[municipalityIndex] : null,
        'scheduled_service': values.length > scheduledServiceIndex && scheduledServiceIndex >= 0 && values[scheduledServiceIndex].isNotEmpty ? values[scheduledServiceIndex] : null,
        'gps_code': values.length > gpsCodeIndex && gpsCodeIndex >= 0 && values[gpsCodeIndex].isNotEmpty ? values[gpsCodeIndex] : null,
        'iata_code': values.length > iataCodeIndex && iataCodeIndex >= 0 && values[iataCodeIndex].isNotEmpty ? values[iataCodeIndex] : null,
        'local_code': values.length > localCodeIndex && localCodeIndex >= 0 && values[localCodeIndex].isNotEmpty ? values[localCodeIndex] : null,
      };

      russianAirports.add(airport);
    }

    print('✅ Найдено российских аэропортов: ${russianAirports.length}\n');

    if (russianAirports.isEmpty) {
      print('❌ Не найдено ни одного российского аэропорта!');
      exit(1);
    }

    // Очищаем старые данные (опционально, можно закомментировать)
    print('🗑️  Очищаем старые данные из OurAirports...');
    await connection.execute(Sql.named('DELETE FROM airports WHERE source = @source'), parameters: {'source': 'ourairports'});
    print('✅ Старые данные удалены\n');

    // Загружаем данные в БД
    print('💾 Загружаем данные в БД...');
    int inserted = 0;
    int errors = 0;

    for (final airport in russianAirports) {
      try {
        await connection.execute(
          Sql.named('''
            INSERT INTO airports (
              ident, type, name, latitude_deg, longitude_deg,
              elevation_ft, continent, iso_country, iso_region,
              municipality, scheduled_service, gps_code, iata_code,
              local_code, services, source, is_active
            ) VALUES (
              @ident, @type, @name, @latitude_deg, @longitude_deg,
              @elevation_ft, @continent, @iso_country, @iso_region,
              @municipality, @scheduled_service, @gps_code, @iata_code,
              @local_code, @services, @source, @is_active
            )
            ON CONFLICT (ident) DO UPDATE SET
              type = EXCLUDED.type,
              name = EXCLUDED.name,
              latitude_deg = EXCLUDED.latitude_deg,
              longitude_deg = EXCLUDED.longitude_deg,
              elevation_ft = EXCLUDED.elevation_ft,
              continent = EXCLUDED.continent,
              iso_country = EXCLUDED.iso_country,
              iso_region = EXCLUDED.iso_region,
              municipality = EXCLUDED.municipality,
              scheduled_service = EXCLUDED.scheduled_service,
              gps_code = EXCLUDED.gps_code,
              iata_code = EXCLUDED.iata_code,
              local_code = EXCLUDED.local_code,
              updated_at = NOW()
          '''),
          parameters: {
            'ident': airport['ident'],
            'type': airport['type'],
            'name': airport['name'],
            'latitude_deg': airport['latitude_deg'],
            'longitude_deg': airport['longitude_deg'],
            'elevation_ft': airport['elevation_ft'],
            'continent': airport['continent'],
            'iso_country': airport['iso_country'],
            'iso_region': airport['iso_region'],
            'municipality': airport['municipality'],
            'scheduled_service': airport['scheduled_service'],
            'gps_code': airport['gps_code'],
            'iata_code': airport['iata_code'],
            'local_code': airport['local_code'],
            'services': '{}', // Пустой JSON объект по умолчанию
            'source': 'ourairports',
            'is_active': true,
          },
        );
        inserted++;
        if (inserted % 100 == 0) {
          print('   Загружено: $inserted...');
        }
      } catch (e) {
        errors++;
        print('   ⚠️  Ошибка при загрузке ${airport['ident']}: $e');
      }
    }

    print('\n✅ Загрузка завершена!');
    print('   📊 Загружено: $inserted аэропортов');
    if (errors > 0) {
      print('   ⚠️  Ошибок: $errors');
    }

    // Выводим статистику
    final stats = await connection.execute(Sql('SELECT type, COUNT(*) FROM airports WHERE iso_country = \'RU\' GROUP BY type ORDER BY COUNT(*) DESC'));
    print('\n📈 Статистика по типам:');
    for (final row in stats) {
      print('   ${row[0]}: ${row[1]}');
    }
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
