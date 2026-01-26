import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/news/repositories/news_repository.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:aviapoint_server/telegram/telegram_bot_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'news_controller.g.dart';

class NewsController {
  final NewsRepository _newsRepository;
  NewsController({required NewsRepository newsRepository}) : _newsRepository = newsRepository;

  Router get router => _$NewsControllerRouter(this);

  ///
  /// Получение всех категорий для новостей
  ///
  /// Получение всех категорий для новостей
  ///

  @Route.get('/api/category_news')
  @OpenApiRoute()
  Future<Response> getCategoryNews(Request request) async {
    final body = await _newsRepository.getCategoryNews();

    return wrapResponse(
      () async {
        return Response.ok(
          jsonEncode(body),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  ///
  /// Получение всех видео сториков
  ///
  /// Получение всех видео сториков
  ///

  @Route.get('/api/news')
  @OpenApiRoute()
  Future<Response> getnews(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;
      final publishedParam = params['published'];
      final authorIdParam = params['author_id'];
      bool? published;
      int? authorId;
      bool isAdmin = false;

      // Если передан author_id в query параметрах, используем его
      if (authorIdParam != null && authorIdParam.isNotEmpty) {
        authorId = int.tryParse(authorIdParam);
      }

      // Проверяем авторизацию только для определения isAdmin (для доступа к неопубликованным новостям)
      // НО authorId передаем в репозиторий ТОЛЬКО если он явно передан в query параметрах
      int? userIdForAdminCheck;
      final authHeader = request.headers['Authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        final tokenService = getIt.get<TokenService>();
        if (tokenService.validateToken(token)) {
          final userIdStr = tokenService.getUserIdFromToken(token);
          if (userIdStr != null && userIdStr.isNotEmpty) {
            userIdForAdminCheck = int.tryParse(userIdStr);
            if (userIdForAdminCheck != null) {
              isAdmin = await _newsRepository.isAdmin(userIdForAdminCheck);
            }
          }
        }
      }

      // Если authorId передан в query, проверяем, является ли он админом
      if (authorId != null) {
        isAdmin = await _newsRepository.isAdmin(authorId);
      }

      // Если запрашивают предложенные новости (published=false), устанавливаем published = false
      if (publishedParam == 'false') {
        published = false;
      } else {
        // Если передан authorId в query, но published не указан, возвращаем все новости пользователя (published = null)
        // Иначе используем значение из параметра или по умолчанию true
        if (authorId != null && publishedParam == null) {
          published = null; // Вернет все новости пользователя (и опубликованные, и неопубликованные)
        } else {
          published = publishedParam != null ? publishedParam == 'true' : true;
        }
      }

      // Передаем authorId в репозиторий ТОЛЬКО если он был явно передан в query параметрах
      // Это позволяет получать все новости для всех пользователей, когда authorId не указан
      final body = await _newsRepository.getNews(
        published: published,
        authorId: authorId, // Будет null, если не передан в query
        isAdmin: isAdmin,
      );

      return Response.ok(
        jsonEncode(body.map((e) => e.toJson()).toList()),
        headers: jsonContentHeaders,
      );
    });
  }

  ///
  /// Получение конкретной новости
  ///
  /// Получение конкретной новости
  ///

  @Route.get('/api/news/<id>')
  @OpenApiRoute()
  Future<Response> getNewsById(Request request) async {
    return wrapResponse(
      () async {
        final id = int.parse(request.params['id']!);

        final news = await _newsRepository.getNewsById(id);
        final newsJson = news.toJson();

        // Загружаем дополнительные изображения
        final additionalImages = await _newsRepository.getNewsImages(id);
        newsJson['additional_images'] = additionalImages;

        return Response.ok(
          jsonEncode(newsJson),
          headers: jsonContentHeaders,
        );
      },
    );
  }

  ///
  /// Получение новостей по конкретной категории
  ///
  /// Получение новостей по конкретной категории
  ///

  @Route.get('/api/news/category/<id>')
  @OpenApiRoute()
  Future<Response> getNewsByCategory(Request request) async {
    return wrapResponse(() async {
      final id = int.parse(request.params['id']!);
      final params = request.url.queryParameters;
      final publishedParam = params['published'];
      bool? published;
      int? authorId;
      bool isAdmin = false;

      // Проверяем авторизацию, если запрашивают предложенные новости
      if (publishedParam == 'false') {
        final authHeader = request.headers['Authorization'];
        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          final token = authHeader.substring(7);
          final tokenService = getIt.get<TokenService>();
          if (tokenService.validateToken(token)) {
            final userIdStr = tokenService.getUserIdFromToken(token);
            if (userIdStr != null && userIdStr.isNotEmpty) {
              authorId = int.tryParse(userIdStr);
              if (authorId != null) {
                isAdmin = await _newsRepository.isAdmin(authorId);
              }
            }
          }
        }
        published = false;
      } else {
        published = publishedParam != null ? publishedParam == 'true' : true;
      }

      return Response.ok(
        jsonEncode((await _newsRepository.getNewsByCategory(
          id,
          published: published,
          authorId: authorId,
          isAdmin: isAdmin,
        ))
            .map((e) => e.toJson())
            .toList()),
        headers: jsonContentHeaders,
      );
    });
  }

  /// Создать новость (требуется авторизация)
  @Route.post('/api/news')
  @OpenApiRoute()
  Future<Response> createNews(Request request) async {
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

      // Проверяем, является ли пользователь админом
      final isAdmin = await _newsRepository.isAdmin(authorId);

      // Если админ - новость публикуется сразу (published = true), иначе отправляется на модерацию (published = false)
      final published = isAdmin;

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'];
      final isMultipart = contentType != null && contentType.startsWith('multipart/form-data');

      String? pictureMiniUrl;
      String? pictureBigUrl;
      Map<String, dynamic> newsData = {};

      // Храним изображения в памяти до получения id новости
      List<int>? pictureMiniBytes;
      List<int>? pictureBigBytes;
      String? pictureMiniExtension;
      String? pictureBigExtension;

      // Дополнительные изображения
      List<List<int>> additionalImageBytesList = [];
      List<String> additionalImageExtensions = [];

      if (isMultipart) {
        // Парсим multipart запрос
        final mediaType = MediaType.parse(contentType);
        final boundary = mediaType.parameters['boundary'];
        if (boundary == null) {
          return Response.badRequest(body: jsonEncode({'error': 'Missing boundary in Content-Type'}), headers: jsonContentHeaders);
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

          // Пропускаем \r\n после boundary
          if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
          if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

          final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
          if (nextBoundaryIndex != -1) {
            final partBytes = bodyBytes.sublist(searchStart, nextBoundaryIndex);
            final partData = _parseMultipartPart(partBytes);
            if (partData != null) {
              parts.add(partData);
            }
          }

          if (nextBoundaryIndex == -1) break;
          searchStart = nextBoundaryIndex;
        }

        // Обрабатываем текстовые поля и файлы
        for (final part in parts) {
          final contentDisposition = part['content-disposition'] as String?;
          if (contentDisposition == null) continue;

          final nameMatch = RegExp('name=["\']?([^"\';]+)').firstMatch(contentDisposition);
          if (nameMatch == null) continue;

          final fieldName = nameMatch.group(1);
          if (fieldName == null) continue;
          final partData = part['data'] as List<int>?;
          if (partData == null) continue;

          if (fieldName == 'picture_mini' || fieldName == 'picture_big') {
            // Это файл изображения
            if (partData.isNotEmpty) {
              // Валидация размера (максимум 10MB)
              if (partData.length > 10 * 1024 * 1024) {
                return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 10MB limit'}), headers: jsonContentHeaders);
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

              // Сохраняем изображение в память (будет сохранено в news/{id}/ после получения id)
              if (fieldName == 'picture_mini') {
                pictureMiniBytes = partData;
                pictureMiniExtension = extension;
              } else {
                pictureBigBytes = partData;
                pictureBigExtension = extension;
              }
            }
          } else if (fieldName == 'additional_images[]') {
            // Дополнительные изображения
            if (partData.isNotEmpty) {
              // Валидация размера (максимум 10MB)
              if (partData.length > 10 * 1024 * 1024) {
                return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 10MB limit'}), headers: jsonContentHeaders);
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

              additionalImageBytesList.add(partData);
              additionalImageExtensions.add(extension);
            }
          } else {
            // Это текстовое поле
            final value = utf8.decode(partData);
            newsData[fieldName] = value;
          }
        }
      } else {
        // Обычный JSON запрос
        final body = await request.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;
        newsData = jsonData;
        pictureMiniUrl = jsonData['picture_mini'] as String?;
        pictureBigUrl = jsonData['picture_big'] as String?;
      }

      // Валидация
      final title = newsData['title'] as String? ?? '';
      if (title.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Title is required'}), headers: jsonContentHeaders);
      }

      final subTitle = newsData['sub_title'] as String? ?? '';
      if (subTitle.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Sub title is required'}), headers: jsonContentHeaders);
      }

      // Источник необязателен
      final source = newsData['source'] as String? ?? '';

      final body = newsData['body'] as String? ?? '';
      if (body.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Body is required'}), headers: jsonContentHeaders);
      }

      // Проверяем наличие изображения для обложки
      if (pictureBigUrl == null && pictureBigBytes == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Picture big is required'}), headers: jsonContentHeaders);
      }

      // Категория необязательна, используем категорию по умолчанию (ID = 1), если не указана
      final categoryId = newsData['category_id'] != null ? (int.tryParse(newsData['category_id'].toString()) ?? 1) : 1;

      final isBigNews = newsData['is_big_news'] == true || newsData['is_big_news'] == 'true';

      // Получаем content из newsData
      final content = newsData['content'] as String?;

      // Создаем новость с временными путями (пустые строки, если файлы загружены)
      final news = await _newsRepository.createNews(
        authorId: authorId,
        title: title,
        subTitle: subTitle,
        source: source,
        body: body,
        content: content,
        pictureMini: pictureMiniUrl ?? '', // Временно пустое, обновим после сохранения файлов
        pictureBig: pictureBigUrl ?? '', // Временно пустое, обновим после сохранения файлов
        isBigNews: isBigNews,
        categoryId: categoryId,
        published: published, // true для админов, false для обычных пользователей
      );

      // Создаем папку news/{id}/
      final newsIdDir = Directory('public/news/${news.id}');
      if (!await newsIdDir.exists()) {
        await newsIdDir.create(recursive: true);
      }

      String? finalPictureMiniPath;
      String? finalPictureBigPath;

      // Сохраняем большое изображение в news/{id}/
      if (pictureBigBytes != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'big.$authorId.$timestamp.$random.${pictureBigExtension ?? 'jpg'}';
        final filePath = 'public/news/${news.id}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pictureBigBytes);
        finalPictureBigPath = 'news/${news.id}/$fileName';
      } else if (pictureBigUrl != null && pictureBigUrl.isNotEmpty) {
        // Если это URL, используем его как есть
        finalPictureBigPath = pictureBigUrl;
      } else {
        // Это не должно произойти из-за проверки выше, но на всякий случай
        return Response.badRequest(body: jsonEncode({'error': 'Picture big is required'}), headers: jsonContentHeaders);
      }

      // Сохраняем миниатюру в news/{id}/ (или используем большое изображение)
      if (pictureMiniBytes != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'mini.$authorId.$timestamp.$random.${pictureMiniExtension ?? 'jpg'}';
        final filePath = 'public/news/${news.id}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pictureMiniBytes);
        finalPictureMiniPath = 'news/${news.id}/$fileName';
      } else if (pictureMiniUrl != null && pictureMiniUrl.isNotEmpty) {
        // Если это URL, используем его как есть
        finalPictureMiniPath = pictureMiniUrl;
      } else {
        // Если миниатюра не была загружена, используем большое изображение
        finalPictureMiniPath = finalPictureBigPath;
      }

      // Обновляем пути в базе данных
      // finalPictureBigPath гарантированно не null из-за проверки выше
      // finalPictureMiniPath гарантированно не null, так как либо загружено мини-изображение, либо используется большое
      await _newsRepository.updateNewsImages(
        newsId: news.id,
        pictureMini: finalPictureMiniPath,
        pictureBig: finalPictureBigPath,
      );

      // Сохраняем дополнительные изображения
      if (additionalImageBytesList.isNotEmpty) {
        final List<String> additionalImageUrls = [];
        final List<String> additionalImagePaths = [];

        for (int i = 0; i < additionalImageBytesList.length; i++) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final random = DateTime.now().microsecondsSinceEpoch % 1000000;
          final extension = additionalImageExtensions[i];
          final fileName = 'additional.$authorId.$timestamp.$random.$i.$extension';
          final filePath = 'public/news/${news.id}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(additionalImageBytesList[i]);

          additionalImageUrls.add('news/${news.id}/$fileName');
          additionalImagePaths.add(filePath);
        }

        await _newsRepository.saveNewsImages(
          newsId: news.id,
          imageUrls: additionalImageUrls,
          imagePaths: additionalImagePaths,
        );
      }

      // Получаем обновленную новость для возврата
      final finalNews = await _newsRepository.getNewsById(news.id);

      // Получаем дополнительные изображения
      final additionalImages = await _newsRepository.getNewsImages(news.id);

      // Отправляем уведомление в Telegram о создании новости
      try {
        final profileRepository = getIt.get<ProfileRepository>();
        final author = await profileRepository.fetchProfileById(authorId);
        final authorName = '${author.firstName ?? ''} ${author.lastName ?? ''}'.trim();
        final authorPhone = author.phone;

        // Получаем название категории
        final category = await _newsRepository.getCategoryById(categoryId);
        final categoryName = category?.title;

        // Получаем базовый URL сервера
        final baseUrl = Platform.environment['BASE_URL'] ?? Platform.environment['SERVER_BASE_URL'] ?? 'https://avia-point.com';

        await TelegramBotService().notifyNewsCreated(
          newsId: finalNews.id,
          authorId: authorId,
          authorName: authorName.isNotEmpty ? authorName : 'Пользователь #$authorId',
          authorPhone: authorPhone,
          title: title,
          subTitle: subTitle,
          source: source,
          body: body,
          pictureMiniUrl: finalPictureMiniPath,
          pictureBigUrl: finalPictureBigPath,
          categoryId: categoryId,
          categoryName: categoryName,
          baseUrl: baseUrl,
        );
      } catch (e, stackTrace) {
        // Логируем ошибку, но не прерываем выполнение
        print('❌ [NewsController] Ошибка отправки Telegram уведомления о создании новости: $e');
        print('❌ [NewsController] Stack trace: $stackTrace');
      }

      // Добавляем дополнительные изображения в ответ
      final newsJson = finalNews.toJson();
      newsJson['additional_images'] = additionalImages;

      return Response.ok(jsonEncode(newsJson), headers: jsonContentHeaders);
    });
  }

  /// Загрузить изображение для новости
  @Route.post('/api/news/images/upload')
  @OpenApiRoute()
  Future<Response> uploadNewsImage(Request request) async {
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
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}), headers: jsonContentHeaders);
      }

      // Парсим multipart запрос
      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing boundary in Content-Type'}), headers: jsonContentHeaders);
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

        // Пропускаем \r\n после boundary
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (nextBoundaryIndex != -1) {
          final partBytes = bodyBytes.sublist(searchStart, nextBoundaryIndex);
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
      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isImageField = RegExp('name=["\']?image').hasMatch(contentDisposition);
        if (!isImageField) continue;

        final photoData = part['data'] as List<int>?;
        if (photoData == null || photoData.isEmpty) continue;

        // Валидация размера (максимум 10MB)
        if (photoData.length > 10 * 1024 * 1024) {
          return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 10MB limit'}), headers: jsonContentHeaders);
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

        // Сохраняем фото
        final publicDir = Directory('public');
        if (!await publicDir.exists()) {
          await publicDir.create(recursive: true);
        }

        final newsDir = Directory('public/news');
        if (!await newsDir.exists()) {
          await newsDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'image.$authorId.$timestamp.$random.$extension';
        final filePath = 'public/news/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(photoData);

        imageUrl = 'news/$fileName';
        break;
      }

      if (imageUrl == null) {
        return Response.badRequest(body: jsonEncode({'error': 'No image provided'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'url': imageUrl}), headers: jsonContentHeaders);
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

    return {'content-disposition': headers['content-disposition'], 'content-type': headers['content-type'], 'data': bodyBytes};
  }

  /// Обновить новость (требуется авторизация, только автор или админ)
  @Route.put('/api/news/<id>')
  @OpenApiRoute()
  Future<Response> updateNews(Request request) async {
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

      final currentUserId = int.parse(userId);
      final newsId = int.parse(request.params['id']!);

      // Получаем новость для проверки авторства
      final existingNews = await _newsRepository.getNewsById(newsId);
      final isAdmin = await _newsRepository.isAdmin(currentUserId);

      // Проверяем права доступа (только автор или админ могут редактировать)
      if (existingNews.author_id != currentUserId && !isAdmin) {
        return Response.forbidden(jsonEncode({'error': 'Forbidden: only author or admin can update news'}));
      }

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'];
      final isMultipart = contentType != null && contentType.startsWith('multipart/form-data');

      String? pictureMiniUrl;
      String? pictureBigUrl;
      Map<String, dynamic> newsData = {};

      // Храним изображения в памяти
      List<int>? pictureMiniBytes;
      List<int>? pictureBigBytes;
      String? pictureMiniExtension;
      String? pictureBigExtension;

      // Дополнительные изображения
      List<List<int>> additionalImageBytesList = [];
      List<String> additionalImageExtensions = [];

      // Список URL дополнительных изображений для удаления
      List<String>? imagesToDelete;

      if (isMultipart) {
        // Парсим multipart запрос (аналогично createNews)
        final mediaType = MediaType.parse(contentType);
        final boundary = mediaType.parameters['boundary'];
        if (boundary == null) {
          return Response.badRequest(body: jsonEncode({'error': 'Missing boundary in Content-Type'}), headers: jsonContentHeaders);
        }

        final bodyBytes = <int>[];
        await for (final chunk in request.read()) {
          bodyBytes.addAll(chunk);
        }

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
          if (nextBoundaryIndex != -1) {
            final partBytes = bodyBytes.sublist(searchStart, nextBoundaryIndex);
            final partData = _parseMultipartPart(partBytes);
            if (partData != null) {
              parts.add(partData);
            }
          }

          if (nextBoundaryIndex == -1) break;
          searchStart = nextBoundaryIndex;
        }

        // Обрабатываем части
        for (final part in parts) {
          final contentDisposition = part['content-disposition'] as String?;
          if (contentDisposition == null) continue;

          final nameMatch = RegExp('name=["\']?([^"\';]+)').firstMatch(contentDisposition);
          if (nameMatch == null) continue;

          final fieldName = nameMatch.group(1);
          if (fieldName == null) continue;
          final partData = part['data'] as List<int>?;
          if (partData == null) continue;

          if (fieldName == 'picture_mini' || fieldName == 'picture_big') {
            if (partData.isNotEmpty) {
              if (partData.length > 10 * 1024 * 1024) {
                return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 10MB limit'}), headers: jsonContentHeaders);
              }

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

              if (fieldName == 'picture_mini') {
                pictureMiniBytes = partData;
                pictureMiniExtension = extension;
              } else {
                pictureBigBytes = partData;
                pictureBigExtension = extension;
              }
            }
          } else if (fieldName == 'additional_images[]') {
            if (partData.isNotEmpty) {
              if (partData.length > 10 * 1024 * 1024) {
                return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 10MB limit'}), headers: jsonContentHeaders);
              }

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

              additionalImageBytesList.add(partData);
              additionalImageExtensions.add(extension);
            }
          } else if (fieldName == 'images_to_delete[]') {
            // Список URL изображений для удаления
            final url = utf8.decode(partData);
            if (imagesToDelete == null) {
              imagesToDelete = [];
            }
            imagesToDelete.add(url);
          } else {
            final value = utf8.decode(partData);
            newsData[fieldName] = value;
          }
        }
      } else {
        // Обычный JSON запрос
        final body = await request.readAsString();
        final jsonData = jsonDecode(body) as Map<String, dynamic>;
        newsData = jsonData;
        pictureMiniUrl = jsonData['picture_mini'] as String?;
        pictureBigUrl = jsonData['picture_big'] as String?;
        if (jsonData['images_to_delete'] != null) {
          imagesToDelete = List<String>.from(jsonData['images_to_delete']);
        }
      }

      // Удаляем указанные дополнительные изображения
      if (imagesToDelete != null && imagesToDelete.isNotEmpty) {
        await _newsRepository.deleteNewsImages(newsId: newsId, imageUrls: imagesToDelete);
      }

      // Подготавливаем данные для обновления
      String? finalTitle = newsData['title'] as String?;
      String? finalSubTitle = newsData['sub_title'] as String?;
      String? finalSource = newsData['source'] as String?;
      String? finalBody = newsData['body'] as String?;
      String? finalContent = newsData['content'] as String?;
      bool? finalIsBigNews = newsData['is_big_news'] != null ? (newsData['is_big_news'] == true || newsData['is_big_news'] == 'true') : null;
      int? finalCategoryId = newsData['category_id'] != null ? int.tryParse(newsData['category_id'].toString()) : null;
      bool? finalPublished = newsData['published'] != null ? (newsData['published'] == true || newsData['published'] == 'true') : null;

      // Если админ не меняет published, не передаем его (оставляем текущее значение)
      if (finalPublished != null && !isAdmin) {
        finalPublished = null; // Обычные пользователи не могут менять статус публикации
      }

      // Сохраняем изображения, если они были загружены
      String? finalPictureMiniPath;
      String? finalPictureBigPath;

      if (pictureBigBytes != null) {
        final newsIdDir = Directory('public/news/$newsId');
        if (!await newsIdDir.exists()) {
          await newsIdDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'big.$currentUserId.$timestamp.$random.${pictureBigExtension ?? 'jpg'}';
        final filePath = 'public/news/$newsId/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pictureBigBytes);
        finalPictureBigPath = 'news/$newsId/$fileName';
      } else if (pictureBigUrl != null && pictureBigUrl.isNotEmpty) {
        finalPictureBigPath = pictureBigUrl;
      } else if (newsData['delete_picture_big'] == 'true' || newsData['delete_picture_big'] == true) {
        // Если запрошено удаление фото обложки
        finalPictureBigPath = '';
      }

      if (pictureMiniBytes != null) {
        final newsIdDir = Directory('public/news/$newsId');
        if (!await newsIdDir.exists()) {
          await newsIdDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'mini.$currentUserId.$timestamp.$random.${pictureMiniExtension ?? 'jpg'}';
        final filePath = 'public/news/$newsId/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pictureMiniBytes);
        finalPictureMiniPath = 'news/$newsId/$fileName';
      } else if (pictureMiniUrl != null && pictureMiniUrl.isNotEmpty) {
        finalPictureMiniPath = pictureMiniUrl;
      } else if (finalPictureBigPath != null) {
        // Если обновлено большое изображение, используем его для миниатюры
        finalPictureMiniPath = finalPictureBigPath;
      }

      // Сохраняем дополнительные изображения
      if (additionalImageBytesList.isNotEmpty) {
        final newsIdDir = Directory('public/news/$newsId');
        if (!await newsIdDir.exists()) {
          await newsIdDir.create(recursive: true);
        }

        final List<String> additionalImageUrls = [];
        final List<String> additionalImagePaths = [];

        for (int i = 0; i < additionalImageBytesList.length; i++) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final random = DateTime.now().microsecondsSinceEpoch % 1000000;
          final extension = additionalImageExtensions[i];
          final fileName = 'additional.$currentUserId.$timestamp.$random.$i.$extension';
          final filePath = 'public/news/$newsId/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(additionalImageBytesList[i]);

          additionalImageUrls.add('news/$newsId/$fileName');
          additionalImagePaths.add(filePath);
        }

        await _newsRepository.saveNewsImages(
          newsId: newsId,
          imageUrls: additionalImageUrls,
          imagePaths: additionalImagePaths,
        );
      }

      // Обновляем новость в базе данных
      final updatedNews = await _newsRepository.updateNews(
        id: newsId,
        title: finalTitle,
        subTitle: finalSubTitle,
        source: finalSource,
        body: finalBody,
        content: finalContent,
        pictureMini: finalPictureMiniPath,
        pictureBig: finalPictureBigPath,
        isBigNews: finalIsBigNews,
        categoryId: finalCategoryId,
        published: finalPublished,
      );

      // Получаем дополнительные изображения
      final additionalImages = await _newsRepository.getNewsImages(newsId);

      // Формируем ответ
      final newsJson = updatedNews.toJson();
      newsJson['additional_images'] = additionalImages;

      return Response.ok(jsonEncode(newsJson), headers: jsonContentHeaders);
    });
  }

  /// Удалить новость (требуется авторизация, только автор или админ)
  @Route.delete('/api/news/<id>')
  @OpenApiRoute()
  Future<Response> deleteNews(Request request) async {
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

      final currentUserId = int.parse(userId);
      final newsId = int.parse(request.params['id']!);

      // Получаем новость для проверки авторства
      final existingNews = await _newsRepository.getNewsById(newsId);
      final isAdmin = await _newsRepository.isAdmin(currentUserId);

      // Проверяем права доступа (только автор или админ могут удалять)
      if (existingNews.author_id != currentUserId && !isAdmin) {
        return Response.forbidden(jsonEncode({'error': 'Forbidden: only author or admin can delete news'}));
      }

      // Удаляем новость
      await _newsRepository.deleteNews(newsId);

      return Response.ok(jsonEncode({'message': 'News deleted successfully'}), headers: jsonContentHeaders);
    });
  }
}
