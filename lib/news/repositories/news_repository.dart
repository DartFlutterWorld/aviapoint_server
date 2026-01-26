import 'package:aviapoint_server/logger/logger.dart';
import 'package:aviapoint_server/news/model/category_news_model.dart';
import 'package:aviapoint_server/news/model/news_model.dart';
import 'package:postgres/postgres.dart';

class NewsRepository {
  final Connection _connection;

  NewsRepository({required Connection connection}) : _connection = connection;

  // /// Получить все новости (из всех категорий, без фильтрации по category_id)
  Future<List<NewsModel>> getNews({bool? published, int? authorId, bool? isAdmin}) async {
    try {
      // Запрос возвращает все новости из всех категорий (без фильтрации по category_id)
      final conditions = <String>[];
      final parameters = <String, dynamic>{};

      // Фильтрация по authorId
      if (authorId != null) {
        conditions.add('author_id = @author_id');
        parameters['author_id'] = authorId;
      }

      // Фильтрация по published
      if (published != null) {
        if (published == false && !(isAdmin ?? false)) {
          // Если запрашивают предложенные новости и пользователь не админ,
          // показываем только его новости (authorId уже добавлен выше)
          conditions.add('published = @published');
          parameters['published'] = false;
        } else if (published == true) {
          // Если запрашиваем опубликованные, включаем также NULL (старые новости без поля published)
          conditions.add('(published = @published OR published IS NULL)');
          parameters['published'] = true;
        } else {
          // published = false и админ - показываем все неопубликованные
          conditions.add('published = @published');
          parameters['published'] = false;
        }
      } else {
        // Если published = null и authorId указан, возвращаем все новости пользователя (и опубликованные, и неопубликованные)
        // Если published = null и authorId не указан, показываем только опубликованные
        if (authorId == null) {
          conditions.add('(published = @published OR published IS NULL)');
          parameters['published'] = true;
        }
        // Если authorId указан, но published = null, не добавляем фильтр по published (вернет все новости пользователя)
      }

      // Строим запрос
      String query = 'SELECT * FROM news';
      if (conditions.isNotEmpty) {
        query += ' WHERE ${conditions.join(' AND ')}';
      }
      // Сортировка по дате: свежие вверху
      // Если date хранится как TEXT с разными форматами, сортируем как строку
      // (ISO формат 2026-01-26... будет правильно сортироваться лексикографически)
      query += ' ORDER BY date DESC NULLS LAST';

      logger.info('getNews query: $query');
      logger.info('getNews parameters: $parameters');

      final result = await _connection.execute(Sql.named(query), parameters: parameters);

      logger.info('getNews result count: ${result.length}');
      if (result.isNotEmpty) {
        logger.info('First news: ${result.first.toColumnMap()}');
        logger.info('All news IDs: ${result.map((r) => r.toColumnMap()['id']).toList()}');
      }

      final models = result.map((e) {
        final row = e.toColumnMap();
        // Обеспечиваем, что published не null
        if (row['published'] == null) {
          row['published'] = true;
        }
        return NewsModel.fromJson(row);
      }).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to news: $e');
      throw e;
    }
  }

  // /// Получить новость по id
  Future<NewsModel> getNewsById(int id) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT * FROM news WHERE id = @id'), parameters: {'id': id});

      logger.info(result.toList().map((f) => f.toColumnMap()));
      final row = result.first.toColumnMap();
      // Обеспечиваем, что published не null
      if (row['published'] == null) {
        row['published'] = true;
      }
      final models = NewsModel.fromJson(row);
      return models;
    } catch (e) {
      logger.severe('Failed to getNewsById: $e');
      throw e;
    }
  }

  // /// Получить новость по id
  Future<List<NewsModel>> getNewsByCategory(int categoryId, {bool? published, int? authorId, bool? isAdmin}) async {
    try {
      String query = 'SELECT * FROM news WHERE category_id = @category_id';
      Map<String, dynamic> parameters = {'category_id': categoryId};

      // Фильтрация по published
      if (published != null) {
        if (published == false && !(isAdmin ?? false)) {
          // Если запрашивают предложенные новости и пользователь не админ,
          // показываем только его новости
          if (authorId != null) {
            query += ' AND published = @published AND author_id = @author_id';
            parameters['published'] = false;
            parameters['author_id'] = authorId;
          } else {
            // Если authorId не передан, возвращаем пустой список
            return [];
          }
        } else {
          query += ' AND published = @published';
          parameters['published'] = published;
        }
      } else {
        // По умолчанию показываем только опубликованные (или NULL, которые считаем опубликованными)
        query += ' AND (published = @published OR published IS NULL)';
        parameters['published'] = true;
      }

      // Сортировка по дате: свежие вверху (DESC - по убыванию)
      query += ' ORDER BY date DESC';

      final result = await _connection.execute(Sql.named(query), parameters: parameters);

      final models = result.map((e) {
        final row = e.toColumnMap();
        // Обеспечиваем, что published не null
        if (row['published'] == null) {
          row['published'] = true;
        }
        return NewsModel.fromJson(row);
      }).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to getNewsByCategory: $e');
      throw e;
    }
  }

  /// Создать новость
  Future<NewsModel> createNews({
    required int authorId,
    required String title,
    required String subTitle,
    required String source,
    required String body,
    String? content, // Quill Delta JSON
    required String pictureMini,
    required String pictureBig,
    required bool isBigNews,
    required int categoryId,
    required bool published,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Вставляем новость, id будет сгенерирован автоматически через DEFAULT (sequence)
      final result = await _connection.execute(
        Sql.named('''
          INSERT INTO news (
            title, sub_title, source, date, body, content,
            picture_mini, picture_big, is_big_news, category_id, 
            author_id, published
          ) VALUES (
            @title, @sub_title, @source, @date, @body, @content,
            @picture_mini, @picture_big, @is_big_news, @category_id,
            @author_id, @published
          ) RETURNING *
        '''),
        parameters: {
          'title': title,
          'sub_title': subTitle,
          'source': source,
          'date': now,
          'body': body,
          'content': content,
          'picture_mini': pictureMini,
          'picture_big': pictureBig,
          'is_big_news': isBigNews,
          'category_id': categoryId,
          'author_id': authorId,
          'published': published, // true для админов, false для обычных пользователей
        },
      );

      final row = result.first.toColumnMap();
      // Обеспечиваем, что published не null
      if (row['published'] == null) {
        row['published'] = false;
      }
      final model = NewsModel.fromJson(row);
      return model;
    } catch (e) {
      logger.severe('Failed to createNews: $e');
      throw e;
    }
  }

  /// Обновить пути изображений новости
  Future<void> updateNewsImages({required int newsId, required String pictureMini, required String pictureBig}) async {
    try {
      await _connection.execute(
        Sql.named('''
          UPDATE news
          SET picture_mini = @picture_mini, picture_big = @picture_big
          WHERE id = @id
        '''),
        parameters: {'id': newsId, 'picture_mini': pictureMini, 'picture_big': pictureBig},
      );
    } catch (e) {
      logger.severe('Failed to updateNewsImages: $e');
      throw e;
    }
  }

  /// Проверить, является ли пользователь администратором
  Future<bool> isAdmin(int userId) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT is_admin FROM profiles WHERE id = @id'), parameters: {'id': userId});

      if (result.isEmpty) {
        return false;
      }

      return result.first[0] as bool? ?? false;
    } catch (e) {
      logger.severe('Failed to check isAdmin: $e');
      return false;
    }
  }

  // /// Получить все категории
  Future<List<CategoryNewsModel>> getCategoryNews() async {
    try {
      final result = await _connection.execute(Sql.named('SELECT * FROM category_news ORDER BY id ASC'));
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => CategoryNewsModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to category_news: $e');
      throw e;
    }
  }

  /// Получить категорию по ID
  Future<CategoryNewsModel?> getCategoryById(int id) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT * FROM category_news WHERE id = @id'), parameters: {'id': id});

      if (result.isEmpty) {
        return null;
      }

      return CategoryNewsModel.fromJson(result.first.toColumnMap());
    } catch (e) {
      logger.severe('Failed to getCategoryById: $e');
      return null;
    }
  }

  /// Сохранить дополнительные изображения для новости
  Future<void> saveNewsImages({required int newsId, required List<String> imageUrls, required List<String> imagePaths}) async {
    try {
      for (int i = 0; i < imageUrls.length; i++) {
        await _connection.execute(
          Sql.named('''
            INSERT INTO news_images (news_id, image_url, image_path, order_index)
            VALUES (@news_id, @image_url, @image_path, @order_index)
          '''),
          parameters: {'news_id': newsId, 'image_url': imageUrls[i], 'image_path': imagePaths[i], 'order_index': i},
        );
      }
    } catch (e) {
      logger.severe('Failed to saveNewsImages for newsId $newsId: $e');
      rethrow;
    }
  }

  /// Получить дополнительные изображения для новости
  Future<List<String>> getNewsImages(int newsId) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT image_url FROM news_images WHERE news_id = @news_id ORDER BY order_index ASC'), parameters: {'news_id': newsId});

      return result.map((e) => e.toColumnMap()['image_url'] as String).toList();
    } catch (e) {
      logger.severe('Failed to getNewsImages for newsId $newsId: $e');
      rethrow;
    }
  }

  /// Обновить новость
  Future<NewsModel> updateNews({
    required int id,
    String? title,
    String? subTitle,
    String? source,
    String? body,
    String? content,
    String? pictureMini,
    String? pictureBig,
    bool? isBigNews,
    int? categoryId,
    bool? published,
  }) async {
    try {
      final updates = <String>[];
      final parameters = <String, dynamic>{'id': id};

      if (title != null) {
        updates.add('title = @title');
        parameters['title'] = title;
      }
      if (subTitle != null) {
        updates.add('sub_title = @sub_title');
        parameters['sub_title'] = subTitle;
      }
      if (source != null) {
        updates.add('source = @source');
        parameters['source'] = source;
      }
      if (body != null) {
        updates.add('body = @body');
        parameters['body'] = body;
      }
      if (content != null) {
        updates.add('content = @content');
        parameters['content'] = content;
      }
      if (pictureMini != null) {
        updates.add('picture_mini = @picture_mini');
        parameters['picture_mini'] = pictureMini;
      }
      if (pictureBig != null) {
        updates.add('picture_big = @picture_big');
        parameters['picture_big'] = pictureBig;
      }
      if (isBigNews != null) {
        updates.add('is_big_news = @is_big_news');
        parameters['is_big_news'] = isBigNews;
      }
      if (categoryId != null) {
        updates.add('category_id = @category_id');
        parameters['category_id'] = categoryId;
      }
      if (published != null) {
        updates.add('published = @published');
        parameters['published'] = published;
      }

      if (updates.isEmpty) {
        // Если нет изменений, просто возвращаем существующую новость
        return await getNewsById(id);
      }

      final query = 'UPDATE news SET ${updates.join(', ')} WHERE id = @id RETURNING *';
      final result = await _connection.execute(Sql.named(query), parameters: parameters);

      final row = result.first.toColumnMap();
      if (row['published'] == null) {
        row['published'] = false;
      }
      return NewsModel.fromJson(row);
    } catch (e) {
      logger.severe('Failed to updateNews: $e');
      rethrow;
    }
  }

  /// Удалить дополнительные изображения для новости
  Future<void> deleteNewsImages({required int newsId, required List<String> imageUrls}) async {
    try {
      for (final imageUrl in imageUrls) {
        await _connection.execute(
          Sql.named('DELETE FROM news_images WHERE news_id = @news_id AND image_url = @image_url'),
          parameters: {'news_id': newsId, 'image_url': imageUrl},
        );
      }
    } catch (e) {
      logger.severe('Failed to deleteNewsImages for newsId $newsId: $e');
      rethrow;
    }
  }

  /// Удалить новость
  Future<void> deleteNews(int id) async {
    try {
      // Удаляем дополнительные изображения
      await _connection.execute(
        Sql.named('DELETE FROM news_images WHERE news_id = @news_id'),
        parameters: {'news_id': id},
      );

      // Удаляем новость
      await _connection.execute(
        Sql.named('DELETE FROM news WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      logger.severe('Failed to deleteNews: $e');
      rethrow;
    }
  }
}
