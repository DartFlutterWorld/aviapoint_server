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

  /// Получить историю цен для запчасти
  @Route.get('/api/market/parts/<id>/price-history')
  @OpenApiRoute()
  Future<Response> getPartPriceHistory(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      final priceHistory = await _repository.getPartPriceHistory(id);
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
        currency: (body['currency'] as String?) ?? 'RUB',
        aircraftSubcategoriesId: body['aircraft_subcategories_id'] != null
            ? (body['aircraft_subcategories_id'] is String ? int.tryParse(body['aircraft_subcategories_id'] as String) : (body['aircraft_subcategories_id'] as num).toInt())
            : null,
        mainImageUrl: null, // Будет обновлено после сохранения файлов
        additionalImageUrls: const [],
        brand: body['brand'] as String?,
        location: body['location'] as String?,
        address: body['address'] as Map<String, dynamic>?,
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
        isPublished: body['is_published'] != null ? (body['is_published'] is bool ? body['is_published'] as bool : body['is_published'].toString().toLowerCase() == 'true') : true,
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
          currency: body['currency'] as String?,
          aircraftSubcategoriesId: body['aircraft_subcategories_id'] != null
              ? (body['aircraft_subcategories_id'] is String ? int.tryParse(body['aircraft_subcategories_id'] as String) : (body['aircraft_subcategories_id'] as num).toInt())
              : null,
          mainImageUrl: mainImageUrl,
          additionalImageUrls: additionalImageUrls,
          brand: body['brand'] as String?,
          location: body['location'] as String?,
          address: body['address'] as Map<String, dynamic>?,
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

  /// Деактивировать объявление о самолете (только для админа - блокирует публикацию)
  @Route.post('/api/market/aircraft/<id>/deactivate')
  @OpenApiRoute()
  Future<Response> deactivateAircraft(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      // Проверяем, что пользователь - админ
      final profileRepository = await getIt.getAsync<ProfileRepository>();
      final isAdmin = await profileRepository.isAdmin(userId);
      if (!isAdmin) {
        return Response.forbidden(jsonEncode({'error': 'Only admins can deactivate aircraft'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      final product = await _repository.deactivateAircraft(productId: id);
      if (product == null) {
        return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(product.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Активировать объявление о самолете (только для админа - разблокирует публикацию)
  @Route.post('/api/market/aircraft/<id>/activate')
  @OpenApiRoute()
  Future<Response> activateAircraft(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      // Проверяем, что пользователь - админ
      final profileRepository = await getIt.getAsync<ProfileRepository>();
      final isAdmin = await profileRepository.isAdmin(userId);
      if (!isAdmin) {
        return Response.forbidden(jsonEncode({'error': 'Only admins can activate aircraft'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Product ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid product ID'}), headers: jsonContentHeaders);
      }

      final product = await _repository.activateAircraft(productId: id);
      if (product == null) {
        return Response.notFound(jsonEncode({'error': 'Product not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(product.toJson()), headers: jsonContentHeaders);
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

  // ============================================
  // API ДЛЯ КАТЕГОРИЙ ЗАПЧАСТЕЙ (ДВУХЭТАПНЫЙ ВЫБОР)
  // ============================================

  /// Получить основные категории запчастей (типы техники)
  @Route.get('/api/market/parts/main-categories')
  @OpenApiRoute()
  Future<Response> getPartsMainCategories(Request request) async {
    return wrapResponse(() async {
      final categories = await _repository.getPartsMainCategories();
      return Response.ok(jsonEncode(categories.map((c) => c.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить подкатегории запчастей по основной категории
  @Route.get('/api/market/parts/subcategories')
  @OpenApiRoute()
  Future<Response> getPartsSubcategories(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;
      final mainCategoryId = params['main_category_id'] != null ? int.tryParse(params['main_category_id']!) : null;
      final parentId = params['parent_id'] != null ? int.tryParse(params['parent_id']!) : null;

      List categories;
      if (parentId != null) {
        categories = await _repository.getPartsSubcategoriesByParent(parentId);
      } else if (mainCategoryId != null) {
        categories = await _repository.getPartsSubcategoriesByMainCategory(mainCategoryId);
      } else {
        return Response.badRequest(
          body: jsonEncode({'error': 'Either main_category_id or parent_id is required'}),
          headers: jsonContentHeaders,
        );
      }

      return Response.ok(jsonEncode(categories.map((c) => c.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить список производителей запчастей
  @Route.get('/api/market/parts/manufacturers')
  @OpenApiRoute()
  Future<Response> getPartsManufacturers(Request request) async {
    return wrapResponse(() async {
      final search = request.url.queryParameters['search'];
      final manufacturers = await _repository.getPartsManufacturers(search: search);
      return Response.ok(jsonEncode(manufacturers), headers: jsonContentHeaders);
    });
  }

  // ============================================
  // API ДЛЯ ОБЪЯВЛЕНИЙ О ЗАПЧАСТЯХ
  // ============================================

  /// Получить список объявлений о запчастях
  @Route.get('/api/market/parts')
  @OpenApiRoute()
  Future<Response> getParts(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;

      // Получаем ID пользователя из токена
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

      final mainCategoryId = params['main_category_id'] != null ? int.tryParse(params['main_category_id']!) : null;
      final subcategoryId = params['subcategory_id'] != null ? int.tryParse(params['subcategory_id']!) : null;
      final sellerId = params['seller_id'] != null ? int.tryParse(params['seller_id']!) : null;
      final manufacturerId = params['manufacturer_id'] != null ? int.tryParse(params['manufacturer_id']!) : null;
      final searchQuery = params['search'];
      final condition = params['condition'];
      final priceFrom = params['price_from'] != null ? int.tryParse(params['price_from']!) : null;
      final priceTo = params['price_to'] != null ? int.tryParse(params['price_to']!) : null;
      final sortBy = params['sort_by'] ?? 'default';
      final limit = params['limit'] != null ? int.tryParse(params['limit']!) ?? 20 : 20;
      final offset = params['offset'] != null ? int.tryParse(params['offset']!) ?? 0 : 0;
      final includeInactiveParam = params['include_inactive'] == 'true';
      final includeInactive = includeInactiveParam && userId != null && sellerId != null && userId == sellerId;

      final parts = await _repository.getParts(
        mainCategoryId: mainCategoryId,
        subcategoryId: subcategoryId,
        sellerId: sellerId,
        manufacturerId: manufacturerId,
        searchQuery: searchQuery,
        condition: condition,
        priceFrom: priceFrom,
        priceTo: priceTo,
        sortBy: sortBy,
        userId: userId,
        includeInactive: includeInactive,
        limit: limit,
        offset: offset,
      );

      // Логирование для отладки
      // print('🔵 [getParts] Найдено запчастей: ${parts.length}, includeInactive: $includeInactive, userId: $userId, sellerId: $sellerId');
      // if (parts.isEmpty) {
      //   print('⚠️ [getParts] Список пуст! Фильтры: mainCategoryId=$mainCategoryId, subcategoryId=$subcategoryId, searchQuery=$searchQuery');
      // }

      return Response.ok(jsonEncode(parts.map((p) => p.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить объявление о запчасти по ID
  @Route.get('/api/market/parts/<id>')
  @OpenApiRoute()
  Future<Response> getPartById(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      // Получаем ID пользователя из токена
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

      final part = await _repository.getPartById(id, userId: userId);
      if (part == null) {
        return Response.notFound(jsonEncode({'error': 'Part not found'}), headers: jsonContentHeaders);
      }

      // Увеличиваем счетчик просмотров
      await _repository.incrementPartViews(id);

      return Response.ok(jsonEncode(part.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Создать объявление о запчасти
  @Route.post('/api/market/parts')
  @OpenApiRoute()
  Future<Response> createPart(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

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
        final tempDir = Directory('public/market/parts/temp');
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
            final filePath = 'public/market/parts/temp/$fileName';
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

      final title = body['title'] as String?;
      if (title == null || title.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Title is required'}), headers: jsonContentHeaders);
      }

      final price = body['price'];
      if (price == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Price is required'}), headers: jsonContentHeaders);
      }
      final priceInt = price is int ? price : (price is num ? price.toInt() : int.tryParse(price.toString()));

      if (priceInt == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid price'}), headers: jsonContentHeaders);
      }

      // Парсим совместимые модели самолетов
      List<int>? compatibleAircraftModelIds;
      if (body['compatible_aircraft_model_ids'] != null) {
        if (body['compatible_aircraft_model_ids'] is List) {
          compatibleAircraftModelIds =
              (body['compatible_aircraft_model_ids'] as List).map((e) => e is int ? e : (e is num ? e.toInt() : int.tryParse(e.toString()))).where((e) => e != null).cast<int>().toList();
        } else if (body['compatible_aircraft_model_ids'] is String) {
          // Обрабатываем строку с запятыми
          final idsStr = body['compatible_aircraft_model_ids'] as String;
          if (idsStr.isNotEmpty) {
            compatibleAircraftModelIds = idsStr.split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();
          }
        }
      }

      // Парсим дополнительные изображения из JSON (если не multipart)
      if (!isMultipart) {
        if (body['additional_image_urls'] != null && body['additional_image_urls'] is List) {
          additionalImageUrls = (body['additional_image_urls'] as List).map((e) => e.toString()).toList();
        }
      }

      // Создаем запчасть в БД (без изображений пока, если multipart)
      final part = await _repository.createPart(
        sellerId: userId,
        title: title,
        description: body['description'] as String?,
        price: priceInt,
        currency: body['currency'] as String? ?? 'RUB',
        partsMainCategoryId: body['parts_main_category_id'] != null
            ? (body['parts_main_category_id'] is String ? int.tryParse(body['parts_main_category_id'] as String) : (body['parts_main_category_id'] as num).toInt())
            : null,
        partsSubcategoryId: body['parts_subcategory_id'] != null
            ? (body['parts_subcategory_id'] is String ? int.tryParse(body['parts_subcategory_id'] as String) : (body['parts_subcategory_id'] as num).toInt())
            : null,
        manufacturerId: body['manufacturer_id'] != null ? (body['manufacturer_id'] is String ? int.tryParse(body['manufacturer_id'] as String) : (body['manufacturer_id'] as num).toInt()) : null,
        manufacturerName: body['manufacturer_name'] as String?,
        partNumber: body['part_number'] as String?,
        oemNumber: body['oem_number'] as String?,
        condition: body['condition'] as String?,
        quantity: body['quantity'] != null
            ? (body['quantity'] is int ? body['quantity'] : (body['quantity'] is String ? int.tryParse(body['quantity'] as String) ?? 1 : (body['quantity'] as num).toInt()))
            : 1,
        mainImageUrl: isMultipart ? null : (body['main_image_url'] as String?),
        additionalImageUrls: isMultipart ? const [] : additionalImageUrls,
        weightKg: body['weight_kg'] != null ? (body['weight_kg'] is num ? (body['weight_kg'] as num).toDouble() : double.tryParse(body['weight_kg'].toString())) : null,
        dimensionsLengthCm: body['dimensions_length_cm'] != null
            ? (body['dimensions_length_cm'] is num ? (body['dimensions_length_cm'] as num).toDouble() : double.tryParse(body['dimensions_length_cm'].toString()))
            : null,
        dimensionsWidthCm: body['dimensions_width_cm'] != null
            ? (body['dimensions_width_cm'] is num ? (body['dimensions_width_cm'] as num).toDouble() : double.tryParse(body['dimensions_width_cm'].toString()))
            : null,
        dimensionsHeightCm: body['dimensions_height_cm'] != null
            ? (body['dimensions_height_cm'] is num ? (body['dimensions_height_cm'] as num).toDouble() : double.tryParse(body['dimensions_height_cm'].toString()))
            : null,
        compatibleAircraftModelsText: body['compatible_aircraft_models_text'] as String?,
        location: body['location'] as String?,
        address: body['address'] as Map<String, dynamic>?,
        compatibleAircraftModelIds: compatibleAircraftModelIds,
        isPublished: body['is_published'] != null ? (body['is_published'] is bool ? body['is_published'] as bool : body['is_published'].toString().toLowerCase() == 'true') : true,
      );

      final partId = part.id;

      // Если multipart, перемещаем файлы из временной директории в директорию запчасти
      if (isMultipart) {
        // Создаем директорию для изображений запчасти
        final partDir = Directory('public/market/parts/$partId');
        if (!await partDir.exists()) {
          await partDir.create(recursive: true);
        }

        // Перемещаем основное изображение
        if (mainImageTempPath != null) {
          final tempFile = File(mainImageTempPath);
          if (await tempFile.exists()) {
            final fileName = mainImageTempPath.split('/').last;
            final newPath = 'public/market/parts/$partId/$fileName';
            await tempFile.copy(newPath);
            await tempFile.delete();
            mainImageUrl = 'market/parts/$partId/$fileName';
          }
        }

        // Перемещаем дополнительные изображения
        for (final tempPath in additionalImagesTempPaths) {
          final tempFile = File(tempPath);
          if (await tempFile.exists()) {
            final fileName = tempPath.split('/').last;
            final newPath = 'public/market/parts/$partId/$fileName';
            await tempFile.copy(newPath);
            await tempFile.delete();
            additionalImageUrls.add('market/parts/$partId/$fileName');
          }
        }

        // Обновляем запчасть с URL изображений
        if (mainImageUrl != null || additionalImageUrls.isNotEmpty) {
          await _repository.updatePart(
            partId: partId,
            sellerId: userId,
            mainImageUrl: mainImageUrl,
            additionalImageUrls: additionalImageUrls,
          );
        }

        // Получаем обновленную запчасть
        final updatedPart = await _repository.getPartById(partId, userId: userId);
        if (updatedPart != null) {
          return Response.ok(jsonEncode(updatedPart.toJson()), headers: jsonContentHeaders);
        }
      }

      return Response.ok(jsonEncode(part.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Обновить объявление о запчасти
  @Route.put('/api/market/parts/<id>')
  @OpenApiRoute()
  Future<Response> updatePart(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      // Проверяем права доступа
      final part = await _repository.getPartById(id, userId: userId);
      if (part == null) {
        return Response.notFound(jsonEncode({'error': 'Part not found'}), headers: jsonContentHeaders);
      }

      final isOwner = part.sellerId == userId;
      if (!isOwner) {
        final profileRepository = await getIt.getAsync<ProfileRepository>();
        final isAdmin = await profileRepository.isAdmin(userId);
        if (!isAdmin) {
          return Response.forbidden(jsonEncode({'error': 'You do not have permission to update this part'}), headers: jsonContentHeaders);
        }
      }

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'] ?? '';
      final isMultipart = contentType.startsWith('multipart/form-data');

      Map<String, dynamic> body = {};
      String? mainImageUrl;
      List<String>? additionalImageUrls;

      if (isMultipart) {
        // Парсим multipart запрос (аналогично updateAircraft)
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

        // Создаем директорию для изображений запчасти
        final publicDir = Directory('public');
        if (!await publicDir.exists()) {
          await publicDir.create(recursive: true);
        }

        final marketDir = Directory('public/market');
        if (!await marketDir.exists()) {
          await marketDir.create(recursive: true);
        }

        final partsDir = Directory('public/market/parts');
        if (!await partsDir.exists()) {
          await partsDir.create(recursive: true);
        }

        final partDir = Directory('public/market/parts/$id');
        if (!await partDir.exists()) {
          await partDir.create(recursive: true);
        }

        // Обрабатываем части multipart
        final additionalImageUrlsList = <String>[];

        for (final partData in parts) {
          final contentDisposition = partData['content-disposition'] as String?;
          if (contentDisposition == null) continue;

          // Извлекаем имя поля
          final nameMatch = RegExp('name=["\']?([^"\';\\s]+)').firstMatch(contentDisposition);
          if (nameMatch == null) continue;
          final fieldName = nameMatch.group(1);
          if (fieldName == null) continue;

          // Обрабатываем текстовые поля
          if (fieldName != 'main_image' && fieldName != 'additional_images') {
            final fieldData = partData['data'] as List<int>?;
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
            final imageData = partData['data'] as List<int>?;
            if (imageData != null && imageData.isNotEmpty) {
              // Валидация размера (максимум 5MB)
              if (imageData.length > 5 * 1024 * 1024) {
                return Response.badRequest(body: jsonEncode({'error': 'Main image file size exceeds 5MB limit'}), headers: jsonContentHeaders);
              }

              // Определяем расширение
              String extension = 'jpg';
              final partContentType = partData['content-type'] as String?;
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
              final filePath = 'public/market/parts/$id/$fileName';
              final file = File(filePath);
              await file.writeAsBytes(imageData);

              mainImageUrl = 'market/parts/$id/$fileName';
            }
            continue;
          }

          // Обрабатываем дополнительные изображения
          if (fieldName == 'additional_images') {
            final imageData = partData['data'] as List<int>?;
            if (imageData != null && imageData.isNotEmpty) {
              // Валидация размера (максимум 5MB)
              if (imageData.length > 5 * 1024 * 1024) {
                continue; // Пропускаем слишком большие файлы
              }

              // Определяем расширение
              String extension = 'jpg';
              final partContentType = partData['content-type'] as String?;
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
              final filePath = 'public/market/parts/$id/$fileName';
              final file = File(filePath);
              await file.writeAsBytes(imageData);

              additionalImageUrlsList.add('market/parts/$id/$fileName');
            }
            continue;
          }
        }

        // Если mainImageUrl не был установлен из файла, но есть в body, используем его
        if (mainImageUrl == null && body.containsKey('main_image_url')) {
          final bodyMainImageUrl = body['main_image_url'] as String?;
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
          additionalImageUrls = part.additionalImageUrls;
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

      // Парсим совместимые модели самолетов
      List<int>? compatibleAircraftModelIds;
      if (body['compatible_aircraft_model_ids'] != null) {
        if (body['compatible_aircraft_model_ids'] is List) {
          compatibleAircraftModelIds =
              (body['compatible_aircraft_model_ids'] as List).map((e) => e is int ? e : (e is num ? e.toInt() : int.tryParse(e.toString()))).where((e) => e != null).cast<int>().toList();
        } else if (body['compatible_aircraft_model_ids'] is String) {
          // Обрабатываем строку с запятыми
          final idsStr = body['compatible_aircraft_model_ids'] as String;
          if (idsStr.isNotEmpty) {
            compatibleAircraftModelIds = idsStr.split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();
          }
        }
      }

      final updatedPartResult = await _repository.updatePart(
        partId: id,
        sellerId: userId,
        title: body['title'] as String?,
        description: body['description'] as String?,
        price: body['price'] != null ? (body['price'] is int ? body['price'] : (body['price'] is num ? (body['price'] as num).toInt() : int.tryParse(body['price'].toString()))) : null,
        currency: body['currency'] as String?,
        partsMainCategoryId: body['parts_main_category_id'] != null
            ? (body['parts_main_category_id'] is String ? int.tryParse(body['parts_main_category_id'] as String) : (body['parts_main_category_id'] as num).toInt())
            : null,
        partsSubcategoryId: body['parts_subcategory_id'] != null
            ? (body['parts_subcategory_id'] is String ? int.tryParse(body['parts_subcategory_id'] as String) : (body['parts_subcategory_id'] as num).toInt())
            : null,
        manufacturerId: body['manufacturer_id'] != null ? (body['manufacturer_id'] is String ? int.tryParse(body['manufacturer_id'] as String) : (body['manufacturer_id'] as num).toInt()) : null,
        manufacturerName: body['manufacturer_name'] as String?,
        partNumber: body['part_number'] as String?,
        oemNumber: body['oem_number'] as String?,
        condition: body['condition'] as String?,
        quantity: body['quantity'] != null
            ? (body['quantity'] is int ? body['quantity'] : (body['quantity'] is String ? int.tryParse(body['quantity'] as String) : (body['quantity'] as num).toInt()))
            : null,
        mainImageUrl: body['main_image_url'] as String?,
        additionalImageUrls: additionalImageUrls,
        weightKg: body['weight_kg'] != null ? (body['weight_kg'] is num ? (body['weight_kg'] as num).toDouble() : double.tryParse(body['weight_kg'].toString())) : null,
        dimensionsLengthCm: body['dimensions_length_cm'] != null
            ? (body['dimensions_length_cm'] is num ? (body['dimensions_length_cm'] as num).toDouble() : double.tryParse(body['dimensions_length_cm'].toString()))
            : null,
        dimensionsWidthCm: body['dimensions_width_cm'] != null
            ? (body['dimensions_width_cm'] is num ? (body['dimensions_width_cm'] as num).toDouble() : double.tryParse(body['dimensions_width_cm'].toString()))
            : null,
        dimensionsHeightCm: body['dimensions_height_cm'] != null
            ? (body['dimensions_height_cm'] is num ? (body['dimensions_height_cm'] as num).toDouble() : double.tryParse(body['dimensions_height_cm'].toString()))
            : null,
        compatibleAircraftModelsText: body['compatible_aircraft_models_text'] as String?,
        location: body['location'] as String?,
        address: body['address'] as Map<String, dynamic>?,
        compatibleAircraftModelIds: compatibleAircraftModelIds,
      );

      if (updatedPartResult == null) {
        return Response.notFound(jsonEncode({'error': 'Part not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(updatedPartResult.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Опубликовать объявление о запчасти
  @Route.post('/api/market/parts/<id>/publish')
  @OpenApiRoute()
  Future<Response> publishPart(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      final part = await _repository.publishPart(partId: id, sellerId: userId);
      if (part == null) {
        return Response.notFound(jsonEncode({'error': 'Part not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(part.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Снять с публикации
  @Route.post('/api/market/parts/<id>/unpublish')
  @OpenApiRoute()
  Future<Response> unpublishPart(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      final part = await _repository.unpublishPart(partId: id, sellerId: userId);
      if (part == null) {
        return Response.notFound(jsonEncode({'error': 'Part not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(part.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Деактивировать объявление (только для админа - блокирует публикацию)
  @Route.post('/api/market/parts/<id>/deactivate')
  @OpenApiRoute()
  Future<Response> deactivatePart(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      // Проверяем, что пользователь - админ
      final profileRepository = await getIt.getAsync<ProfileRepository>();
      final isAdmin = await profileRepository.isAdmin(userId);
      if (!isAdmin) {
        return Response.forbidden(jsonEncode({'error': 'Only admins can deactivate parts'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      final part = await _repository.deactivatePart(partId: id);
      if (part == null) {
        return Response.notFound(jsonEncode({'error': 'Part not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(part.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Активировать объявление (только для админа - разблокирует публикацию)
  @Route.post('/api/market/parts/<id>/activate')
  @OpenApiRoute()
  Future<Response> activatePart(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      // Проверяем, что пользователь - админ
      final profileRepository = await getIt.getAsync<ProfileRepository>();
      final isAdmin = await profileRepository.isAdmin(userId);
      if (!isAdmin) {
        return Response.forbidden(jsonEncode({'error': 'Only admins can activate parts'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      final part = await _repository.activatePart(partId: id);
      if (part == null) {
        return Response.notFound(jsonEncode({'error': 'Part not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(part.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Удалить объявление о запчасти
  @Route.delete('/api/market/parts/<id>')
  @OpenApiRoute()
  Future<Response> deletePart(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      final deleted = await _repository.deletePart(partId: id, sellerId: userId);
      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Part not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'message': 'Part deleted successfully'}), headers: jsonContentHeaders);
    });
  }

  /// Добавить в избранное
  @Route.post('/api/market/parts/<id>/favorite')
  @OpenApiRoute()
  Future<Response> addPartToFavorites(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      await _repository.addPartToFavorites(userId, id);
      return Response.ok(jsonEncode({'message': 'Part added to favorites'}), headers: jsonContentHeaders);
    });
  }

  /// Удалить из избранного
  @Route.delete('/api/market/parts/<id>/favorite')
  @OpenApiRoute()
  Future<Response> removePartFromFavorites(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      if (idStr == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Part ID is required'}), headers: jsonContentHeaders);
      }

      final id = int.tryParse(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid part ID'}), headers: jsonContentHeaders);
      }

      await _repository.removePartFromFavorites(userId, id);
      return Response.ok(jsonEncode({'message': 'Part removed from favorites'}), headers: jsonContentHeaders);
    });
  }

  /// Получить избранные запчасти
  @Route.get('/api/market/parts/favorites')
  @OpenApiRoute()
  Future<Response> getFavoriteParts(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final params = request.url.queryParameters;
      final limit = params['limit'] != null ? int.tryParse(params['limit']!) ?? 20 : 20;
      final offset = params['offset'] != null ? int.tryParse(params['offset']!) ?? 0 : 0;

      final parts = await _repository.getFavoriteParts(userId, limit: limit, offset: offset);
      return Response.ok(jsonEncode(parts.map((p) => p.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Вспомогательный метод для получения userId из запроса
  int? _getUserIdFromRequest(Request request) {
    try {
      final authHeader = request.headers['Authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        if (_tokenService.validateToken(token)) {
          final userIdStr = _tokenService.getUserIdFromToken(token);
          if (userIdStr != null && userIdStr.isNotEmpty) {
            return int.tryParse(userIdStr);
          }
        }
      }
    } catch (e) {
      // Игнорируем ошибки
    }
    return null;
  }
}
