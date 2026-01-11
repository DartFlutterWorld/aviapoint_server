import 'package:aviapoint_server/blog/data/model/blog_article_model.dart';
import 'package:aviapoint_server/blog/data/model/blog_category_model.dart';
import 'package:aviapoint_server/blog/data/model/blog_tag_model.dart';
import 'package:aviapoint_server/blog/data/model/blog_comment_model.dart';
import 'package:postgres/postgres.dart';

class BlogRepository {
  final Connection _connection;

  BlogRepository({required Connection connection}) : _connection = connection;

  /// Получить список категорий блога
  Future<List<BlogCategoryModel>> getCategories({bool activeOnly = true}) async {
    final query = activeOnly
        ? 'SELECT * FROM blog_categories WHERE is_active = true ORDER BY order_index ASC, name ASC'
        : 'SELECT * FROM blog_categories ORDER BY order_index ASC, name ASC';

    final result = await _connection.execute(Sql(query));

    return result.map((row) => BlogCategoryModel.fromJson(row.toColumnMap())).toList();
  }

  /// Получить статьи блога с фильтрами
  Future<List<BlogArticleModel>> getArticles({
    int? categoryId,
    int? aircraftModelId,
    int? authorId,
    String? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = '''
      SELECT 
        a.*,
        p.first_name as author_first_name,
        p.last_name as author_last_name,
        p.avatar_url as author_avatar_url,
        c.name as category_name,
        c.color as category_color,
        am.id as aircraft_model_id,
        am.model_code as aircraft_model_code,
        am.manufacturer_id as aircraft_manufacturer_id,
        m.id as aircraft_manufacturer_m_id,
        m.name as aircraft_manufacturer_m_name,
        (
          SELECT json_agg(t.*)
          FROM blog_tags t
          JOIN blog_article_tags at ON t.id = at.tag_id
          WHERE at.article_id = a.id
        ) as tags
      FROM blog_articles a
      LEFT JOIN profiles p ON a.author_id = p.id
      LEFT JOIN blog_categories c ON a.category_id = c.id
      LEFT JOIN aircraft_models am ON a.aircraft_model_id = am.id
      LEFT JOIN aircraft_manufacturers m ON am.manufacturer_id = m.id
      WHERE 1=1
    ''';

    final parameters = <String, dynamic>{};

    if (status != null) {
      query += ' AND a.status = @status';
      parameters['status'] = status;
    }

    if (authorId != null) {
      query += ' AND a.author_id = @author_id';
      parameters['author_id'] = authorId;
    }

    if (categoryId != null) {
      query += ' AND a.category_id = @category_id';
      parameters['category_id'] = categoryId;
    }

    if (aircraftModelId != null) {
      query += ' AND a.aircraft_model_id = @aircraft_model_id';
      parameters['aircraft_model_id'] = aircraftModelId;
    }


    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Поиск по всем полям: title, content, excerpt, категория, самолёт, теги, автор
      query += '''
        AND (
          a.title ILIKE @search 
          OR a.content ILIKE @search 
          OR a.excerpt ILIKE @search
          OR c.name ILIKE @search
          OR am.model_code ILIKE @search
          OR am.model_code ILIKE @search
          OR p.first_name ILIKE @search
          OR p.last_name ILIKE @search
          OR EXISTS (
            SELECT 1 
            FROM blog_article_tags at2
            JOIN blog_tags t2 ON at2.tag_id = t2.id
            WHERE at2.article_id = a.id 
            AND t2.name ILIKE @search
          )
        )
      ''';
      parameters['search'] = '%$searchQuery%';
    }

    query += ' ORDER BY a.published_at DESC, a.created_at DESC';
    query += ' LIMIT @limit OFFSET @offset';
    parameters['limit'] = limit;
    parameters['offset'] = offset;

    final result = await _connection.execute(Sql.named(query), parameters: parameters);

    return result.map((row) {
      final map = row.toColumnMap();
      
      // Формируем вложенные объекты для BlogArticleModel.fromJson
      final jsonMap = Map<String, dynamic>.from(map);
      
      if (map['author_profile_id'] != null) {
        jsonMap['author'] = {
          'id': map['author_profile_id'],
          'phone': map['author_phone'] ?? '',
          'email': map['author_email'],
          'first_name': map['author_first_name'],
          'last_name': map['author_last_name'],
          'avatar_url': map['author_avatar_url'],
        };
      }
      
      if (map['category_id'] != null) {
        jsonMap['category'] = {
          'id': map['category_id'],
          'name': map['category_name'],
          'color': map['category_color'],
        };
      }
      
      // Создаем объект aircraft_model только если все обязательные поля присутствуют
      if (map['aircraft_model_id'] != null && 
          map['aircraft_manufacturer_id'] != null &&
          map['aircraft_model_code'] != null) {
        jsonMap['aircraft_model'] = {
          'id': map['aircraft_model_id'],
          'manufacturer_id': map['aircraft_manufacturer_id'],
          'model_code': map['aircraft_model_code'],
          // Поля производителя с префиксом m_ для fromJson
          'm_id': map['aircraft_manufacturer_m_id'],
          'm_name': map['aircraft_manufacturer_m_name'],
        };
      }

      return BlogArticleModel.fromJson(jsonMap);
    }).toList();
  }

  /// Получить статью по ID
  Future<BlogArticleModel?> getArticle({required int id}) async {

    var query = '''
      SELECT 
        a.*,
        p.id as author_profile_id,
        p.first_name as author_first_name,
        p.last_name as author_last_name,
        p.phone as author_phone,
        p.email as author_email,
        p.avatar_url as author_avatar_url,
        c.name as category_name,
        c.color as category_color,
        am.id as aircraft_model_id,
        am.model_code as aircraft_model_code,
        am.manufacturer_id as aircraft_manufacturer_id,
        m.id as aircraft_manufacturer_m_id,
        m.name as aircraft_manufacturer_m_name,
        (
          SELECT json_agg(t.*)
          FROM blog_tags t
          JOIN blog_article_tags at ON t.id = at.tag_id
          WHERE at.article_id = a.id
        ) as tags
      FROM blog_articles a
      LEFT JOIN profiles p ON a.author_id = p.id
      LEFT JOIN blog_categories c ON a.category_id = c.id
      LEFT JOIN aircraft_models am ON a.aircraft_model_id = am.id
      LEFT JOIN aircraft_manufacturers m ON am.manufacturer_id = m.id
      WHERE 1=1
    ''';

    final parameters = <String, dynamic>{'id': id};
    query += ' AND a.id = @id';

    final result = await _connection.execute(Sql.named(query), parameters: parameters);

    if (result.isEmpty) return null;

    final map = result.first.toColumnMap();
    final jsonMap = Map<String, dynamic>.from(map);
    
    if (map['author_profile_id'] != null) {
      jsonMap['author'] = {
        'id': map['author_profile_id'],
        'phone': map['author_phone'] ?? '',
        'email': map['author_email'],
        'first_name': map['author_first_name'],
        'last_name': map['author_last_name'],
        'avatar_url': map['author_avatar_url'],
      };
    }
      
      if (map['category_id'] != null) {
      jsonMap['category'] = {
        'id': map['category_id'],
        'name': map['category_name'],
        'color': map['category_color'],
      };
    }
    
    // Создаем объект aircraft_model только если все обязательные поля присутствуют
    if (map['aircraft_model_id'] != null && 
        map['aircraft_manufacturer_id'] != null &&
        map['aircraft_model_code'] != null) {
      jsonMap['aircraft_model'] = {
        'id': map['aircraft_model_id'],
        'manufacturer_id': map['aircraft_manufacturer_id'],
        'model_code': map['aircraft_model_code'],
        // Поля производителя с префиксом m_ для fromJson
        'm_id': map['aircraft_manufacturer_m_id'],
        'm_name': map['aircraft_manufacturer_m_name'],
      };
    }

    // Увеличиваем счетчик просмотров
    await _connection.execute(
      Sql.named('UPDATE blog_articles SET view_count = view_count + 1 WHERE id = @id'),
      parameters: {'id': id},
    );

    return BlogArticleModel.fromJson(jsonMap);
  }

  /// Получить все теги
  Future<List<BlogTagModel>> getTags() async {
    final result = await _connection.execute(Sql('SELECT * FROM blog_tags ORDER BY name ASC'));
    return result.map((row) => BlogTagModel.fromJson(row.toColumnMap())).toList();
  }

  /// Создать статью
  Future<BlogArticleModel> createArticle({
    required int authorId,
    int? categoryId,
    int? aircraftModelId,
    required String title,
    String? excerpt,
    required String content,
    String? coverImageUrl,
    String status = 'draft',
    List<int>? tagIds,
  }) async {
    final publishedAt = status == 'published' ? DateTime.now() : null;

    // Создаем статью
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO blog_articles (
          author_id, category_id, aircraft_model_id, title, excerpt, content,
          cover_image_url, status, published_at
        ) VALUES (
          @author_id, @category_id, @aircraft_model_id, @title, @excerpt, @content,
          @cover_image_url, @status, @published_at
        ) RETURNING id
      '''),
      parameters: {
        'author_id': authorId,
        'category_id': categoryId,
        'aircraft_model_id': aircraftModelId,
        'title': title,
        'excerpt': excerpt,
        'content': content,
        'cover_image_url': coverImageUrl,
        'status': status,
        'published_at': publishedAt,
      },
    );

    final articleId = result.first[0] as int;

    // Добавляем теги, если они указаны
    if (tagIds != null && tagIds.isNotEmpty) {
      for (final tagId in tagIds) {
        await _connection.execute(
          Sql.named('INSERT INTO blog_article_tags (article_id, tag_id) VALUES (@article_id, @tag_id) ON CONFLICT DO NOTHING'),
          parameters: {'article_id': articleId, 'tag_id': tagId},
        );
      }
    }

    // Возвращаем полную статью
    final article = await getArticle(id: articleId);
    if (article == null) {
      throw Exception('Failed to retrieve created article');
    }
    return article;
  }

  /// Обновить статью
  Future<BlogArticleModel> updateArticle({
    required int id,
    required int authorId, // Для проверки прав
    int? categoryId,
    int? aircraftModelId,
    String? title,
    String? excerpt,
    String? content,
    String? coverImageUrl,
    String? metaTitle,
    String? metaDescription,
    String? status,
    bool? isFeatured,
    List<int>? tagIds,
  }) async {
    // Проверяем, что пользователь является автором статьи
    final articleCheck = await _connection.execute(
      Sql.named('SELECT author_id FROM blog_articles WHERE id = @id'),
      parameters: {'id': id},
    );
    
    if (articleCheck.isEmpty) {
      throw Exception('Article not found');
    }
    
    if (articleCheck.first[0] as int != authorId) {
      throw Exception('Unauthorized: You can only update your own articles');
    }

    final updates = <String>[];
    final parameters = <String, dynamic>{'id': id};

    if (categoryId != null) {
      updates.add('category_id = @category_id');
      parameters['category_id'] = categoryId;
    }
    if (aircraftModelId != null) {
      updates.add('aircraft_model_id = @aircraft_model_id');
      parameters['aircraft_model_id'] = aircraftModelId;
    }
    if (title != null) {
      updates.add('title = @title');
      parameters['title'] = title;
    }
    if (excerpt != null) {
      updates.add('excerpt = @excerpt');
      parameters['excerpt'] = excerpt;
    }
    if (content != null) {
      updates.add('content = @content');
      parameters['content'] = content;
    }
    if (coverImageUrl != null) {
      updates.add('cover_image_url = @cover_image_url');
      parameters['cover_image_url'] = coverImageUrl;
    }
    if (status != null) {
      updates.add('status = @status');
      parameters['status'] = status;
      
      // Если статус меняется на published и published_at еще не установлен
      if (status == 'published') {
        updates.add('published_at = COALESCE(published_at, NOW())');
      }
    }

    updates.add('updated_at = NOW()');

    if (updates.isNotEmpty) {
      await _connection.execute(
        Sql.named('UPDATE blog_articles SET ${updates.join(', ')} WHERE id = @id'),
        parameters: parameters,
      );
    }

    // Обновляем теги, если они указаны
    if (tagIds != null) {
      // Удаляем все существующие теги
      await _connection.execute(
        Sql.named('DELETE FROM blog_article_tags WHERE article_id = @article_id'),
        parameters: {'article_id': id},
      );
      
      // Добавляем новые теги
      if (tagIds.isNotEmpty) {
        for (final tagId in tagIds) {
          await _connection.execute(
            Sql.named('INSERT INTO blog_article_tags (article_id, tag_id) VALUES (@article_id, @tag_id)'),
            parameters: {'article_id': id, 'tag_id': tagId},
          );
        }
      }
    }

    // Возвращаем обновленную статью
    final article = await getArticle(id: id);
    if (article == null) {
      throw Exception('Failed to retrieve updated article');
    }
    return article;
  }

  /// Удалить статью
  Future<bool> deleteArticle({
    required int id,
    required int authorId, // Для проверки прав
  }) async {
    // Проверяем, что пользователь является автором статьи
    final articleCheck = await _connection.execute(
      Sql.named('SELECT author_id FROM blog_articles WHERE id = @id'),
      parameters: {'id': id},
    );
    
    if (articleCheck.isEmpty) {
      return false;
    }
    
    if (articleCheck.first[0] as int != authorId) {
      throw Exception('Unauthorized: You can only delete your own articles');
    }

    final result = await _connection.execute(
      Sql.named('DELETE FROM blog_articles WHERE id = @id'),
      parameters: {'id': id},
    );
    
    return result.affectedRows > 0;
  }

  // ====================================================================
  // КОММЕНТАРИИ К СТАТЬЯМ
  // ====================================================================

  /// Получить комментарии к статье
  Future<List<BlogCommentModel>> getCommentsByArticleId(int articleId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          c.*,
          p.first_name as author_first_name,
          p.last_name as author_last_name,
          p.avatar_url as author_avatar_url,
          COALESCE((
            SELECT AVG(rating)::numeric
            FROM reviews
            WHERE reviewed_id = p.id 
              AND reply_to_review_id IS NULL 
              AND rating IS NOT NULL
          ), 0) AS author_rating
        FROM blog_comments c
        LEFT JOIN profiles p ON c.author_id = p.id
        WHERE c.article_id = @article_id
          AND c.is_approved = true
        ORDER BY c.created_at ASC
      '''),
      parameters: {'article_id': articleId},
    );

    return result.map((row) {
      final map = row.toColumnMap();
      return BlogCommentModel.fromJson(map);
    }).toList();
  }

  /// Создать комментарий
  Future<BlogCommentModel> createComment({
    required int articleId,
    required int authorId,
    String? parentCommentId,
    required String content,
  }) async {
    // Проверяем существование статьи
    final articleCheck = await _connection.execute(
      Sql.named('SELECT id FROM blog_articles WHERE id = @article_id'),
      parameters: {'article_id': articleId},
    );

    if (articleCheck.isEmpty) {
      throw Exception('Article not found');
    }

    // Если указан parent_comment_id, проверяем что он существует и принадлежит той же статье
    if (parentCommentId != null && parentCommentId.isNotEmpty) {
      final parentId = int.tryParse(parentCommentId);
      if (parentId != null) {
        final parentCheck = await _connection.execute(
          Sql.named('''
            SELECT id FROM blog_comments 
            WHERE id = @parent_id AND article_id = @article_id
          '''),
          parameters: {'parent_id': parentId, 'article_id': articleId},
        );

        if (parentCheck.isEmpty) {
          throw Exception('Parent comment not found or does not belong to this article');
        }
      }
    }

    final parentIdInt = parentCommentId != null && parentCommentId.isNotEmpty ? int.tryParse(parentCommentId) : null;

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO blog_comments (article_id, author_id, parent_comment_id, content)
        VALUES (@article_id, @author_id, @parent_comment_id, @content)
        RETURNING *
      '''),
      parameters: {
        'article_id': articleId,
        'author_id': authorId,
        'parent_comment_id': parentIdInt,
        'content': content,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create comment');
    }

    // Получаем данные автора через JOIN
    final commentMap = result.first.toColumnMap();
    final authorResult = await _connection.execute(
      Sql.named('''
        SELECT 
          first_name as author_first_name,
          last_name as author_last_name,
          avatar_url as author_avatar_url,
          COALESCE((
            SELECT AVG(rating)::numeric
            FROM reviews
            WHERE reviewed_id = @author_id 
              AND reply_to_review_id IS NULL 
              AND rating IS NOT NULL
          ), 0) AS author_rating
        FROM profiles
        WHERE id = @author_id
      '''),
      parameters: {'author_id': authorId},
    );

    if (authorResult.isNotEmpty) {
      final authorMap = authorResult.first.toColumnMap();
      commentMap.addAll(authorMap);
    }

    return BlogCommentModel.fromJson(commentMap);
  }

  /// Обновить комментарий
  Future<BlogCommentModel> updateComment({
    required int commentId,
    required int authorId,
    required String content,
  }) async {
    // Проверяем что комментарий существует и принадлежит автору
    final commentCheck = await _connection.execute(
      Sql.named('SELECT author_id FROM blog_comments WHERE id = @comment_id'),
      parameters: {'comment_id': commentId},
    );

    if (commentCheck.isEmpty) {
      throw Exception('Comment not found');
    }

    if (commentCheck.first[0] as int != authorId) {
      throw Exception('Unauthorized: You can only update your own comments');
    }

    final result = await _connection.execute(
      Sql.named('''
        UPDATE blog_comments
        SET content = @content, updated_at = NOW()
        WHERE id = @comment_id
        RETURNING *
      '''),
      parameters: {
        'comment_id': commentId,
        'content': content,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to update comment');
    }

    // Получаем данные автора через JOIN
    final commentMap = result.first.toColumnMap();
    final authorResult = await _connection.execute(
      Sql.named('''
        SELECT 
          first_name as author_first_name,
          last_name as author_last_name,
          avatar_url as author_avatar_url,
          COALESCE((
            SELECT AVG(rating)::numeric
            FROM reviews
            WHERE reviewed_id = @author_id 
              AND reply_to_review_id IS NULL 
              AND rating IS NOT NULL
          ), 0) AS author_rating
        FROM profiles
        WHERE id = @author_id
      '''),
      parameters: {'author_id': authorId},
    );

    if (authorResult.isNotEmpty) {
      final authorMap = authorResult.first.toColumnMap();
      commentMap.addAll(authorMap);
    }

    return BlogCommentModel.fromJson(commentMap);
  }

  /// Удалить комментарий
  Future<bool> deleteComment({required int commentId, required int authorId}) async {
    // Проверяем что комментарий существует и принадлежит автору
    final commentCheck = await _connection.execute(
      Sql.named('SELECT author_id FROM blog_comments WHERE id = @comment_id'),
      parameters: {'comment_id': commentId},
    );

    if (commentCheck.isEmpty) {
      throw Exception('Comment not found');
    }

    if (commentCheck.first[0] as int != authorId) {
      throw Exception('Unauthorized: You can only delete your own comments');
    }

    final result = await _connection.execute(
      Sql.named('DELETE FROM blog_comments WHERE id = @comment_id'),
      parameters: {'comment_id': commentId},
    );

    return result.affectedRows > 0;
  }
}

