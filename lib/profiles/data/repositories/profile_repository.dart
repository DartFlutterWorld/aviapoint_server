import 'package:aviapoint_server/profiles/data/model/profile_model.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:postgres/postgres.dart';

class ProfileRepository {
  final Connection _connection;

  ProfileRepository({required Connection connection}) : _connection = connection;

  // /// Получить профиль пользователя
  Future<ProfileModel> fetchProfileByPhone(String phone) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          p.*,
          COALESCE(AVG(r.rating)::numeric, 0) as average_rating,
          COUNT(r.id) FILTER (WHERE r.rating IS NOT NULL) as reviews_count
        FROM profiles p
        LEFT JOIN reviews r ON r.reviewed_id = p.id AND r.reply_to_review_id IS NULL AND r.rating IS NOT NULL
        WHERE p.phone = @phone
        GROUP BY p.id
      '''),
      parameters: {'phone': phone},
    );

    final serializedState = result.first.toColumnMap();
    return ProfileModel.fromJson(serializedState);
  }

  // /// Получить профиль пользователя
  Future<ProfileModel> fetchProfileById(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          p.*,
          COALESCE(AVG(r.rating)::numeric, 0) as average_rating,
          COUNT(r.id) FILTER (WHERE r.rating IS NOT NULL) as reviews_count
        FROM profiles p
        LEFT JOIN reviews r ON r.reviewed_id = p.id AND r.reply_to_review_id IS NULL AND r.rating IS NOT NULL
        WHERE p.id = @id
        GROUP BY p.id
      '''),
      parameters: {'id': id},
    );

    final serializedState = result.first.toColumnMap();
    return ProfileModel.fromJson(serializedState);
  }

  // /// Получить Profiles
  Future<List<ProfileModel>> fetchProiles() async {
    final result = await _connection.execute(Sql.named('SELECT * FROM profiles'));
    // logger.info(result.first.toColumnMap());
    logger.info(result.toList().map((f) => f.toColumnMap()));

    final models = result.map((e) => ProfileModel.fromJson(e.toColumnMap())).toList();
    return models;
  }

  /// Создать нового юзера
  Future<ProfileModel> createUser({required String phone, bool isCompleted = false}) async {
    final result = await _connection.execute(
      Sql.named(
        'INSERT INTO profiles (phone)'
        'VALUES ( @phone)'
        'RETURNING *',
      ),
      parameters: {'phone': phone},
    );
    final serializedState = result.first.toColumnMap();
    return ProfileModel.fromJson(serializedState);
  }

  /// Обновить профиль пользователя
  Future<ProfileModel> updateProfile({required int id, String? email, String? firstName, String? lastName, String? telegram, String? max}) async {
    // Строим динамический SQL запрос для обновления только переданных полей
    final updates = <String>[];
    final parameters = <String, dynamic>{'id': id};

    // Обрабатываем все поля, конвертируя пустые строки в NULL для очистки
    if (email != null) {
      updates.add('email = @email');
      parameters['email'] = email.isEmpty ? null : email;
    }
    if (firstName != null) {
      updates.add('first_name = @firstName');
      parameters['firstName'] = firstName.isEmpty ? null : firstName;
    }
    if (lastName != null) {
      updates.add('last_name = @lastName');
      parameters['lastName'] = lastName.isEmpty ? null : lastName;
    }
    if (telegram != null) {
      updates.add('telegram = @telegram');
      parameters['telegram'] = telegram.isEmpty ? null : telegram;
    }
    if (max != null) {
      updates.add('max = @max');
      parameters['max'] = max.isEmpty ? null : max;
    }

    if (updates.isEmpty) {
      // Если нет полей для обновления, просто возвращаем текущий профиль
      return await fetchProfileById(id);
    }

    final updateClause = updates.join(', ');
    final sql = 'UPDATE profiles SET $updateClause WHERE id = @id RETURNING *';

    final result = await _connection.execute(Sql.named(sql), parameters: parameters);

    final serializedState = result.first.toColumnMap();
    return ProfileModel.fromJson(serializedState);
  }

  /// Обновить аватар пользователя
  Future<ProfileModel> updateAvatarUrl({required int id, required String avatarUrl}) async {
    final result = await _connection.execute(Sql.named('UPDATE profiles SET avatar_url = @avatarUrl WHERE id = @id RETURNING *'), parameters: {'id': id, 'avatarUrl': avatarUrl});

    final serializedState = result.first.toColumnMap();
    return ProfileModel.fromJson(serializedState);
  }

  /// Обновить FCM токен пользователя
  /// Обновить или добавить FCM токен для пользователя (новая система с поддержкой платформ)
  /// Если токен уже существует для этой платформы, обновляет его
  /// Если нет - создает новую запись
  Future<void> updateFcmToken({required int id, required String? fcmToken, String? platform}) async {
    if (fcmToken == null || fcmToken.isEmpty) {
      // Если токен пустой, удаляем все токены пользователя
      await _connection.execute(
        Sql.named('DELETE FROM fcm_tokens WHERE user_id = @id'),
        parameters: {'id': id},
      );
      return;
    }

    final platformValue = platform ?? 'mobile';

    // Обновляем или вставляем токен в таблицу fcm_tokens
    // Используем ON CONFLICT по fcm_token (уникальный индекс)
    await _connection.execute(
      Sql.named('''
        INSERT INTO fcm_tokens (user_id, fcm_token, platform, created_at, updated_at)
        VALUES (@id, @fcmToken, @platform, NOW(), NOW())
        ON CONFLICT (fcm_token) 
        DO UPDATE SET 
          user_id = EXCLUDED.user_id,
          platform = EXCLUDED.platform,
          updated_at = NOW()
      '''),
      parameters: {'id': id, 'fcmToken': fcmToken, 'platform': platformValue},
    );
  }

  /// Сохранить анонимный FCM токен (без user_id)
  /// Используется для массовых рассылок неавторизованным пользователям
  Future<void> saveAnonymousFcmToken({required String? fcmToken, String? platform}) async {
    if (fcmToken == null || fcmToken.isEmpty) {
      logger.info('⚠️ Попытка сохранить пустой анонимный FCM токен');
      return;
    }

    final platformValue = platform ?? 'mobile';
    logger.info('💾 Сохранение анонимного FCM токена в БД: token=${fcmToken.substring(0, 20)}..., platform=$platformValue');

    try {
      // Проверяем, существует ли уже такой токен
      final existingToken = await _connection.execute(
        Sql.named('''
          SELECT id, user_id, platform, created_at, updated_at
          FROM fcm_tokens 
          WHERE fcm_token = @fcmToken
          LIMIT 1
        '''),
        parameters: {'fcmToken': fcmToken},
      );

      if (existingToken.isNotEmpty) {
        final existingUserId = existingToken.first[1]; // user_id
        final existingPlatform = existingToken.first[2] as String?;
        logger.info('🔍 Токен уже существует в БД: id=${existingToken.first[0]}, user_id=$existingUserId, platform=$existingPlatform');
      } else {
        logger.info('🆕 Токен не найден в БД, будет создана новая запись');
      }

      // Сохраняем анонимный токен (user_id = NULL)
      // Используем ON CONFLICT по уникальному индексу idx_fcm_tokens_token_unique
      final result = await _connection.execute(
        Sql.named('''
          INSERT INTO fcm_tokens (user_id, fcm_token, platform, created_at, updated_at)
          VALUES (NULL, @fcmToken, @platform, NOW(), NOW())
          ON CONFLICT (fcm_token) 
          DO UPDATE SET 
            user_id = COALESCE(EXCLUDED.user_id, fcm_tokens.user_id),
            platform = EXCLUDED.platform,
            updated_at = NOW()
        '''),
        parameters: {'fcmToken': fcmToken, 'platform': platformValue},
      );

      logger.info('✅ Анонимный FCM токен сохранен/обновлен в БД. Затронуто строк: ${result.affectedRows}');

      // Проверяем результат после операции
      final verifyToken = await _connection.execute(
        Sql.named('''
          SELECT id, user_id, platform, created_at, updated_at
          FROM fcm_tokens 
          WHERE fcm_token = @fcmToken
          LIMIT 1
        '''),
        parameters: {'fcmToken': fcmToken},
      );

      if (verifyToken.isNotEmpty) {
        final verifyUserId = verifyToken.first[1]; // user_id
        final verifyPlatform = verifyToken.first[2] as String?;
        logger.info('✅ Проверка после сохранения: id=${verifyToken.first[0]}, user_id=$verifyUserId, platform=$verifyPlatform');
      } else {
        logger.info('⚠️ Токен не найден в БД после операции сохранения!');
      }
    } catch (e, stackTrace) {
      logger.severe('❌ Ошибка при сохранении анонимного FCM токена в БД: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Получить FCM токен пользователя
  /// Возвращает первый доступный токен из таблицы fcm_tokens
  Future<String?> getFcmToken(int userId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT fcm_token 
        FROM fcm_tokens 
        WHERE user_id = @id 
        ORDER BY updated_at DESC 
        LIMIT 1
      '''),
      parameters: {'id': userId},
    );

    if (result.isNotEmpty) {
      return result.first[0] as String?;
    }
    return null;
  }

  /// Получить все FCM токены пользователя по платформе
  Future<List<String>> getFcmTokensByPlatform(int userId, String? platform) async {
    String query = '''
      SELECT fcm_token 
      FROM fcm_tokens 
      WHERE user_id = @id
    ''';

    final parameters = <String, dynamic>{'id': userId};

    if (platform != null) {
      query += ' AND platform = @platform';
      parameters['platform'] = platform;
    }

    query += ' ORDER BY updated_at DESC';

    final result = await _connection.execute(
      Sql.named(query),
      parameters: parameters,
    );

    return result.map((row) => row[0] as String).toList();
  }

  /// Получить все FCM токены пользователя (для всех платформ)
  Future<List<Map<String, dynamic>>> getAllFcmTokens(int userId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT fcm_token, platform, updated_at
        FROM fcm_tokens 
        WHERE user_id = @id
        ORDER BY updated_at DESC
      '''),
      parameters: {'id': userId},
    );

    return result.map((row) {
      final map = row.toColumnMap();
      return {
        'fcm_token': map['fcm_token'] as String,
        'platform': map['platform'] as String,
        'updated_at': map['updated_at'] as DateTime,
      };
    }).toList();
  }

  /// Проверить, является ли пользователь администратором
  Future<bool> isAdmin(int userId) async {
    final result = await _connection.execute(
      Sql.named('SELECT is_admin FROM profiles WHERE id = @id'),
      parameters: {'id': userId},
    );

    if (result.isEmpty) {
      return false;
    }

    final row = result.first.toColumnMap();
    return row['is_admin'] as bool? ?? false;
  }

  /// Получить все FCM токены администраторов
  Future<List<String>> getAdminFcmTokens() async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT DISTINCT ft.fcm_token
        FROM fcm_tokens ft
        INNER JOIN profiles p ON ft.user_id = p.id
        WHERE p.is_admin = true
          AND ft.fcm_token IS NOT NULL
          AND ft.fcm_token != ''
        ORDER BY ft.updated_at DESC
      '''),
    );

    return result.map((row) => row[0] as String).toList();
  }

  /// Удалить аккаунт пользователя
  /// Удаляет профиль и все связанные данные
  /// CASCADE автоматически удалит связанные данные из следующих таблиц:
  /// - bookings (passenger_id)
  /// - flights (pilot_id)
  /// - reviews (reviewer_id, reviewed_id)
  /// - airport_ownership_requests (user_id)
  /// - airport_visitor_photos (user_id)
  /// - flight_photos (uploaded_by)
  /// - subscriptions (user_id)
  Future<void> deleteAccount({required int id}) async {
    // Начинаем транзакцию
    await _connection.execute(Sql('BEGIN'));

    try {
      // Удаляем FCM токены из таблицы (CASCADE автоматически удалит при удалении профиля,
      // но также удаляем явно для явности и логирования)
      await _connection.execute(
        Sql.named('DELETE FROM fcm_tokens WHERE user_id = @id'),
        parameters: {'id': id},
      );

      // Удаляем профиль (CASCADE автоматически удалит связанные данные)
      await _connection.execute(
        Sql.named('DELETE FROM profiles WHERE id = @id'),
        parameters: {'id': id},
      );

      // Коммитим транзакцию
      await _connection.execute(Sql('COMMIT'));
      logger.info('Account deleted successfully: user_id=$id');
    } catch (e) {
      // Откатываем транзакцию в случае ошибки
      await _connection.execute(Sql('ROLLBACK'));
      logger.severe('Error deleting account: user_id=$id, error=$e');
      rethrow;
    }
  }
}
