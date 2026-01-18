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
        Sql.named('DELETE FROM user_fcm_tokens WHERE user_id = @id'),
        parameters: {'id': id},
      );
      // Также обновляем старое поле для обратной совместимости
      await _connection.execute(
        Sql.named('UPDATE profiles SET fcm_token = NULL WHERE id = @id'),
        parameters: {'id': id},
      );
      return;
    }

    final platformValue = platform ?? 'mobile';

    // Обновляем или вставляем токен в новую таблицу
    await _connection.execute(
      Sql.named('''
        INSERT INTO user_fcm_tokens (user_id, fcm_token, platform, created_at, updated_at)
        VALUES (@id, @fcmToken, @platform, NOW(), NOW())
        ON CONFLICT (user_id, fcm_token) 
        DO UPDATE SET 
          platform = EXCLUDED.platform,
          updated_at = NOW()
      '''),
      parameters: {'id': id, 'fcmToken': fcmToken, 'platform': platformValue},
    );

    // Для обратной совместимости также обновляем поле в profiles (берем последний токен)
    await _connection.execute(
      Sql.named('''
        UPDATE profiles 
        SET fcm_token = (
          SELECT fcm_token 
          FROM user_fcm_tokens 
          WHERE user_id = @id 
          ORDER BY updated_at DESC 
          LIMIT 1
        )
        WHERE id = @id
      '''),
      parameters: {'id': id},
    );
  }

  /// Получить FCM токен пользователя (для обратной совместимости)
  /// Возвращает первый доступный токен
  Future<String?> getFcmToken(int userId) async {
    // Сначала пробуем получить из новой таблицы
    final result = await _connection.execute(
      Sql.named('''
        SELECT fcm_token 
        FROM user_fcm_tokens 
        WHERE user_id = @id 
        ORDER BY updated_at DESC 
        LIMIT 1
      '''),
      parameters: {'id': userId},
    );

    if (result.isNotEmpty) {
      return result.first[0] as String?;
    }

    // Если не найден, пробуем получить из старого поля (для обратной совместимости)
    final oldResult = await _connection.execute(
      Sql.named('SELECT fcm_token FROM profiles WHERE id = @id'),
      parameters: {'id': userId},
    );

    if (oldResult.isEmpty) {
      return null;
    }

    final row = oldResult.first.toColumnMap();
    return row['fcm_token'] as String?;
  }

  /// Получить все FCM токены пользователя по платформе
  Future<List<String>> getFcmTokensByPlatform(int userId, String? platform) async {
    String query = '''
      SELECT fcm_token 
      FROM user_fcm_tokens 
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
        FROM user_fcm_tokens 
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
        SELECT DISTINCT uft.fcm_token
        FROM user_fcm_tokens uft
        INNER JOIN profiles p ON uft.user_id = p.id
        WHERE p.is_admin = true
          AND uft.fcm_token IS NOT NULL
          AND uft.fcm_token != ''
        ORDER BY uft.updated_at DESC
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
      // Удаляем FCM токены из новой таблицы (CASCADE автоматически удалит при удалении профиля)
      await _connection.execute(
        Sql.named('DELETE FROM user_fcm_tokens WHERE user_id = @id'),
        parameters: {'id': id},
      );
      
      // Также очищаем старое поле в профиле (для обратной совместимости)
      await _connection.execute(
        Sql.named('UPDATE profiles SET fcm_token = NULL WHERE id = @id'),
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
