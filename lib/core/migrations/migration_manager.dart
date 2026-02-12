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
          // Игнорируем ошибки создания индексов, если они уже существуют или таблица используется
          final errorStr = e.toString();
          if (errorStr.contains('already exists') || 
              errorStr.contains('being used by active queries') ||
              errorStr.contains('55006')) {
            logger.info('⚠️  Пропущена команда (индекс уже существует или таблица используется): ${command.substring(0, command.length > 100 ? 100 : command.length)}...');
            continue;
          }
          
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
    
    logger.info('📋 Выполненные миграции: ${executedMigrations.toList()}');

    // Список всех миграций в порядке выполнения
    final migrations = [
      _MigrationInfo(version: '073', name: 'add_iap_support_to_payments', file: 'migrations/073_add_iap_support_to_payments.sql'),
      _MigrationInfo(version: '074', name: 'create_parts_categories', file: 'migrations/074_create_parts_categories.sql'),
      _MigrationInfo(version: '075', name: 'add_subscription_type_id_to_payments', file: 'migrations/075_add_subscription_type_id_to_payments.sql'),
      _MigrationInfo(version: '076', name: 'fix_subscription_type_column', file: 'migrations/076_fix_subscription_type_column.sql'),
      _MigrationInfo(version: '077', name: 'create_parts_market', file: 'migrations/077_create_parts_market.sql'),
      _MigrationInfo(version: '078', name: 'add_is_published_to_aircraft_market', file: 'migrations/078_add_is_published_to_aircraft_market.sql'),
      _MigrationInfo(version: '079', name: 'add_is_published_to_parts_market', file: 'migrations/079_add_is_published_to_parts_market.sql'),
      _MigrationInfo(version: '080', name: 'create_parts_market_price_history', file: 'migrations/080_create_parts_market_price_history.sql'),
      _MigrationInfo(version: '081', name: 'add_currency_to_aircraft_market', file: 'migrations/081_add_currency_to_aircraft_market.sql'),
      _MigrationInfo(version: '082', name: 'create_jobs_vacancies_and_resumes', file: 'migrations/082_create_jobs_vacancies_and_resumes.sql'),
      _MigrationInfo(version: '084', name: 'create_checko_entities', file: 'migrations/084_create_checko_entities.sql'),
      _MigrationInfo(version: '085', name: 'drop_user_id_from_checko_tables', file: 'migrations/085_drop_user_id_from_checko_tables.sql'),
      _MigrationInfo(version: '086', name: 'change_checko_company_unique_to_inn_only', file: 'migrations/086_change_checko_company_unique_to_inn_only.sql'),
      _MigrationInfo(version: '087', name: 'add_employer_inn_to_jobs_vacancies', file: 'migrations/087_add_employer_inn_to_jobs_vacancies.sql'),
      _MigrationInfo(version: '088', name: 'drop_jobs_vacancy_location_columns', file: 'migrations/088_drop_jobs_vacancy_location_columns.sql'),
      _MigrationInfo(version: '089', name: 'add_job_vacancy_contact_fields', file: 'migrations/089_add_job_vacancy_contact_fields.sql'),
      _MigrationInfo(version: '090', name: 'add_jobs_vacancy_is_private', file: 'migrations/090_add_jobs_vacancy_is_private.sql'),
      _MigrationInfo(version: '091', name: 'create_jobs_contact_profiles_and_link', file: 'migrations/091_create_jobs_contact_profiles_and_link.sql'),
      _MigrationInfo(version: '092', name: 'move_jobs_address_to_contact_profiles', file: 'migrations/092_move_jobs_address_to_contact_profiles.sql'),
      _MigrationInfo(version: '093', name: 'drop_jobs_vacancies_is_remote', file: 'migrations/093_drop_jobs_vacancies_is_remote.sql'),
      _MigrationInfo(version: '094', name: 'add_contact_profile_images', file: 'migrations/094_add_contact_profile_images.sql'),
      _MigrationInfo(version: '095', name: 'resume_extended_fields_and_contacts', file: 'migrations/095_resume_extended_fields_and_contacts.sql'),
      _MigrationInfo(version: '096', name: 'add_employer_comment_to_vacancy_responses', file: 'migrations/096_add_employer_comment_to_vacancy_responses.sql'),
      _MigrationInfo(version: '097', name: 'drop_iap_from_payments', file: 'migrations/097_drop_iap_from_payments.sql'),
      _MigrationInfo(version: '098', name: 'add_address_to_market', file: 'migrations/098_add_address_to_market.sql'),
      _MigrationInfo(version: '099', name: 'add_additional_image_urls_to_jobs_vacancies', file: 'migrations/099_add_additional_image_urls_to_jobs_vacancies.sql'),
      // Добавьте здесь новые миграции по порядку
    ];

    int executedCount = 0;
    for (final migration in migrations) {
      logger.info('🔍 Проверка миграции: ${migration.name} (${migration.version}) - выполнена: ${executedMigrations.contains(migration.version)}');
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
}

class _MigrationInfo {
  final String version;
  final String name;
  final String file;

  _MigrationInfo({required this.version, required this.name, required this.file});
}
