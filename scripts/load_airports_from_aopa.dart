#!/usr/bin/env dart

/// Скрипт для загрузки аэропортов из АОПА-Россия (maps.aopa.ru) в базу данных
///
/// Использование:
///   dart scripts/load_airports_from_aopa.dart --csv public/aopa-points-export.csv
///
/// CSV файл должен быть в формате АОПА с разделителем ";" (точка с запятой)

import 'dart:io';
import 'dart:convert';
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

  // По умолчанию используем файл из public
  if (csvPath == null) {
    csvPath = 'public/aopa-points-export.csv';
  }

  // Проверяем существование файла
  final csvFile = File(csvPath);
  if (!await csvFile.exists()) {
    print('❌ Файл $csvPath не найден!');
    print('📥 Убедитесь, что файл находится в папке public/');
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
      print('📝 Сначала выполните миграцию: migrations/recreate_airports_table_aopa.sql');
      exit(1);
    }

    // Читаем CSV файл
    print('📖 Читаем файл $csvPath...');
    final content = await csvFile.readAsString(encoding: utf8);
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    print('📊 Найдено строк: ${lines.length}\n');

    if (lines.length < 2) {
      print('❌ Файл должен содержать заголовки и хотя бы одну строку данных!');
      exit(1);
    }

    // Парсим заголовки (первая строка) - разделитель ";"
    final headers = _parseCsvLine(lines[0]);
    print('📋 Заголовки (${headers.length}): ${headers.take(5).join(", ")}...\n');

    // Маппинг заголовков на индексы
    final headerMap = <String, int>{};
    for (int i = 0; i < headers.length; i++) {
      headerMap[headers[i].trim()] = i;
    }

    // Проверяем наличие обязательных полей
    final requiredFields = ['Тип', 'Название', 'Долгота КТА', 'Широта КТА', 'Индекс'];
    for (final field in requiredFields) {
      if (!headerMap.containsKey(field)) {
        print('❌ Отсутствует обязательное поле: $field');
        print('📋 Доступные поля: ${headerMap.keys.join(", ")}');
        exit(1);
      }
    }

    // Начинаем транзакцию
    await connection.execute(Sql('BEGIN'));

    int imported = 0;
    int skipped = 0;
    int errors = 0;
    final typeStats = <String, int>{};

    print('📥 Начинаем импорт данных...\n');

    // Обрабатываем каждую строку данных (начиная со второй)
    for (int i = 1; i < lines.length; i++) {
      try {
        final values = _parseCsvLine(lines[i]);

        if (values.length < headers.length) {
          // Дополняем пустыми значениями, если нужно
          while (values.length < headers.length) {
            values.add('');
          }
        }

        // Извлекаем данные
        final isActive = _getValue(values, headerMap, 'Действующий')?.toLowerCase() == 'действующий';
        final type = _getValue(values, headerMap, 'Тип') ?? '';
        final name = _getValue(values, headerMap, 'Название') ?? '';
        final nameEng = _getValue(values, headerMap, 'Название [eng]');
        final city = _getValue(values, headerMap, 'Город');
        final ident = _getValue(values, headerMap, 'Индекс') ?? '';
        final identRu = _getValue(values, headerMap, 'Индекс RU');
        final countryCode = _getValue(values, headerMap, 'Код страны');
        final country = _getValue(values, headerMap, 'Страна');
        final countryEng = _getValue(values, headerMap, 'Страна [анг]');
        final region = _getValue(values, headerMap, 'Регион');
        final regionEng = _getValue(values, headerMap, 'Регион [анг]');
        final coordinatesText = _getValue(values, headerMap, 'КТА');
        final longitudeStr = _getValue(values, headerMap, 'Долгота КТА') ?? '';
        final latitudeStr = _getValue(values, headerMap, 'Широта КТА') ?? '';
        final elevationStr = _getValue(values, headerMap, 'Превышение');
        final ownership = _getValue(values, headerMap, 'Принадлежность');
        final isInternational = _getValue(values, headerMap, 'Международный')?.toLowerCase() == 'да';
        final email = _getValue(values, headerMap, 'Email');
        final website = _getValue(values, headerMap, 'Web-сайт');
        final notes = _getValue(values, headerMap, 'Примечание');
        final runwayName = _getValue(values, headerMap, 'Название основной ВПП');
        final runwayLengthStr = _getValue(values, headerMap, 'Длина основной ВПП');
        final runwayWidthStr = _getValue(values, headerMap, 'Ширина основной ВПП');
        final runwaySurface = _getValue(values, headerMap, 'Покрытие основной ВПП');
        final runwayMagneticCourse = _getValue(values, headerMap, 'Магнитный курс основной ВПП');
        final runwayLighting = _getValue(values, headerMap, 'Освещение основной ВПП');

        // Валидация обязательных полей
        if (ident.isEmpty || name.isEmpty || longitudeStr.isEmpty || latitudeStr.isEmpty) {
          skipped++;
          continue;
        }

        // Парсим координаты
        final longitude = double.tryParse(longitudeStr.replaceAll(',', '.')) ?? 0.0;
        final latitude = double.tryParse(latitudeStr.replaceAll(',', '.')) ?? 0.0;

        if (longitude == 0.0 || latitude == 0.0) {
          skipped++;
          continue;
        }

        // Парсим высоту
        int? elevation;
        if (elevationStr != null && elevationStr.isNotEmpty) {
          elevation = int.tryParse(elevationStr);
        }

        // Парсим размеры ВПП
        int? runwayLength;
        if (runwayLengthStr != null && runwayLengthStr.isNotEmpty) {
          runwayLength = int.tryParse(runwayLengthStr);
        }

        int? runwayWidth;
        if (runwayWidthStr != null && runwayWidthStr.isNotEmpty) {
          runwayWidth = int.tryParse(runwayWidthStr);
        }

        // Вставляем данные
        await connection.execute(
          Sql.named('''
            INSERT INTO airports (
              is_active, type, name, name_eng, city, ident, ident_ru,
              country_code, country, country_eng, region, region_eng,
              coordinates_text, longitude_deg, latitude_deg, elevation_ft,
              ownership, is_international, email, website, notes,
              runway_name, runway_length, runway_width, runway_surface,
              runway_magnetic_course, runway_lighting, source
            ) VALUES (
              @is_active, @type, @name, @name_eng, @city, @ident, @ident_ru,
              @country_code, @country, @country_eng, @region, @region_eng,
              @coordinates_text, @longitude_deg, @latitude_deg, @elevation_ft,
              @ownership, @is_international, @email, @website, @notes,
              @runway_name, @runway_length, @runway_width, @runway_surface,
              @runway_magnetic_course, @runway_lighting, @source
            )
            ON CONFLICT (ident) DO UPDATE SET
              is_active = EXCLUDED.is_active,
              type = EXCLUDED.type,
              name = EXCLUDED.name,
              name_eng = EXCLUDED.name_eng,
              city = EXCLUDED.city,
              ident_ru = EXCLUDED.ident_ru,
              country_code = EXCLUDED.country_code,
              country = EXCLUDED.country,
              country_eng = EXCLUDED.country_eng,
              region = EXCLUDED.region,
              region_eng = EXCLUDED.region_eng,
              coordinates_text = EXCLUDED.coordinates_text,
              longitude_deg = EXCLUDED.longitude_deg,
              latitude_deg = EXCLUDED.latitude_deg,
              elevation_ft = EXCLUDED.elevation_ft,
              ownership = EXCLUDED.ownership,
              is_international = EXCLUDED.is_international,
              email = EXCLUDED.email,
              website = EXCLUDED.website,
              notes = EXCLUDED.notes,
              runway_name = EXCLUDED.runway_name,
              runway_length = EXCLUDED.runway_length,
              runway_width = EXCLUDED.runway_width,
              runway_surface = EXCLUDED.runway_surface,
              runway_magnetic_course = EXCLUDED.runway_magnetic_course,
              runway_lighting = EXCLUDED.runway_lighting,
              updated_at = NOW()
          '''),
          parameters: {
            'is_active': isActive,
            'type': type,
            'name': name,
            'name_eng': nameEng,
            'city': city,
            'ident': ident,
            'ident_ru': identRu,
            'country_code': countryCode,
            'country': country,
            'country_eng': countryEng,
            'region': region,
            'region_eng': regionEng,
            'coordinates_text': coordinatesText,
            'longitude_deg': longitude,
            'latitude_deg': latitude,
            'elevation_ft': elevation,
            'ownership': ownership,
            'is_international': isInternational,
            'email': email,
            'website': website,
            'notes': notes,
            'runway_name': runwayName,
            'runway_length': runwayLength,
            'runway_width': runwayWidth,
            'runway_surface': runwaySurface,
            'runway_magnetic_course': runwayMagneticCourse,
            'runway_lighting': runwayLighting,
            'source': 'aopa',
          },
        );

        imported++;
        typeStats[type] = (typeStats[type] ?? 0) + 1;

        if (imported % 100 == 0) {
          print('  ✅ Импортировано: $imported записей...');
        }
      } catch (e) {
        errors++;
        if (errors <= 5) {
          print('  ⚠️  Ошибка в строке ${i + 1}: $e');
        }
      }
    }

    // Коммитим транзакцию
    await connection.execute(Sql('COMMIT'));

    print('\n✅ Импорт завершен!');
    print('📊 Статистика:');
    print('   Импортировано: $imported');
    print('   Пропущено: $skipped');
    print('   Ошибок: $errors');
    print('\n📋 По типам:');
    typeStats.forEach((type, count) {
      print('   $type: $count');
    });
  } catch (e, stackTrace) {
    await connection.execute(Sql('ROLLBACK'));
    print('\n❌ Ошибка при импорте: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  } finally {
    await connection.close();
    print('\n👋 Соединение с БД закрыто');
  }
}

/// Парсит CSV строку с разделителем ";", учитывая кавычки
List<String> _parseCsvLine(String line) {
  final result = <String>[];
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
    } else if (char == ';' && !inQuotes) {
      // Конец поля
      result.add(buffer.toString().trim());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }

  // Добавляем последнее поле
  result.add(buffer.toString().trim());

  return result;
}

/// Получает значение из массива по индексу из headerMap
String? _getValue(List<String> values, Map<String, int> headerMap, String headerName) {
  final index = headerMap[headerName];
  if (index == null || index >= values.length) {
    return null;
  }
  final value = values[index];
  return value.isEmpty ? null : value;
}
