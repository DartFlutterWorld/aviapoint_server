import 'dart:convert';
import 'dart:io';
import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/blog/api/create_blog_article_request.dart';
import 'package:aviapoint_server/blog/api/update_blog_article_request.dart';
import 'package:aviapoint_server/blog/repositories/blog_repository.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/telegram/telegram_bot_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http_parser/http_parser.dart';

part 'blog_controller.g.dart';

class BlogController {
  final BlogRepository _repository;

  BlogController({required BlogRepository repository}) : _repository = repository;

  Router get router => _$BlogControllerRouter(this);

  /// Получить все категории блога
  @Route.get('/api/blog/categories')
  @OpenApiRoute()
  Future<Response> getCategories(Request request) async {
    return wrapResponse(() async {
      final activeOnly = request.url.queryParameters['active_only'] != 'false';
      final categories = await _repository.getCategories(activeOnly: activeOnly);
      return Response.ok(jsonEncode(categories.map((c) => c.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить список статей блога
  @Route.get('/api/blog/articles')
  @OpenApiRoute()
  Future<Response> getArticles(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;

      final categoryId = params['category_id'] != null ? int.tryParse(params['category_id']!) : null;
      final aircraftModelId = params['aircraft_model_id'] != null ? int.tryParse(params['aircraft_model_id']!) : null;
      final authorId = params['author_id'] != null ? int.tryParse(params['author_id']!) : null;
      // Если status не передан, передаем null чтобы показать все статусы (для "моих статей")
      final status = params.containsKey('status') ? params['status'] : null;
      final isFeatured = params['featured'] == 'true' ? true : (params['featured'] == 'false' ? false : null);
      final searchQuery = params['search'];
      final limit = params['limit'] != null ? int.tryParse(params['limit']!) ?? 20 : 20;
      final offset = params['offset'] != null ? int.tryParse(params['offset']!) ?? 0 : 0;

      final articles = await _repository.getArticles(
        categoryId: categoryId,
        aircraftModelId: aircraftModelId,
        authorId: authorId,
        status: status,
        searchQuery: searchQuery,
        limit: limit,
        offset: offset,
      );

      return Response.ok(jsonEncode(articles.map((a) => a.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить детальную информацию о статье по ID
  @Route.get('/api/blog/articles/<id>')
  @OpenApiRoute()
  Future<Response> getArticleById(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Article ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid article ID'}), headers: jsonContentHeaders);
      }

      final article = await _repository.getArticle(id: id);
      if (article == null) {
        return Response.notFound(jsonEncode({'error': 'Article not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(article.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Получить все теги
  @Route.get('/api/blog/tags')
  @OpenApiRoute()
  Future<Response> getTags(Request request) async {
    return wrapResponse(() async {
      final tags = await _repository.getTags();
      return Response.ok(jsonEncode(tags.map((t) => t.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Создать статью (требуется авторизация)
  @Route.post('/api/blog/articles')
  @OpenApiRoute()
  Future<Response> createArticle(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final authorId = int.parse(userId);

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'];
      final isMultipart = contentType != null && contentType.startsWith('multipart/form-data');

      String? coverImageUrl;
      Map<String, dynamic> articleData = {};

      if (isMultipart) {
        // Парсим multipart запрос
        final mediaType = MediaType.parse(contentType);
        final boundary = mediaType.parameters['boundary'];
        if (boundary == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Missing boundary in Content-Type'}),
            headers: jsonContentHeaders,
          );
        }

        // Читаем тело запроса
        final bodyBytes = <int>[];
        await for (final chunk in request.read()) {
          bodyBytes.addAll(chunk);
        }

        // Парсим multipart вручную
        final boundaryMarker = '--$boundary';
        final boundaryBytes = utf8.encode(boundaryMarker);
        final parts = <Map<String, dynamic>>[];

        int searchStart = 0;
        while (true) {
          final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
          if (boundaryIndex == -1) break;

          searchStart = boundaryIndex + boundaryBytes.length;
          if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
          if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

          final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
          final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

          if (partEnd > searchStart) {
            final partBytes = bodyBytes.sublist(searchStart, partEnd);
            final partData = _parseMultipartPart(partBytes);
            if (partData != null) {
              parts.add(partData);
            }
          }

          if (nextBoundaryIndex == -1) break;
          searchStart = nextBoundaryIndex;
        }

        // Обрабатываем текстовые поля
        for (final part in parts) {
          final contentDisposition = part['content-disposition'] as String?;
          if (contentDisposition == null) continue;

          final nameMatch = RegExp('name=["\']?([^"\']+)').firstMatch(contentDisposition);
          if (nameMatch == null) continue;

          final fieldName = nameMatch.group(1);
          if (fieldName == null) continue;

          // Проверяем, является ли это файлом
          final isFile = RegExp('filename=').hasMatch(contentDisposition);
          if (isFile) {
            continue; // Файлы обработаем отдельно
          }

          final data = part['data'] as List<int>?;
          if (data == null) continue;

          final value = utf8.decode(data).trim();
          articleData[fieldName] = value;
        }

        // Обрабатываем фотографию обложки
        final publicDir = Directory('public');
        if (!await publicDir.exists()) {
          await publicDir.create(recursive: true);
        }

        final blogDir = Directory('public/blog');
        if (!await blogDir.exists()) {
          await blogDir.create(recursive: true);
        }

        for (final part in parts) {
          final contentDisposition = part['content-disposition'] as String?;
          if (contentDisposition == null) continue;

          final isCoverImageField = RegExp('name=["\']?cover_image').hasMatch(contentDisposition);
          if (!isCoverImageField) continue;

          final photoData = part['data'] as List<int>?;
          if (photoData == null || photoData.isEmpty) continue;

          // Валидация размера (максимум 5MB)
          if (photoData.length > 5 * 1024 * 1024) {
            return Response.badRequest(
              body: jsonEncode({'error': 'File size exceeds 5MB limit'}),
              headers: jsonContentHeaders,
            );
          }

          // Определяем расширение
          String extension = 'jpg';
          final partContentType = part['content-type'] as String?;
          if (partContentType != null) {
            final partMediaType = MediaType.parse(partContentType);
            if (partMediaType.subtype == 'jpeg' || partMediaType.subtype == 'jpg') {
              extension = 'jpg';
            } else if (partMediaType.subtype == 'png') {
              extension = 'png';
            }
          }

          // Сохраняем фото
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final random = DateTime.now().microsecondsSinceEpoch % 1000000;
          final fileName = 'cover.$authorId.$timestamp.$random.$extension';
          final filePath = 'public/blog/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(photoData);

          coverImageUrl = 'blog/$fileName';
        }
      } else {
        // Обычный JSON запрос
        final body = await request.readAsString();
        final createRequest = CreateBlogArticleRequest.fromJson(jsonDecode(body));
        articleData = createRequest.toJson();
        coverImageUrl = createRequest.coverImageUrl;
      }

      // Валидация
      final title = articleData['title'] as String? ?? '';
      if (title.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Title is required'}),
          headers: jsonContentHeaders,
        );
      }

      final content = articleData['content'] as String? ?? '';
      if (content.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Content is required'}),
          headers: jsonContentHeaders,
        );
      }

      // Валидация категории (обязательное поле)
      final categoryId = articleData['category_id'] != null ? int.tryParse(articleData['category_id'].toString()) : null;
      if (categoryId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Category is required'}),
          headers: jsonContentHeaders,
        );
      }

      // Валидация краткого описания (обязательное поле)
      final excerpt = articleData['excerpt'] as String? ?? '';
      if (excerpt.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Excerpt is required'}),
          headers: jsonContentHeaders,
        );
      }

      // Валидация обложки (обязательное поле)
      if (coverImageUrl == null || coverImageUrl.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Cover image is required'}),
          headers: jsonContentHeaders,
        );
      }

      // Создаем статью
      final article = await _repository.createArticle(
        authorId: authorId,
        categoryId: categoryId,
        aircraftModelId: articleData['aircraft_model_id'] != null ? int.tryParse(articleData['aircraft_model_id'].toString()) : null,
        title: title,
        excerpt: excerpt,
        content: content,
        coverImageUrl: coverImageUrl,
        status: articleData['status'] as String? ?? 'draft',
        tagIds: articleData['tag_ids'] != null ? (articleData['tag_ids'] as List).map((e) => int.tryParse(e.toString())).whereType<int>().toList() : null,
      );

      // Отправляем уведомление в Telegram о создании статьи
      try {
        final author = article.author;
        if (author != null) {
          final authorName = '${author.firstName ?? ''} ${author.lastName ?? ''}'.trim();
          final authorPhone = author.phone ?? '';

          final categoryName = article.category?.name;
          String? aircraftModelName;
          if (article.aircraftModel != null) {
            final manufacturerName = article.aircraftModel!.manufacturer?.name ?? '';
            final modelCode = article.aircraftModel!.modelCode;
            final name = '$manufacturerName $modelCode'.trim();
            aircraftModelName = name.isEmpty ? null : name;
          }

          await TelegramBotService().notifyBlogArticleCreated(
            articleId: article.id,
            authorId: authorId,
            authorName: authorName.isNotEmpty ? authorName : 'Пользователь #$authorId',
            authorPhone: authorPhone,
            title: title,
            excerpt: article.excerpt,
            status: article.status,
            categoryName: categoryName,
            aircraftModelName: aircraftModelName,
          );
        }
      } catch (e) {
        // Логируем ошибку, но не прерываем выполнение
        print('⚠️ [BlogController] Ошибка отправки Telegram уведомления о создании статьи: $e');
      }

      return Response.ok(jsonEncode(article.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Обновить статью (требуется авторизация и права автора)
  @Route.put('/api/blog/articles/<id>')
  @OpenApiRoute()
  Future<Response> updateArticle(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final authorId = int.parse(userId);

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Article ID is required'}),
          headers: jsonContentHeaders,
        );
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid article ID'}),
          headers: jsonContentHeaders,
        );
      }

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'];
      final isMultipart = contentType != null && contentType.startsWith('multipart/form-data');

      String? coverImageUrl;
      Map<String, dynamic> articleData = {};

      if (isMultipart) {
        // Парсим multipart запрос
        final mediaType = MediaType.parse(contentType);
        final boundary = mediaType.parameters['boundary'];
        if (boundary == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Missing boundary in Content-Type'}),
            headers: jsonContentHeaders,
          );
        }

        // Читаем тело запроса
        final bodyBytes = <int>[];
        await for (final chunk in request.read()) {
          bodyBytes.addAll(chunk);
        }

        // Парсим multipart вручную
        final boundaryMarker = '--$boundary';
        final boundaryBytes = utf8.encode(boundaryMarker);
        final parts = <Map<String, dynamic>>[];

        int searchStart = 0;
        while (true) {
          final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
          if (boundaryIndex == -1) break;

          searchStart = boundaryIndex + boundaryBytes.length;
          if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
          if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

          final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
          final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

          if (partEnd > searchStart) {
            final partBytes = bodyBytes.sublist(searchStart, partEnd);
            final partData = _parseMultipartPart(partBytes);
            if (partData != null) {
              parts.add(partData);
            }
          }

          if (nextBoundaryIndex == -1) break;
          searchStart = nextBoundaryIndex;
        }

        // Обрабатываем текстовые поля
        for (final part in parts) {
          final contentDisposition = part['content-disposition'] as String?;
          if (contentDisposition == null) continue;

          final nameMatch = RegExp('name=["\']?([^"\']+)').firstMatch(contentDisposition);
          if (nameMatch == null) continue;

          final fieldName = nameMatch.group(1);
          if (fieldName == null) continue;

          // Проверяем, является ли это файлом
          final isFile = RegExp('filename=').hasMatch(contentDisposition);
          if (isFile) {
            continue; // Файлы обработаем отдельно
          }

          final data = part['data'] as List<int>?;
          if (data == null) continue;

          final value = utf8.decode(data).trim();
          articleData[fieldName] = value;
        }

        // Обрабатываем фотографию обложки
        final publicDir = Directory('public');
        if (!await publicDir.exists()) {
          await publicDir.create(recursive: true);
        }

        final blogDir = Directory('public/blog');
        if (!await blogDir.exists()) {
          await blogDir.create(recursive: true);
        }

        for (final part in parts) {
          final contentDisposition = part['content-disposition'] as String?;
          if (contentDisposition == null) continue;

          final isCoverImageField = RegExp('name=["\']?cover_image').hasMatch(contentDisposition);
          if (!isCoverImageField) continue;

          final photoData = part['data'] as List<int>?;
          if (photoData == null || photoData.isEmpty) continue;

          // Валидация размера (максимум 5MB)
          if (photoData.length > 5 * 1024 * 1024) {
            return Response.badRequest(
              body: jsonEncode({'error': 'File size exceeds 5MB limit'}),
              headers: jsonContentHeaders,
            );
          }

          // Определяем расширение
          String extension = 'jpg';
          final partContentType = part['content-type'] as String?;
          if (partContentType != null) {
            final partMediaType = MediaType.parse(partContentType);
            if (partMediaType.subtype == 'jpeg' || partMediaType.subtype == 'jpg') {
              extension = 'jpg';
            } else if (partMediaType.subtype == 'png') {
              extension = 'png';
            }
          }

          // Сохраняем фото
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final random = DateTime.now().microsecondsSinceEpoch % 1000000;
          final fileName = 'cover.$id.$authorId.$timestamp.$random.$extension';
          final filePath = 'public/blog/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(photoData);

          coverImageUrl = 'blog/$fileName';
        }
      } else {
        // Обычный JSON запрос
        final body = await request.readAsString();
        final updateRequest = UpdateBlogArticleRequest.fromJson(jsonDecode(body));
        articleData = updateRequest.toJson();
        coverImageUrl = updateRequest.coverImageUrl;
      }

      try {
        // Обновляем статью (проверка прав выполняется в репозитории)
        final article = await _repository.updateArticle(
          id: id,
          authorId: authorId,
          categoryId: articleData['category_id'] != null ? int.tryParse(articleData['category_id'].toString()) : null,
          aircraftModelId: articleData['aircraft_model_id'] != null ? int.tryParse(articleData['aircraft_model_id'].toString()) : null,
          title: articleData['title'] as String?,
          excerpt: articleData['excerpt'] as String?,
          content: articleData['content'] as String?,
          coverImageUrl: coverImageUrl,
          status: articleData['status'] as String?,
          tagIds: articleData['tag_ids'] != null ? (articleData['tag_ids'] as List).map((e) => int.tryParse(e.toString())).whereType<int>().toList() : null,
        );

        return Response.ok(jsonEncode(article.toJson()), headers: jsonContentHeaders);
      } catch (e) {
        if (e.toString().contains('Unauthorized')) {
          return Response.forbidden(
            jsonEncode({'error': e.toString()}),
            headers: jsonContentHeaders,
          );
        }
        if (e.toString().contains('not found')) {
          return Response.notFound(
            jsonEncode({'error': e.toString()}),
            headers: jsonContentHeaders,
          );
        }
        rethrow;
      }
    });
  }

  /// Удалить статью (требуется авторизация и права автора)
  @Route.delete('/api/blog/articles/<id>')
  @OpenApiRoute()
  Future<Response> deleteArticle(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userId = tokenService.getUserIdFromToken(token);
      if (userId == null || userId.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final authorId = int.parse(userId);

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Article ID is required'}),
          headers: jsonContentHeaders,
        );
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid article ID'}),
          headers: jsonContentHeaders,
        );
      }

      try {
        // Удаляем статью (проверка прав выполняется в репозитории)
        final deleted = await _repository.deleteArticle(id: id, authorId: authorId);

        if (!deleted) {
          return Response.notFound(
            jsonEncode({'error': 'Article not found'}),
            headers: jsonContentHeaders,
          );
        }

        return Response(204);
      } catch (e) {
        if (e.toString().contains('Unauthorized')) {
          return Response.forbidden(
            jsonEncode({'error': e.toString()}),
            headers: jsonContentHeaders,
          );
        }
        rethrow;
      }
    });
  }

  /// Загрузить изображение для контента статьи (для существующих статей)
  @Route.post('/api/blog/articles/<id>/content-images')
  @OpenApiRoute()
  Future<Response> uploadContentImage(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userIdStr = tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final userId = int.parse(userIdStr);

      // Получаем ID статьи
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Article ID is required'}),
          headers: jsonContentHeaders,
        );
      }

      final articleId = int.tryParse(idStr);
      if (articleId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid article ID'}),
          headers: jsonContentHeaders,
        );
      }

      // Проверяем, что статья существует и пользователь является автором
      final article = await _repository.getArticle(id: articleId);
      if (article == null) {
        return Response.notFound(
          jsonEncode({'error': 'Article not found'}),
          headers: jsonContentHeaders,
        );
      }

      if (article.authorId != userId) {
        return Response.forbidden(
          jsonEncode({'error': 'You can only upload images to your own articles'}),
          headers: jsonContentHeaders,
        );
      }

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'];
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}),
          headers: jsonContentHeaders,
        );
      }

      // Парсим multipart запрос
      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing boundary in Content-Type'}),
          headers: jsonContentHeaders,
        );
      }

      // Читаем тело запроса
      final bodyBytes = <int>[];
      await for (final chunk in request.read()) {
        bodyBytes.addAll(chunk);
      }

      // Парсим multipart вручную
      final boundaryMarker = '--$boundary';
      final boundaryBytes = utf8.encode(boundaryMarker);
      final parts = <Map<String, dynamic>>[];

      int searchStart = 0;
      while (true) {
        final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (boundaryIndex == -1) break;

        searchStart = boundaryIndex + boundaryBytes.length;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

        if (partEnd > searchStart) {
          final partBytes = bodyBytes.sublist(searchStart, partEnd);
          final partData = _parseMultipartPart(partBytes);
          if (partData != null) {
            parts.add(partData);
          }
        }

        if (nextBoundaryIndex == -1) break;
        searchStart = nextBoundaryIndex;
      }

      // Ищем изображение
      String? imageUrl;
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final blogArticlesDir = Directory('public/blog_articles');
      if (!await blogArticlesDir.exists()) {
        await blogArticlesDir.create(recursive: true);
      }

      final articleImagesDir = Directory('public/blog_articles/$articleId');
      if (!await articleImagesDir.exists()) {
        await articleImagesDir.create(recursive: true);
      }

      final imagesDir = Directory('public/blog_articles/$articleId/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isImageField = RegExp('name=["\']?image').hasMatch(contentDisposition);
        if (!isImageField) continue;

        final imageData = part['data'] as List<int>?;
        if (imageData == null || imageData.isEmpty) continue;

        // Валидация размера (максимум 5MB)
        if (imageData.length > 5 * 1024 * 1024) {
          return Response.badRequest(
            body: jsonEncode({'error': 'File size exceeds 5MB limit'}),
            headers: jsonContentHeaders,
          );
        }

        // Определяем расширение
        String extension = 'jpg';
        final partContentType = part['content-type'] as String?;
        if (partContentType != null) {
          final partMediaType = MediaType.parse(partContentType);
          if (partMediaType.subtype == 'jpeg' || partMediaType.subtype == 'jpg') {
            extension = 'jpg';
          } else if (partMediaType.subtype == 'png') {
            extension = 'png';
          } else if (partMediaType.subtype == 'webp') {
            extension = 'webp';
          }
        }

        // Сохраняем изображение
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = '$articleId.$timestamp.$random.$extension';
        final filePath = 'public/blog_articles/$articleId/images/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(imageData);

        imageUrl = 'blog_articles/$articleId/images/$fileName';
        break; // Обрабатываем только первое изображение
      }

      if (imageUrl == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No image provided'}),
          headers: jsonContentHeaders,
        );
      }

      return Response.ok(
        jsonEncode({'url': imageUrl}),
        headers: jsonContentHeaders,
      );
    });
  }

  /// Загрузить изображение для контента новой статьи (временный endpoint)
  @Route.post('/api/blog/articles/content-images/upload')
  @OpenApiRoute()
  Future<Response> uploadContentImageTemporary(Request request) async {
    return wrapResponse(() async {
      // Проверка авторизации
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
      }

      final userIdStr = tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final userId = int.parse(userIdStr);

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'];
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}),
          headers: jsonContentHeaders,
        );
      }

      // Парсим multipart запрос
      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing boundary in Content-Type'}),
          headers: jsonContentHeaders,
        );
      }

      // Читаем тело запроса
      final bodyBytes = <int>[];
      await for (final chunk in request.read()) {
        bodyBytes.addAll(chunk);
      }

      // Парсим multipart вручную
      final boundaryMarker = '--$boundary';
      final boundaryBytes = utf8.encode(boundaryMarker);
      final parts = <Map<String, dynamic>>[];

      int searchStart = 0;
      while (true) {
        final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (boundaryIndex == -1) break;

        searchStart = boundaryIndex + boundaryBytes.length;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

        if (partEnd > searchStart) {
          final partBytes = bodyBytes.sublist(searchStart, partEnd);
          final partData = _parseMultipartPart(partBytes);
          if (partData != null) {
            parts.add(partData);
          }
        }

        if (nextBoundaryIndex == -1) break;
        searchStart = nextBoundaryIndex;
      }

      // Ищем изображение
      String? imageUrl;
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final blogArticlesDir = Directory('public/blog_articles');
      if (!await blogArticlesDir.exists()) {
        await blogArticlesDir.create(recursive: true);
      }

      final tempDir = Directory('public/blog_articles/temp');
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isImageField = RegExp('name=["\']?image').hasMatch(contentDisposition);
        if (!isImageField) continue;

        final imageData = part['data'] as List<int>?;
        if (imageData == null || imageData.isEmpty) continue;

        // Валидация размера (максимум 5MB)
        if (imageData.length > 5 * 1024 * 1024) {
          return Response.badRequest(
            body: jsonEncode({'error': 'File size exceeds 5MB limit'}),
            headers: jsonContentHeaders,
          );
        }

        // Определяем расширение
        String extension = 'jpg';
        final partContentType = part['content-type'] as String?;
        if (partContentType != null) {
          final partMediaType = MediaType.parse(partContentType);
          if (partMediaType.subtype == 'jpeg' || partMediaType.subtype == 'jpg') {
            extension = 'jpg';
          } else if (partMediaType.subtype == 'png') {
            extension = 'png';
          } else if (partMediaType.subtype == 'webp') {
            extension = 'webp';
          }
        }

        // Сохраняем изображение во временную папку
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = '$userId.$timestamp.$random.$extension';
        final filePath = 'public/blog_articles/temp/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(imageData);

        imageUrl = 'blog_articles/temp/$fileName';
        break; // Обрабатываем только первое изображение
      }

      if (imageUrl == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No image provided'}),
          headers: jsonContentHeaders,
        );
      }

      return Response.ok(
        jsonEncode({'url': imageUrl}),
        headers: jsonContentHeaders,
      );
    });
  }

  // Вспомогательные методы для парсинга multipart
  int _indexOfBytes(List<int> haystack, List<int> needle, int start) {
    for (int i = start; i <= haystack.length - needle.length; i++) {
      bool match = true;
      for (int j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
    return -1;
  }

  Map<String, dynamic>? _parseMultipartPart(List<int> partBytes) {
    // Ищем разделитель между заголовками и телом
    final crlf = [13, 10, 13, 10]; // \r\n\r\n
    int headerEnd = -1;
    for (int i = 0; i <= partBytes.length - crlf.length; i++) {
      bool match = true;
      for (int j = 0; j < crlf.length; j++) {
        if (partBytes[i + j] != crlf[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        headerEnd = i + crlf.length;
        break;
      }
    }

    if (headerEnd == -1) return null;

    // Парсим заголовки
    final headerBytes = partBytes.sublist(0, headerEnd - crlf.length);
    final headers = <String, String>{};
    final headerLines = utf8.decode(headerBytes).split('\r\n');
    for (final line in headerLines) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim().toLowerCase();
        final value = line.substring(colonIndex + 1).trim();
        headers[key] = value;
      }
    }

    // Извлекаем тело
    final bodyBytes = partBytes.sublist(headerEnd);
    // Удаляем завершающие \r\n
    while (bodyBytes.isNotEmpty && (bodyBytes.last == 13 || bodyBytes.last == 10)) {
      bodyBytes.removeLast();
    }

    return {
      'content-disposition': headers['content-disposition'],
      'content-type': headers['content-type'],
      'data': bodyBytes,
    };
  }
}
