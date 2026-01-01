import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:aviapoint_server/logger/logger.dart';

/// Менеджер миграций базы данных
/// Автоматически отслеживает выполненные миграции и выполняет только новые
class MigrationManager {
  final Connection _connection;

  MigrationManager({required Connection connection}) : _connection = connection;

  /// Инициализирует таблицу для отслеживания миграций
  Future<void> _initMigrationTable() async {
    await _connection.execute(
      Sql('''
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        executed_at TIMESTAMP DEFAULT NOW()
      )
    '''),
    );
  }

  /// Получает список выполненных миграций
  Future<Set<String>> _getExecutedMigrations() async {
    final result = await _connection.execute(Sql('SELECT version FROM schema_migrations ORDER BY executed_at'));
    return result.map((row) => row[0] as String).toSet();
  }

  /// Регистрирует выполненную миграцию
  Future<void> _recordMigration(String version, String name) async {
    await _connection.execute(
      Sql.named('''
        INSERT INTO schema_migrations (version, name)
        VALUES (@version, @name)
        ON CONFLICT (version) DO NOTHING
      '''),
      parameters: {'version': version, 'name': name},
    );
  }

  /// Выполняет SQL миграцию из файла
  Future<void> _executeMigrationFile(String filePath, String version, String name) async {
    logger.info('📝 Выполняем миграцию: $name ($version)');

    final file = File(filePath);
    if (!await file.exists()) {
      // Для миграций создания таблиц: если файла нет, проверяем существование таблицы
      if (_isCreateTableMigration(name)) {
        final tableNames = _extractTableNamesFromMigrationName(name);
        if (tableNames.isNotEmpty) {
          try {
            // Проверяем существование хотя бы одной из таблиц
            for (final tableName in tableNames) {
              final result = await _connection.execute(
                Sql.named("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = @table_name)"),
                parameters: {'table_name': tableName},
              );
              final tableExists = result.first[0] as bool;
              if (tableExists) {
                logger.info('⏭️  Таблица $tableName уже существует, пропускаем миграцию $name');
                await _recordMigration(version, name);
                return;
              }
            }
            // Если ни одна таблица не существует, но файла нет - пропускаем с предупреждением
            // Таблица будет создана вручную или через другую миграцию
            logger.info('⚠️  Файл миграции не найден и таблицы не существуют: $filePath');
            logger.info('⏭️  Пропускаем миграцию $name (таблицы будут созданы вручную или через другую миграцию)');
            await _recordMigration(version, name);
            return;
          } catch (e) {
            // Если ошибка при проверке - пропускаем миграцию
            logger.info('⚠️  Не удалось проверить существование таблиц: $e');
            logger.info('⏭️  Пропускаем миграцию $name (не удалось проверить таблицы)');
            await _recordMigration(version, name);
            return;
          }
        }
      }
      // Для всех остальных миграций (добавление полей, изменение структуры) файл обязателен
      throw Exception('Файл миграции не найден: $filePath');
    }

    final sql = await file.readAsString();

    // Разбиваем SQL на команды, учитывая блоки DO $$ ... END $$; и функции
    final commands = _splitSqlCommands(sql);

    // Выполняем команды в транзакции
    await _connection.execute(Sql('BEGIN'));
    try {
      for (final command in commands) {
        if (command.trim().isEmpty) continue;

        try {
          await _connection.execute(Sql(command));
        } catch (e) {
          logger.severe('❌ Ошибка при выполнении команды в миграции $name: $e');
          logger.severe('Команда: ${command.substring(0, command.length > 200 ? 200 : command.length)}...');
          await _connection.execute(Sql('ROLLBACK'));
          rethrow;
        }
      }
      await _connection.execute(Sql('COMMIT'));
    } catch (e) {
      await _connection.execute(Sql('ROLLBACK'));
      rethrow;
    }

    await _recordMigration(version, name);
    logger.info('✅ Миграция выполнена: $name');
  }

  /// Выполняет все невыполненные миграции
  Future<void> runMigrations() async {
    logger.info('🚀 Запуск миграций базы данных...');

    await _initMigrationTable();
    final executedMigrations = await _getExecutedMigrations();

    // Список всех миграций в порядке выполнения
    final migrations = [
      _MigrationInfo(version: '001', name: 'create_payments_table', file: 'migrations/create_payments_table.sql'),
      _MigrationInfo(version: '002', name: 'create_subscriptions_table', file: 'migrations/create_subscriptions_table.sql'),
      _MigrationInfo(version: '003', name: 'create_on_the_way_tables', file: 'migrations/create_on_the_way_tables.sql'),
      _MigrationInfo(version: '004', name: 'create_airports_table', file: 'migrations/create_airports_table.sql'),
      _MigrationInfo(version: '005', name: 'add_avatar_url_to_profiles', file: 'migrations/add_avatar_url_to_profiles.sql'),
      _MigrationInfo(version: '006', name: 'add_reply_to_reviews', file: 'migrations/add_reply_to_reviews.sql'),
      _MigrationInfo(version: '007', name: 'make_rating_nullable_for_replies', file: 'migrations/make_rating_nullable_for_replies.sql'),
      _MigrationInfo(version: '008', name: 'add_flight_photos_table', file: 'migrations/add_flight_photos_table.sql'),
      _MigrationInfo(version: '009', name: 'recreate_airports_table_aopa', file: 'migrations/recreate_airports_table_aopa.sql'),
      _MigrationInfo(version: '010', name: 'create_feedback_table', file: 'migrations/create_feedback_table.sql'),
      _MigrationInfo(version: '011', name: 'create_airport_ownership_requests_table', file: 'migrations/create_airport_ownership_requests_table.sql'),
      _MigrationInfo(version: '012', name: 'add_owned_airports_to_profiles', file: 'migrations/add_owned_airports_to_profiles.sql'),
      _MigrationInfo(version: '013', name: 'add_user_id_to_payments', file: 'migrations/add_user_id_to_payments.sql'),
      _MigrationInfo(version: '014', name: 'add_subscription_fields_to_profiles', file: 'migrations/add_subscription_fields_to_profiles.sql'),
      _MigrationInfo(version: '015', name: 'add_subscription_fields_to_payments', file: 'migrations/add_subscription_fields_to_payments.sql'),
      _MigrationInfo(version: '016', name: 'add_description_to_subscription_types', file: 'migrations/add_description_to_subscription_types.sql'),
      _MigrationInfo(version: '017', name: 'make_payment_id_nullable_in_subscriptions', file: 'migrations/make_payment_id_nullable_in_subscriptions.sql'),
      _MigrationInfo(version: '018', name: 'add_missing_fields_to_airport_ownership_requests', file: 'migrations/add_missing_fields_to_airport_ownership_requests.sql'),
      _MigrationInfo(version: '019', name: 'add_owner_id_to_airports', file: 'migrations/add_owner_id_to_airports.sql'),
      _MigrationInfo(version: '020', name: 'add_photos_to_airports', file: 'migrations/add_photos_to_airports.sql'),
      _MigrationInfo(version: '021', name: 'create_airport_feedback_table', file: 'migrations/create_airport_feedback_table.sql'),
      _MigrationInfo(version: '022', name: 'create_airport_visitor_photos_table', file: 'migrations/create_airport_visitor_photos_table.sql'),
      _MigrationInfo(version: '023', name: 'add_visitor_photos_to_airports', file: 'migrations/add_visitor_photos_to_airports.sql'),
      _MigrationInfo(version: '024', name: 'create_flight_waypoints_table', file: 'migrations/create_flight_waypoints_table.sql'),
      _MigrationInfo(version: '025', name: 'clear_all_flights_data', file: 'migrations/clear_all_flights_data.sql'),
      _MigrationInfo(version: '026', name: 'create_flight_questions_table', file: 'migrations/create_flight_questions_table.sql'),
      _MigrationInfo(version: '027', name: 'remove_subscription_fields_from_profiles', file: 'migrations/remove_subscription_fields_from_profiles.sql'),
      _MigrationInfo(version: '028', name: 'remove_unique_active_subscription_index', file: 'migrations/remove_unique_active_subscription_index.sql'),
      _MigrationInfo(version: '029', name: 'add_telegram_and_max_to_profiles', file: 'migrations/add_telegram_and_max_to_profiles.sql'),
      _MigrationInfo(version: '030', name: 'insert_airports_data', file: 'migrations/030_insert_airports_data.sql'),
      _MigrationInfo(version: '031', name: 'create_airport_reviews_table', file: 'migrations/create_airport_reviews_table.sql'),
      // Добавьте здесь новые миграции по порядку
    ];

    int executedCount = 0;
    for (final migration in migrations) {
      if (executedMigrations.contains(migration.version)) {
        logger.info('⏭️  Миграция уже выполнена: ${migration.name} (${migration.version})');
        continue;
      }

      try {
        await _executeMigrationFile(migration.file, migration.version, migration.name);
        executedCount++;
      } catch (e) {
        logger.severe('❌ Ошибка при выполнении миграции ${migration.name}: $e');
        rethrow;
      }
    }

    if (executedCount == 0) {
      logger.info('✅ Все миграции уже выполнены');
    } else {
      logger.info('✅ Выполнено миграций: $executedCount');
    }
  }

  /// Откатывает последнюю миграцию (опционально, требует файлы отката)
  Future<void> rollbackLastMigration() async {
    logger.info('⏪ Откат последней миграции...');

    final result = await _connection.execute(Sql('SELECT version, name FROM schema_migrations ORDER BY executed_at DESC LIMIT 1'));

    if (result.isEmpty) {
      logger.info('ℹ️  Нет выполненных миграций для отката');
      return;
    }

    final lastMigration = result.first;
    final version = lastMigration[0] as String;
    final name = lastMigration[1] as String;

    logger.info('Откатываем миграцию: $name ($version)');
    // Здесь можно добавить логику отката, если есть файлы rollback
    await _connection.execute(Sql.named('DELETE FROM schema_migrations WHERE version = @version'), parameters: {'version': version});
    logger.info('✅ Миграция откачена: $name');
  }

  /// Получает статус миграций
  Future<List<Map<String, dynamic>>> getMigrationStatus() async {
    await _initMigrationTable();
    final result = await _connection.execute(Sql('SELECT version, name, executed_at FROM schema_migrations ORDER BY executed_at'));

    return result.map((row) => {'version': row[0] as String, 'name': row[1] as String, 'executed_at': row[2] as DateTime}).toList();
  }

  /// Разбивает SQL на команды, учитывая блоки DO $$ ... END $$; и функции
  List<String> _splitSqlCommands(String sql) {
    final commands = <String>[];
    var currentCommand = StringBuffer();
    var inDoBlock = false;
    var dollarQuote = '';
    var inFunction = false;

    // Разбиваем по строкам для обработки
    final lines = sql.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      var trimmedLine = line.trim();

      // Удаляем комментарии в конце строки (но не внутри строковых литералов)
      final commentIndex = trimmedLine.indexOf('--');
      if (commentIndex > 0) {
        // Проверяем, что -- не внутри строки в кавычках
        final beforeComment = trimmedLine.substring(0, commentIndex);
        final singleQuotes = beforeComment.split("'").length - 1;
        final doubleQuotes = beforeComment.split('"').length - 1;
        // Если четное количество кавычек, значит комментарий не внутри строки
        if (singleQuotes % 2 == 0 && doubleQuotes % 2 == 0) {
          // Удаляем комментарий из строки
          final lineCommentIndex = line.indexOf('--');
          if (lineCommentIndex > 0) {
            line = line.substring(0, lineCommentIndex).trimRight();
          }
          trimmedLine = trimmedLine.substring(0, commentIndex).trim();
        }
      }

      // Пропускаем пустые строки и строки, которые полностью являются комментариями
      if (trimmedLine.isEmpty || trimmedLine.startsWith('--')) {
        continue;
      }

      // Проверяем начало блока DO $$
      if (!inDoBlock && !inFunction && trimmedLine.contains(RegExp(r'DO\s+\$\$', caseSensitive: false))) {
        inDoBlock = true;
        // Определяем dollar quote
        final dollarMatch = RegExp(r'\$(\w*)\$').firstMatch(trimmedLine);
        dollarQuote = dollarMatch != null ? '\$${dollarMatch.group(1)}\$' : '\$\$';
        currentCommand.writeln(line);
        continue;
      }

      // Проверяем начало функции
      if (!inDoBlock && !inFunction && trimmedLine.contains(RegExp(r'CREATE\s+(OR\s+REPLACE\s+)?FUNCTION', caseSensitive: false))) {
        inFunction = true;
        final dollarMatch = RegExp(r'\$(\w*)\$').firstMatch(trimmedLine);
        dollarQuote = dollarMatch != null ? '\$${dollarMatch.group(1)}\$' : '\$\$';
        currentCommand.writeln(line);
        continue;
      }

      if (inDoBlock || inFunction) {
        currentCommand.writeln(line);

        // Проверяем закрытие блока
        if (trimmedLine.contains(dollarQuote) && trimmedLine.endsWith(';')) {
          if (inDoBlock) {
            inDoBlock = false;
          } else if (inFunction) {
            inFunction = false;
          }
          final command = currentCommand.toString().trim();
          if (command.isNotEmpty) {
            commands.add(command);
          }
          currentCommand.clear();
          dollarQuote = '';
        }
      } else {
        // Обычная команда
        currentCommand.writeln(line);

        // Если строка заканчивается на ;, это конец команды
        if (trimmedLine.endsWith(';')) {
          final command = currentCommand.toString().trim();
          if (command.isNotEmpty) {
            commands.add(command);
          }
          currentCommand.clear();
        }
      }
    }

    // Добавляем оставшуюся команду, если есть
    final remaining = currentCommand.toString().trim();
    if (remaining.isNotEmpty) {
      commands.add(remaining);
    }

    return commands.where((cmd) => cmd.trim().isNotEmpty && !cmd.trim().startsWith('--')).toList();
  }

  /// Проверяет, является ли миграция созданием таблицы
  bool _isCreateTableMigration(String migrationName) {
    return migrationName.startsWith('create_') && (migrationName.endsWith('_table') || migrationName.endsWith('_tables'));
  }

  /// Извлекает имена таблиц из имени миграции
  /// Например: create_payments_table -> [payments]
  ///           create_on_the_way_tables -> [flights, bookings, reviews]
  List<String> _extractTableNamesFromMigrationName(String migrationName) {
    // Специальные случаи для множественных таблиц
    if (migrationName == 'create_on_the_way_tables') {
      return ['flights', 'bookings', 'reviews'];
    }

    // Для create_*_table извлекаем имя таблицы
    final match = RegExp(r'^create_(.+)_table$').firstMatch(migrationName);
    if (match != null) {
      return [match.group(1)!];
    }

    return [];
  }
}

class _MigrationInfo {
  final String version;
  final String name;
  final String file;

  _MigrationInfo({required this.version, required this.name, required this.file});
}
