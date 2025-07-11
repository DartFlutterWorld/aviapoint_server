import 'package:airpoint_server/profiles/data/model/profile_model.dart';
import 'package:airpoint_server/logger/logger.dart';
import 'package:postgres/postgres.dart';

class ProfileRepository {
  final Connection _connection;

  ProfileRepository({
    required Connection connection,
  }) : _connection = connection;

  // /// Получить профиль пользователя
  Future<ProfileModel> fetchProfileByPhone(String phone) async {
    final result = await _connection.execute(Sql.named('SELECT * FROM profiles WHERE phone = @phone'), parameters: {
      'phone': phone,
    });

    final serializedState = result.first.toColumnMap();
    return ProfileModel.fromJson(serializedState);
  }

  // /// Получить профиль пользователя
  Future<ProfileModel> fetchProfileById(int id) async {
    final result = await _connection.execute(Sql.named('SELECT * FROM profiles WHERE id = @id'), parameters: {
      'id': id,
    });

    final serializedState = result.first.toColumnMap();
    return ProfileModel.fromJson(serializedState);
  }

  // /// Получить Profiles
  Future<List<ProfileModel>> fetchProiles() async {
    final result = await _connection.execute(
      Sql.named('SELECT * FROM profiles'),
    );
    // logger.info(result.first.toColumnMap());
    logger.info(result.toList().map((f) => f.toColumnMap()));

    final models = result.map((e) => ProfileModel.fromJson(e.toColumnMap())).toList();
    return models;
  }

  /// Создать нового юзера
  Future<ProfileModel> createUser({
    required String phone,
    bool isCompleted = false,
  }) async {
    final result = await _connection.execute(
        Sql.named('INSERT INTO profiles (phone)'
            'VALUES ( @phone)'
            'RETURNING *'),
        parameters: {
          'phone': phone,
        });
    final serializedState = result.first.toColumnMap();
    return ProfileModel.fromJson(serializedState);
  }
}
