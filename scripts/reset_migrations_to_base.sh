#!/bin/bash

# Скрипт для очистки всех миграций и оставления только базовой миграции
# Использование: выполните в проекте aviapoint_server локально

set -e

PROJECT_DIR="/Users/admin/Projects/aviapoint_server"
MIGRATIONS_DIR="$PROJECT_DIR/migrations"
BACKUP_DIR="$PROJECT_DIR/migrations_backup_$(date +%Y%m%d_%H%M%S)"
BASE_MIGRATION="072_sync_all_tables_and_fields.sql"

echo "🧹 Очистка миграций - оставить только базовую миграцию..."
echo ""
echo "⚠️  ВНИМАНИЕ: Это удалит все миграции кроме базовой!"
echo "   Создастся резервная копия в: $BACKUP_DIR"
echo ""
read -p "Продолжить? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Отменено"
    exit 1
fi

cd "$PROJECT_DIR"

# 1. Создать резервную копию всех миграций
echo ""
echo "📦 Создание резервной копии..."
mkdir -p "$BACKUP_DIR"
cp -r "$MIGRATIONS_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
echo "✅ Резервная копия создана: $BACKUP_DIR"

# 2. Проверить, что базовая миграция существует
if [ ! -f "$MIGRATIONS_DIR/$BASE_MIGRATION" ]; then
    echo "❌ Базовая миграция не найдена: $BASE_MIGRATION"
    exit 1
fi

# 3. Удалить все миграции кроме базовой
echo ""
echo "🗑️  Удаление миграций (кроме базовой)..."
cd "$MIGRATIONS_DIR"

# Сохранить базовую миграцию
cp "$BASE_MIGRATION" "../${BASE_MIGRATION}.tmp"

# Удалить все SQL файлы
rm -f *.sql

# Восстановить базовую миграцию
mv "../${BASE_MIGRATION}.tmp" "$BASE_MIGRATION"

# Удалить другие файлы (кроме .md и .txt)
find . -type f ! -name "*.sql" ! -name "*.md" ! -name "*.txt" -delete 2>/dev/null || true

echo "✅ Миграции удалены, базовая миграция сохранена"

# 4. Обновить migration_manager.dart
echo ""
echo "📝 Обновление migration_manager.dart..."
MIGRATION_MANAGER="$PROJECT_DIR/lib/core/migrations/migration_manager.dart"

if [ ! -f "$MIGRATION_MANAGER" ]; then
    echo "❌ Файл migration_manager.dart не найден: $MIGRATION_MANAGER"
    exit 1
fi

# Создать новый список миграций с только базовой
cat > "$MIGRATION_MANAGER.new" << 'EOF'
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
    // Оставлена только базовая миграция синхронизации
    final migrations = [
      _MigrationInfo(version: '072', name: 'sync_all_tables_and_fields', file: 'migrations/072_sync_all_tables_and_fields.sql'),
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
EOF

# Создать резервную копию старого файла
cp "$MIGRATION_MANAGER" "${MIGRATION_MANAGER}.backup"

# Заменить файл
mv "$MIGRATION_MANAGER.new" "$MIGRATION_MANAGER"

echo "✅ migration_manager.dart обновлен"

# 5. Инструкции по очистке schema_migrations
echo ""
echo "📋 Следующие шаги:"
echo ""
echo "1. На сервере очистить таблицу schema_migrations:"
echo "   ssh ваш_сервер"
echo "   docker exec aviapoint-postgres psql -U postgres -d aviapoint -c \"TRUNCATE TABLE schema_migrations;\""
echo ""
echo "2. Или удалить все записи кроме базовой миграции:"
echo "   docker exec aviapoint-postgres psql -U postgres -d aviapoint -c \"DELETE FROM schema_migrations WHERE version != '072';\""
echo ""
echo "3. Перезапустить бэкенд, чтобы применить базовую миграцию:"
echo "   docker-compose -f docker-compose.prod.yaml restart aviapoint-server"
echo ""
echo "✅ Готово!"
echo ""
echo "📦 Резервная копия: $BACKUP_DIR"
echo "💾 Backup migration_manager.dart: ${MIGRATION_MANAGER}.backup"
