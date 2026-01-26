import 'dart:convert';
import 'dart:io';
import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/market/repositories/market_repository.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http_parser/http_parser.dart';

part 'market_controller.g.dart';

class MarketController {
  final MarketRepository _repository;
  final TokenService _tokenService;

  MarketController({required MarketRepository repository, required TokenService tokenService})
      : _repository = repository,
        _tokenService = tokenService;

  Router get router => _$MarketControllerRouter(this);

  /// Получить основные категории по типу продукта
  @Route.get('/api/market/categories/main')
  @OpenApiRoute()
  Future<Response> getMainCategories(Request request) async {
    return wrapResponse(() async {
      final productType = request.url.queryParameters['product_type'] ?? 'aircraft';
      if (productType != 'aircraft' && productType != 'parts') {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product_type. Must be "aircraft" or "parts"'}), headers: jsonContentHeaders);
      }

      final categories = await _repository.getMainCategories(productType);
      return Response.ok(jsonEncode(categories.map((c) => c.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить все категории по типу продукта
  @Route.get('/api/market/categories')
  @OpenApiRoute()
  Future<Response> getAllCategories(Request request) async {
    return wrapResponse(() async {
      final productType = request.url.queryParameters['product_type'] ?? 'aircraft';
      if (productType != 'aircraft' && productType != 'parts') {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product_type. Must be "aircraft" or "parts"'}), headers: jsonContentHeaders);
      }

      final categories = await _repository.getAllCategories(productType);
      return Response.ok(jsonEncode(categories.map((c) => c.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить категорию по ID
  @Route.get('/api/market/categories/<id>')
  @OpenApiRoute()
  Future<Response> getCategoryById(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Category ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid category ID'}), headers: jsonContentHeaders);
      }

      final category = await _repository.getCategoryById(id);
      if (category == null) {
        return Response.notFound(jsonEncode({'error': 'Category not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(category.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Получить список продуктов с фильтрами
  @Route.get('/api/market/aircraft')
  @OpenApiRoute()
  Future<Response> getProducts(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;

      // Получаем ID пользователя из токена, если авторизован
      int? userId;
      try {
        final authHeader = request.headers['Authorization'];
        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          final token = authHeader.substring(7);
          if (_tokenService.validateToken(token)) {
            final userIdStr = _tokenService.getUserIdFromToken(token);
            if (userIdStr != null && userIdStr.isNotEmpty) {
              userId = int.tryParse(userIdStr);
            }
          }
        }
      } catch (e) {
        // Игнорируем ошибки авторизации - пользователь может быть не авторизован
      }

      // aircraft_subcategories_id (заменяет category_id)
      final aircraftSubcategoriesId = params['aircraft_subcategories_id'] != null ? int.tryParse(params['aircraft_subcategories_id']!) : null;
      final sellerId = params['seller_id'] != null ? int.tryParse(params['seller_id']!) : null;
      final searchQuery = params['search'];
      final priceFrom = params['price_from'] != null ? int.tryParse(params['price_from']!) : null;
      final priceTo = params['price_to'] != null ? int.tryParse(params['price_to']!) : null;
      final brand = params['brand'];
      final sortBy = params['sort_by'] ?? 'default'; // 'default', 'date', 'price_asc', 'price_desc'
      final limit = params['limit'] != null ? int.tryParse(params['limit']!) ?? 20 : 20;
      final offset = params['offset'] != null ? int.tryParse(params['offset']!) ?? 0 : 0;
      final includeInactiveParam = params['include_inactive'] == 'true';
      final includeInactive = includeInactiveParam && userId != null && sellerId != null && userId == sellerId;

      // Парсим список категорий (если переданы через запятую)
      List<int>? categoryIds;
      if (params['aircraft_subcategories_ids'] != null) {
        categoryIds = params['aircraft_subcategories_ids']!.split(',').map((e) => int.tryParse(e.trim())).where((e) => e != null).cast<int>().toList();
        if (categoryIds.isEmpty) categoryIds = null;
      }

      final products = await _repository.getAircraft(
        productType: 'aircraft', // Всегда 'aircraft', тип определяется через aircraft_subcategories_id
        categoryId: aircraftSubcategoriesId,
        categoryIds: categoryIds,
        sellerId: sellerId,
        searchQuery: searchQuery,
        priceFrom: priceFrom,
        priceTo: priceTo,
        brand: brand,
        sortBy: sortBy,
        userId: userId,
        includeInactive: includeInactive,
        limit: limit,
        offset: offset,
      );

      return Response.ok(jsonEncode(products.map((p) => p.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить продукт по ID
  @Route.get('/api/market/aircraft/<id>')
  @OpenApiRoute()
  Future<Response> getProductById(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      // Получаем ID пользователя из токена, если авторизован
      int? userId;
      try {
        final authHeader = request.headers['Authorization'];
        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          final token = authHeader.substring(7);
          if (_tokenService.validateToken(token)) {
            final userIdStr = _tokenService.getUserIdFromToken(token);
            if (userIdStr != null && userIdStr.isNotEmpty) {
              userId = int.tryParse(userIdStr);
            }
          }
        }
      } catch (e) {
        // Игнорируем ошибки авторизации
      }

      final product = await _repository.getAircraftById(id, userId: userId);
      if (product == null) {
        return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
      }

      // Увеличиваем счетчик просмотров
      _repository.incrementViews(id).catchError((e) {
        // Игнорируем ошибки при увеличении просмотров
      });

      return Response.ok(jsonEncode(product.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Получить историю цен для объявления
  @Route.get('/api/market/aircraft/<id>/price-history')
  @OpenApiRoute()
  Future<Response> getPriceHistory(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      final priceHistory = await _repository.getPriceHistory(id);
      return Response.ok(jsonEncode(priceHistory.map((h) => h.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Создать объявление о самолёте (требуется авторизация)
  @Route.post('/api/market/aircraft')
  @OpenApiRoute()
  Future<Response> createAircraft(Request request) async {
    return wrapResponse(() async {
      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'] ?? '';
      final isMultipart = contentType.startsWith('multipart/form-data');

      Map<String, dynamic> body = {};
      String? mainImageUrl;
      List<String> additionalImageUrls = [];
      String? mainImageTempPath;
      final additionalImagesTempPaths = <String>[];

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

        // Сохраняем файлы во временную директорию
        final tempDir = Directory('public/market/aircraft/temp');
        if (!await tempDir.exists()) {
          await tempDir.create(recursive: true);
        }

        for (final part in parts) {
          final contentDisposition = part['content-disposition'] as String?;
          if (contentDisposition == null) continue;

          // Извлекаем имя поля
          final nameMatch = RegExp('name=["\']?([^"\';\\s]+)').firstMatch(contentDisposition);
          if (nameMatch == null) continue;
          final fieldName = nameMatch.group(1);
          if (fieldName == null) continue;

          // Обрабатываем текстовые поля
          if (fieldName != 'main_image' && fieldName != 'additional_images') {
            final fieldData = part['data'] as List<int>?;
            if (fieldData != null && fieldData.isNotEmpty) {
              final fieldValue = utf8.decode(fieldData);
              if (fieldName.endsWith('[]')) {
                final arrayName = fieldName.substring(0, fieldName.length - 2);
                if (body[arrayName] == null) {
                  body[arrayName] = <String>[];
                }
                (body[arrayName] as List).add(fieldValue);
              } else {
                body[fieldName] = fieldValue;
              }
            }
            continue;
          }

          // Обрабатываем изображения
          final imageData = part['data'] as List<int>?;
          if (imageData != null && imageData.isNotEmpty) {
            // Валидация размера (максимум 5MB)
            if (imageData.length > 5 * 1024 * 1024) {
              continue; // Пропускаем слишком большие файлы
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

            // Сохраняем во временную директорию
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final random = DateTime.now().microsecondsSinceEpoch % 1000000;
            final fileName = '$fieldName.$timestamp.$random.$extension';
            final filePath = 'public/market/aircraft/temp/$fileName';
            final file = File(filePath);
            await file.writeAsBytes(imageData);

            if (fieldName == 'main_image') {
              mainImageTempPath = filePath;
            } else if (fieldName == 'additional_images') {
              additionalImagesTempPaths.add(filePath);
            }
          }
        }
      } else {
        // Обычный JSON запрос
        final bodyStr = await request.readAsString();
        if (bodyStr.isEmpty) {
          return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
        }
        body = jsonDecode(bodyStr) as Map<String, dynamic>;
      }

      // Валидация обязательных полей
      if (body['title'] == null || (body['title'] as String).isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Title is required'}), headers: jsonContentHeaders);
      }
      if (body['price'] == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Price is required'}), headers: jsonContentHeaders);
      }

      // Создаем продукт в БД (без изображений пока)
      final product = await _repository.createAircraft(
        sellerId: userId,
        title: body['title'] as String,
        description: body['description'] as String?,
        price: body['price'] is String ? int.parse(body['price'] as String) : (body['price'] as num).toInt(),
        aircraftSubcategoriesId: body['aircraft_subcategories_id'] != null
            ? (body['aircraft_subcategories_id'] is String ? int.tryParse(body['aircraft_subcategories_id'] as String) : (body['aircraft_subcategories_id'] as num).toInt())
            : null,
        mainImageUrl: null, // Будет обновлено после сохранения файлов
        additionalImageUrls: const [],
        brand: body['brand'] as String?,
        location: body['location'] as String?,
        year: body['year'] != null ? (body['year'] is String ? int.tryParse(body['year'] as String) : (body['year'] as num).toInt()) : null,
        totalFlightHours:
            body['total_flight_hours'] != null ? (body['total_flight_hours'] is String ? int.tryParse(body['total_flight_hours'] as String) : (body['total_flight_hours'] as num).toInt()) : null,
        enginePower: body['engine_power'] != null ? (body['engine_power'] is String ? int.tryParse(body['engine_power'] as String) : (body['engine_power'] as num).toInt()) : null,
        engineVolume: body['engine_volume'] != null ? (body['engine_volume'] is String ? int.tryParse(body['engine_volume'] as String) : (body['engine_volume'] as num).toInt()) : null,
        seats: body['seats'] != null ? (body['seats'] is String ? int.tryParse(body['seats'] as String) : (body['seats'] as num).toInt()) : null,
        condition: body['condition'] as String?,
        isShareSale: body['is_share_sale'] != null ? (body['is_share_sale'] is String ? body['is_share_sale'] == 'true' : body['is_share_sale'] as bool) : null,
        shareNumerator: body['share_numerator'] != null ? (body['share_numerator'] is String ? int.tryParse(body['share_numerator'] as String) : (body['share_numerator'] as num).toInt()) : null,
        shareDenominator:
            body['share_denominator'] != null ? (body['share_denominator'] is String ? int.tryParse(body['share_denominator'] as String) : (body['share_denominator'] as num).toInt()) : null,
        isLeasing: body['is_leasing'] != null ? (body['is_leasing'] is String ? body['is_leasing'] == 'true' : body['is_leasing'] as bool) : null,
        leasingConditions: body['leasing_conditions'] as String?,
      );

      final productId = product.id;

      // Создаем директорию для изображений товара
      final productDir = Directory('public/market/aircraft/$productId');
      if (!await productDir.exists()) {
        await productDir.create(recursive: true);
      }

      // Перемещаем файлы из временной директории в директорию продукта
      if (isMultipart) {
        // Основное изображение
        if (mainImageTempPath != null) {
          final tempFile = File(mainImageTempPath);
          if (await tempFile.exists()) {
            final fileName = mainImageTempPath.split('/').last;
            final newPath = 'public/market/aircraft/$productId/$fileName';
            await tempFile.copy(newPath);
            await tempFile.delete();
            mainImageUrl = 'market/aircraft/$productId/$fileName';
          }
        }

        // Дополнительные изображения
        for (final tempPath in additionalImagesTempPaths) {
          final tempFile = File(tempPath);
          if (await tempFile.exists()) {
            final fileName = tempPath.split('/').last;
            final newPath = 'public/market/aircraft/$productId/$fileName';
            await tempFile.copy(newPath);
            await tempFile.delete();
            additionalImageUrls.add('market/aircraft/$productId/$fileName');
          }
        }

        // Обновляем продукт с путями к изображениям
        if (mainImageUrl != null || additionalImageUrls.isNotEmpty) {
          await _repository.updateAircraft(
            productId: productId,
            sellerId: userId,
            mainImageUrl: mainImageUrl,
            additionalImageUrls: additionalImageUrls,
          );
        }
      }

      // Получаем обновленный продукт
      final createdProduct = await _repository.getAircraftById(productId, userId: userId);
      if (createdProduct == null) {
        return Response.internalServerError(body: jsonEncode({'error': 'Failed to create product'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(createdProduct.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Добавить продукт в избранное (требуется авторизация)
  @Route.post('/api/market/aircraft/<id>/favorite')
  @OpenApiRoute()
  Future<Response> addToFavorites(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      await _repository.addToFavorites(userId, id);
      return Response.ok(jsonEncode({'success': true}), headers: jsonContentHeaders);
    });
  }

  /// Удалить продукт из избранного (требуется авторизация)
  @Route.delete('/api/market/aircraft/<id>/favorite')
  @OpenApiRoute()
  Future<Response> removeFromFavorites(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      await _repository.removeFromFavorites(userId, id);
      return Response.ok(jsonEncode({'success': true}), headers: jsonContentHeaders);
    });
  }

  /// Получить избранные продукты пользователя (требуется авторизация)
  @Route.get('/api/market/favorites')
  @OpenApiRoute()
  Future<Response> getFavorites(Request request) async {
    return wrapResponse(() async {
      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      final params = request.url.queryParameters;
      final productType = params['product_type'];
      final limit = params['limit'] != null ? int.tryParse(params['limit']!) ?? 20 : 20;
      final offset = params['offset'] != null ? int.tryParse(params['offset']!) ?? 0 : 0;

      final products = await _repository.getFavoriteAircraft(userId, productType: productType, limit: limit, offset: offset);

      return Response.ok(jsonEncode(products.map((p) => p.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Обновить товар (только владелец)
  @Route.put('/api/market/aircraft/<id>')
  @OpenApiRoute()
  Future<Response> updateProduct(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      // Проверяем права доступа (владелец или администратор)
      final product = await _repository.getAircraftById(id, userId: userId);
      if (product == null) {
        return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
      }

      final isOwner = product.sellerId == userId;
      if (!isOwner) {
        // Проверяем, является ли пользователь администратором
        final profileRepository = await getIt.getAsync<ProfileRepository>();
        final isAdmin = await profileRepository.isAdmin(userId);
        if (!isAdmin) {
          return Response.forbidden(jsonEncode({'error': 'You do not have permission to update this product'}), headers: jsonContentHeaders);
        }
      }

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'] ?? '';
      final isMultipart = contentType.startsWith('multipart/form-data');

      Map<String, dynamic> body = {};
      String? mainImageUrl;
      List<String>? additionalImageUrls;

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

        // Создаем директорию для изображений товара
        final publicDir = Directory('public');
        if (!await publicDir.exists()) {
          await publicDir.create(recursive: true);
        }

        final marketDir = Directory('public/market');
        if (!await marketDir.exists()) {
          await marketDir.create(recursive: true);
        }

        final productsDir = Directory('public/market/aircraft');
        if (!await productsDir.exists()) {
          await productsDir.create(recursive: true);
        }

        final productDir = Directory('public/market/aircraft/$id');
        if (!await productDir.exists()) {
          await productDir.create(recursive: true);
        }

        // Обрабатываем части multipart
        final additionalImageUrlsList = <String>[];

        for (final part in parts) {
          final contentDisposition = part['content-disposition'] as String?;
          if (contentDisposition == null) continue;

          // Извлекаем имя поля
          final nameMatch = RegExp('name=["\']?([^"\';\\s]+)').firstMatch(contentDisposition);
          if (nameMatch == null) continue;
          final fieldName = nameMatch.group(1);
          if (fieldName == null) continue;

          // Обрабатываем текстовые поля
          if (fieldName != 'main_image' && fieldName != 'additional_images') {
            final fieldData = part['data'] as List<int>?;
            if (fieldData != null && fieldData.isNotEmpty) {
              final fieldValue = utf8.decode(fieldData);
              // Обрабатываем массивы (например, additional_image_urls[])
              if (fieldName.endsWith('[]')) {
                final arrayName = fieldName.substring(0, fieldName.length - 2);
                if (body[arrayName] == null) {
                  body[arrayName] = <String>[];
                }
                (body[arrayName] as List).add(fieldValue);
              } else {
                body[fieldName] = fieldValue;
              }
            }
            continue;
          }

          // Обрабатываем основное изображение
          if (fieldName == 'main_image') {
            final imageData = part['data'] as List<int>?;
            if (imageData != null && imageData.isNotEmpty) {
              // Валидация размера (максимум 5MB)
              if (imageData.length > 5 * 1024 * 1024) {
                return Response.badRequest(body: jsonEncode({'error': 'Main image file size exceeds 5MB limit'}), headers: jsonContentHeaders);
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
              final fileName = 'main.$timestamp.$random.$extension';
              final filePath = 'public/market/aircraft/$id/$fileName';
              final file = File(filePath);
              await file.writeAsBytes(imageData);

              mainImageUrl = 'market/aircraft/$id/$fileName';
            }
            continue;
          }

          // Обрабатываем дополнительные изображения
          if (fieldName == 'additional_images') {
            final imageData = part['data'] as List<int>?;
            if (imageData != null && imageData.isNotEmpty) {
              // Валидация размера (максимум 5MB)
              if (imageData.length > 5 * 1024 * 1024) {
                continue; // Пропускаем слишком большие файлы
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
              final fileName = 'additional.$timestamp.$random.$extension';
              final filePath = 'public/market/aircraft/$id/$fileName';
              final file = File(filePath);
              await file.writeAsBytes(imageData);

              additionalImageUrlsList.add('market/aircraft/$id/$fileName');
            }
            continue;
          }
        }

        // Если mainImageUrl не был установлен из файла, но есть в body, используем его
        // Если был загружен новый файл - mainImageUrl уже установлен, не перезаписываем
        if (mainImageUrl == null && body.containsKey('main_image_url')) {
          final bodyMainImageUrl = body['main_image_url'] as String?;
          // Используем URL из body только если файл не был загружен
          mainImageUrl = bodyMainImageUrl;
        }

        // Обрабатываем дополнительные изображения
        if (additionalImageUrlsList.isNotEmpty) {
          // Если пришли новые файлы - объединяем с существующими из body
          final existingUrls = body['additional_image_urls'] != null ? (body['additional_image_urls'] is List ? List<String>.from(body['additional_image_urls'] as List) : []) : [];
          additionalImageUrls = [...existingUrls, ...additionalImageUrlsList];
        } else if (body.containsKey('additional_image_urls')) {
          // Если поле передано явно, используем его (может быть пустой список '[]')
          if (body['additional_image_urls'] is List) {
            additionalImageUrls = List<String>.from(body['additional_image_urls'] as List);
          } else if (body['additional_image_urls'] is String && body['additional_image_urls'] == '[]') {
            // Если передана строка '[]', значит нужно удалить все
            additionalImageUrls = [];
          } else {
            additionalImageUrls = [];
          }
        } else {
          // Если ничего не передано, сохраняем существующие
          additionalImageUrls = product.additionalImageUrls;
        }
      } else {
        // Обычный JSON запрос
        final bodyStr = await request.readAsString();
        if (bodyStr.isEmpty) {
          return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
        }

        body = jsonDecode(bodyStr) as Map<String, dynamic>;
        mainImageUrl = body['main_image_url'] as String?;
        additionalImageUrls = body['additional_image_urls'] != null ? List<String>.from(body['additional_image_urls'] as List) : null;
      }

      try {
        final updatedProduct = await _repository.updateAircraft(
          productId: id,
          sellerId: userId,
          title: body['title'] as String?,
          description: body['description'] as String?,
          price: body['price'] != null ? (body['price'] is String ? int.tryParse(body['price'] as String) : (body['price'] as num).toInt()) : null,
          aircraftSubcategoriesId: body['aircraft_subcategories_id'] != null
              ? (body['aircraft_subcategories_id'] is String ? int.tryParse(body['aircraft_subcategories_id'] as String) : (body['aircraft_subcategories_id'] as num).toInt())
              : null,
          mainImageUrl: mainImageUrl,
          additionalImageUrls: additionalImageUrls,
          brand: body['brand'] as String?,
          location: body['location'] as String?,
          year: body['year'] != null ? (body['year'] is String ? int.tryParse(body['year'] as String) : (body['year'] as num).toInt()) : null,
          totalFlightHours:
              body['total_flight_hours'] != null ? (body['total_flight_hours'] is String ? int.tryParse(body['total_flight_hours'] as String) : (body['total_flight_hours'] as num).toInt()) : null,
          enginePower: body['engine_power'] != null ? (body['engine_power'] is String ? int.tryParse(body['engine_power'] as String) : (body['engine_power'] as num).toInt()) : null,
          engineVolume: body['engine_volume'] != null ? (body['engine_volume'] is String ? int.tryParse(body['engine_volume'] as String) : (body['engine_volume'] as num).toInt()) : null,
          seats: body['seats'] != null ? (body['seats'] is String ? int.tryParse(body['seats'] as String) : (body['seats'] as num).toInt()) : null,
          condition: body['condition'] as String?,
          isShareSale: body['is_share_sale'] != null ? (body['is_share_sale'] is String ? body['is_share_sale'] == 'true' : body['is_share_sale'] as bool) : null,
          shareNumerator: body['share_numerator'] != null ? (body['share_numerator'] is String ? int.tryParse(body['share_numerator'] as String) : (body['share_numerator'] as num).toInt()) : null,
          shareDenominator:
              body['share_denominator'] != null ? (body['share_denominator'] is String ? int.tryParse(body['share_denominator'] as String) : (body['share_denominator'] as num).toInt()) : null,
          isLeasing: body['is_leasing'] != null ? (body['is_leasing'] is String ? body['is_leasing'] == 'true' : body['is_leasing'] as bool) : null,
          leasingConditions: body['leasing_conditions'] as String?,
        );

        if (updatedProduct == null) {
          return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
        }

        return Response.ok(jsonEncode(updatedProduct.toJson()), headers: jsonContentHeaders);
      } catch (e) {
        if (e.toString().contains('permission')) {
          return Response.forbidden(jsonEncode({'error': 'You do not have permission to update this product'}), headers: jsonContentHeaders);
        }
        rethrow;
      }
    });
  }

  /// Опубликовать объявление заново (только владелец)
  @Route.post('/api/market/aircraft/<id>/publish')
  @OpenApiRoute()
  Future<Response> publishProduct(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      try {
        final product = await _repository.publishAircraft(productId: id, sellerId: userId);
        if (product == null) {
          return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
        }

        return Response.ok(jsonEncode(product.toJson()), headers: jsonContentHeaders);
      } catch (e) {
        if (e.toString().contains('permission')) {
          return Response.forbidden(jsonEncode({'error': 'You do not have permission to publish this product'}), headers: jsonContentHeaders);
        }
        rethrow;
      }
    });
  }

  /// Снять объявление с публикации (только владелец)
  @Route.post('/api/market/aircraft/<id>/unpublish')
  @OpenApiRoute()
  Future<Response> unpublishProduct(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      try {
        final product = await _repository.unpublishAircraft(productId: id, sellerId: userId);
        if (product == null) {
          return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
        }

        return Response.ok(jsonEncode(product.toJson()), headers: jsonContentHeaders);
      } catch (e) {
        if (e.toString().contains('permission')) {
          return Response.forbidden(jsonEncode({'error': 'You do not have permission to unpublish this product'}), headers: jsonContentHeaders);
        }
        rethrow;
      }
    });
  }

  /// Удалить товар (только владелец)
  @Route.delete('/api/market/aircraft/<id>')
  @OpenApiRoute()
  Future<Response> deleteProduct(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      try {
        final deleted = await _repository.deleteAircraft(id, userId);
        if (!deleted) {
          return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
        }

        return Response.ok(jsonEncode({'message': 'Product deleted successfully'}), headers: jsonContentHeaders);
      } catch (e) {
        if (e.toString().contains('permission')) {
          return Response.forbidden(jsonEncode({'error': 'You do not have permission to delete this product'}), headers: jsonContentHeaders);
        }
        rethrow;
      }
    });
  }

  /// Загрузить основную фотографию товара (только владелец)
  @Route.post('/api/market/products/<id>/main-image')
  @OpenApiRoute()
  Future<Response> uploadMainImage(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      // Проверяем права доступа (владелец или администратор)
      final product = await _repository.getAircraftById(id, userId: userId);
      if (product == null) {
        return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
      }

      final isOwner = product.sellerId == userId;
      if (!isOwner) {
        // Проверяем, является ли пользователь администратором
        final profileRepository = await getIt.getAsync<ProfileRepository>();
        final isAdmin = await profileRepository.isAdmin(userId);
        if (!isAdmin) {
          return Response.forbidden(jsonEncode({'error': 'You do not have permission to upload images for this product'}), headers: jsonContentHeaders);
        }
      }

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

      final marketDir = Directory('public/market');
      if (!await marketDir.exists()) {
        await marketDir.create(recursive: true);
      }

      final productsDir = Directory('public/market/aircraft');
      if (!await productsDir.exists()) {
        await productsDir.create(recursive: true);
      }

      final productDir = Directory('public/market/aircraft/$id');
      if (!await productDir.exists()) {
        await productDir.create(recursive: true);
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
          return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 5MB limit'}), headers: jsonContentHeaders);
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
        final fileName = 'main.$timestamp.$random.$extension';
        final filePath = 'public/market/aircraft/$id/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(imageData);

        imageUrl = 'market/aircraft/$id/$fileName';
        break; // Обрабатываем только первое изображение
      }

      if (imageUrl == null) {
        return Response.badRequest(body: jsonEncode({'error': 'No image provided'}), headers: jsonContentHeaders);
      }

      // Обновляем товар с новым URL основной фотографии
      final updatedProduct = await _repository.updateAircraft(productId: id, sellerId: userId, mainImageUrl: imageUrl);

      if (updatedProduct == null) {
        return Response.internalServerError(body: jsonEncode({'error': 'Failed to update product'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'url': imageUrl}), headers: jsonContentHeaders);
    });
  }

  /// Загрузить дополнительные фотографии товара (только владелец)
  @Route.post('/api/market/products/<id>/additional-images')
  @OpenApiRoute()
  Future<Response> uploadAdditionalImages(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      // Проверяем авторизацию
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final token = authHeader.substring(7);
      if (!_tokenService.validateToken(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token'}), headers: jsonContentHeaders);
      }

      final userIdStr = _tokenService.getUserIdFromToken(token);
      if (userIdStr == null || userIdStr.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}), headers: jsonContentHeaders);
      }

      final userId = int.parse(userIdStr);

      // Проверяем права доступа (владелец или администратор)
      final product = await _repository.getAircraftById(id, userId: userId);
      if (product == null) {
        return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
      }

      final isOwner = product.sellerId == userId;
      if (!isOwner) {
        // Проверяем, является ли пользователь администратором
        final profileRepository = await getIt.getAsync<ProfileRepository>();
        final isAdmin = await profileRepository.isAdmin(userId);
        if (!isAdmin) {
          return Response.forbidden(jsonEncode({'error': 'You do not have permission to upload images for this product'}), headers: jsonContentHeaders);
        }
      }

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

      // Ищем все изображения
      final imageUrls = <String>[];
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final marketDir = Directory('public/market');
      if (!await marketDir.exists()) {
        await marketDir.create(recursive: true);
      }

      final productsDir = Directory('public/market/aircraft');
      if (!await productsDir.exists()) {
        await productsDir.create(recursive: true);
      }

      final productDir = Directory('public/market/aircraft/$id');
      if (!await productDir.exists()) {
        await productDir.create(recursive: true);
      }

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isImageField = RegExp('name=["\']?images').hasMatch(contentDisposition);
        if (!isImageField) continue;

        final imageData = part['data'] as List<int>?;
        if (imageData == null || imageData.isEmpty) continue;

        // Валидация размера (максимум 5MB)
        if (imageData.length > 5 * 1024 * 1024) {
          continue; // Пропускаем слишком большие файлы
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
        final fileName = 'additional.$timestamp.$random.$extension';
        final filePath = 'public/market/aircraft/$id/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(imageData);

        imageUrls.add('market/aircraft/$id/$fileName');
      }

      if (imageUrls.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'No images provided'}), headers: jsonContentHeaders);
      }

      // Получаем текущий список дополнительных изображений
      final currentProduct = await _repository.getAircraftById(id, userId: userId);
      final currentAdditionalImages = currentProduct?.additionalImageUrls ?? [];

      // Добавляем новые изображения к существующим
      final updatedAdditionalImages = [...currentAdditionalImages, ...imageUrls];

      // Обновляем товар с новым списком дополнительных фотографий
      final updatedProduct = await _repository.updateAircraft(productId: id, sellerId: userId, additionalImageUrls: updatedAdditionalImages);

      if (updatedProduct == null) {
        return Response.internalServerError(body: jsonEncode({'error': 'Failed to update product'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'urls': imageUrls}), headers: jsonContentHeaders);
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
}
