import 'package:airpoint_server/data/model/profile_model.dart';
import 'package:airpoint_server/logger/logger.dart';
import 'package:postgres/postgres.dart';

class ProfileRepository {
  final Connection _connection;

  ProfileRepository({
    required Connection connection,
  }) : _connection = connection;

  // /// Получить из хранилища все задачи в отсортированном порядке
  Future<Iterable<ProfileModel>> fetchAllOrders(String userId) async {
    final result = await _connection.execute(
      Sql.named('SELECT * FROM profile ORDER BY id ASC'),
    );

    final models = result.map((e) => ProfileModel.fromJson(e.toColumnMap())).toList();
    return models;
  }

  // /// Получить Profiles
  Future<List<ProfileModel>> fetchProiles() async {
    final result = await _connection.execute(
      Sql.named('SELECT * FROM profile'),
    );
    // logger.info(result.first.toColumnMap());
    logger.info(result.toList().map((f) => f.toColumnMap()));

    final models = result.map((e) => ProfileModel.fromJson(e.toColumnMap())).toList();
    return models;
  }

  /// Создать нового юзера
  Future<ProfileModel> create({
    required int id,
    required String name,
    required String phone,
    bool isCompleted = false,
  }) async {
    final result = await _connection.execute(
        Sql.named('INSERT INTO profile (id, name, phone) '
            'VALUES (@id, @name, @phone) '
            'RETURNING *'),
        parameters: {
          'id': id,
          'name': name,
          'phone': phone,
        });
    final serializedState = result.first.toColumnMap();
    return ProfileModel.fromJson(serializedState);
  }
}
