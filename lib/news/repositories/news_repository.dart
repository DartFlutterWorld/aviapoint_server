import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/news/model/category_news_model.dart';
import 'package:aviapoint_server/news/model/news_model.dart';
import 'package:postgres/postgres.dart';

class NewsRepository {
  final Connection _connection;

  NewsRepository({
    required Connection connection,
  }) : _connection = connection;

  // /// Получить все новости
  Future<List<NewsModel>> getNews() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM news'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => NewsModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to news: $e');
      throw e;
    }
  }

// /// Получить новость по id
  Future<NewsModel> getNewsById(int id) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT * FROM news WHERE id = @id'), parameters: {
        'id': id,
      });

      logger.info(result.toList().map((f) => f.toColumnMap()));
      final models = NewsModel.fromJson(result.first.toColumnMap());
      return models;
    } catch (e) {
      logger.severe('Failed to getNewsById: $e');
      throw e;
    }
  }

// /// Получить новость по id
  Future<List<NewsModel>> getNewsByCategory(int categoryId) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT * FROM news WHERE category_id = @category_id'), parameters: {
        'category_id': categoryId,
      });

      // logger.info(result.toList().map((f) => f.toColumnMap()));
      final models = result.map((e) => NewsModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to getNewsByCategory: $e');
      throw e;
    }
  }

  // /// Получить все категории
  Future<List<CategoryNewsModel>> getCategoryNews() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM category_news ORDER BY id ASC'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => CategoryNewsModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to category_news: $e');
      throw e;
    }
  }
}
