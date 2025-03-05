import 'package:airpoint_server/learning/video_for_students/model/video_for_students_model.dart';
import 'package:airpoint_server/logger/logger.dart';
import 'package:postgres/postgres.dart';

class VideoForStudentsRepository {
  final Connection _connection;

  VideoForStudentsRepository({
    required Connection connection,
  }) : _connection = connection;

  // /// Получить все видео для студентов
  Future<List<VideoForStudentsModel>> fetchVideoForStudents() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM video'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => VideoForStudentsModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to fetchVideoForStudents: $e');
      throw e;
    }
  }

  Future<VideoForStudentsModel> fetchVideoById(int id) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT * FROM video WHERE id = @id'), parameters: {
        'id': id,
      });

      logger.info(result.toList().map((f) => f.toColumnMap()));
      final models = VideoForStudentsModel.fromJson(result.first.toColumnMap());
      return models;
    } catch (e) {
      logger.severe('Failed to fetchVideoById: $e');
      throw e;
    }
  }
}
