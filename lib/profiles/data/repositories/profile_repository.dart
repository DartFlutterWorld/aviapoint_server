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

    if (email != null) {
      updates.add('email = @email');
      parameters['email'] = email;
    }
    if (firstName != null) {
      updates.add('first_name = @firstName');
      parameters['firstName'] = firstName;
    }
    if (lastName != null) {
      updates.add('last_name = @lastName');
      parameters['lastName'] = lastName;
    }
    if (telegram != null) {
      updates.add('telegram = @telegram');
      parameters['telegram'] = telegram;
    }
    if (max != null) {
      updates.add('max = @max');
      parameters['max'] = max;
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
  Future<void> updateFcmToken({required int id, required String? fcmToken}) async {
    await _connection.execute(
      Sql.named('UPDATE profiles SET fcm_token = @fcmToken WHERE id = @id'),
      parameters: {'id': id, 'fcmToken': fcmToken},
    );
  }

  /// Получить FCM токен пользователя
  Future<String?> getFcmToken(int userId) async {
    final result = await _connection.execute(
      Sql.named('SELECT fcm_token FROM profiles WHERE id = @id'),
      parameters: {'id': userId},
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first.toColumnMap();
    return row['fcm_token'] as String?;
  }
}
