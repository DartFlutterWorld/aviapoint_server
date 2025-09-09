import 'package:airpoint_server/logger/logger.dart';
import 'package:airpoint_server/stories/model/story_model.dart';
import 'package:postgres/postgres.dart';

class StoriesRepository {
  final Connection _connection;

  StoriesRepository({
    required Connection connection,
  }) : _connection = connection;

  // /// Получить все сторики
  Future<List<StoryModel>> getStories() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM stories'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => StoryModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to stories: $e');
      throw e;
    }
  }

  Future<StoryModel> fetchStoryId(int id) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT * FROM stories WHERE id = @id'), parameters: {
        'id': id,
      });

      logger.info(result.toList().map((f) => f.toColumnMap()));
      final models = StoryModel.fromJson(result.first.toColumnMap());
      return models;
    } catch (e) {
      logger.severe('Failed to fetchStoryId: $e');
      throw e;
    }
  }
}
