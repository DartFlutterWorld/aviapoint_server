import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/on_the_way/repositories/airport_repository.dart';
import 'package:aviapoint_server/on_the_way/repositories/airport_ownership_repository.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http_parser/http_parser.dart';

part 'airport_controller.g.dart';

class AirportController {
  final AirportRepository _airportRepository;
  final AirportOwnershipRepository _ownershipRepository;
  final ProfileRepository _profileRepository;

  AirportController({
    required AirportRepository airportRepository,
    required AirportOwnershipRepository ownershipRepository,
    required ProfileRepository profileRepository,
  })  : _airportRepository = airportRepository,
        _ownershipRepository = ownershipRepository,
        _profileRepository = profileRepository;

  Router get router => _$AirportControllerRouter(this);

  /// Поиск аэропортов
  @Route.get('/api/airports')
  @OpenApiRoute()
  Future<Response> searchAirports(Request request) async {
    return wrapResponse(() async {
      final query = request.url.queryParameters['q'];
      final country = request.url.queryParameters['country'];
      final type = request.url.queryParameters['type'];
      final limitStr = request.url.queryParameters['limit'];
      final limit = limitStr != null ? int.tryParse(limitStr) : 50;

      final airports = await _airportRepository.searchAirports(query: query, country: country, type: type, limit: limit ?? 50);

      return Response.ok(jsonEncode(airports.map((a) => a.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Получить аэропорт по коду
  @Route.get('/api/airports/<code>')
  @OpenApiRoute()
  Future<Response> getAirportByCode(Request request) async {
    return wrapResponse(() async {
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
      }

      final airport = await _airportRepository.getAirportByCode(code);

      if (airport == null) {
        return Response.notFound(jsonEncode({'error': 'Аэропорт с кодом $code не найден'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(airport.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Получить все аэропорты страны
  @Route.get('/api/airports/country/<country>')
  @OpenApiRoute()
  Future<Response> getAirportsByCountry(Request request) async {
    return wrapResponse(() async {
      final country = request.params['country'];
      if (country == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Country code is required'}), headers: jsonContentHeaders);
      }

      final limitStr = request.url.queryParameters['limit'];
      final limit = limitStr != null ? int.tryParse(limitStr) : null;

      final airports = await _airportRepository.getAirportsByCountry(country, limit: limit);

      return Response.ok(jsonEncode(airports.map((a) => a.toJson()).toList()), headers: jsonContentHeaders);
    });
  }

  /// Отправить обратную связь об аэропорте
  @Route.post('/api/airports/<code>/feedback')
  @OpenApiRoute()
  Future<Response> submitAirportFeedback(Request request) async {
    return wrapResponse(() async {
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
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

      // Извлекаем данные формы
      String? email;
      String? comment;
      final photoUrls = <String>[];

      // Обрабатываем текстовые поля
      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final nameMatch = RegExp('name=["\']?([^"\']+)').firstMatch(contentDisposition);
        if (nameMatch == null) continue;

        final fieldName = nameMatch.group(1);
        if (fieldName == null) continue;

        if (fieldName == 'email') {
          final data = part['data'] as List<int>?;
          if (data != null) {
            email = utf8.decode(data).trim();
            if (email.isEmpty) email = null;
          }
        } else if (fieldName == 'comment') {
          final data = part['data'] as List<int>?;
          if (data != null) {
            comment = utf8.decode(data).trim();
            if (comment.isEmpty) comment = null;
          }
        }
      }

      // Обрабатываем фотографии
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final airportsDir = Directory('public/airports');
      if (!await airportsDir.exists()) {
        await airportsDir.create(recursive: true);
      }

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isPhotoField = RegExp('name=["\']?photos').hasMatch(contentDisposition);
        if (!isPhotoField) continue;

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
        final index = photoUrls.length;
        final fileName = '$code.$timestamp.$random.$index.$extension';
        final filePath = 'public/airports/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(photoData);

        photoUrls.add('airports/$fileName');
      }

      // Сохраняем обратную связь
      await _airportRepository.submitAirportFeedback(
        airportCode: code,
        email: email,
        comment: comment,
        photoUrls: photoUrls.isNotEmpty ? photoUrls : null,
      );

      return Response.ok(
        jsonEncode({'success': true, 'message': 'Обратная связь успешно отправлена'}),
        headers: jsonContentHeaders,
      );
    });
  }

  /// Загрузить фотографии аэропорта
  @Route.post('/api/airports/<code>/photos')
  @OpenApiRoute()
  Future<Response> uploadAirportPhotos(Request request) async {
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

      // Получаем код аэропорта
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
      }

      // Проверяем, что пользователь является владельцем аэропорта
      final isOwner = await _airportRepository.isAirportOwner(userId, code);
      if (!isOwner) {
        return Response.forbidden(
          jsonEncode({'error': 'Only airport owners can upload photos'}),
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

      // Получаем телефон пользователя из профиля
      final userProfile = await _profileRepository.fetchProfileById(userId);
      final userPhone = userProfile.phone;

      // Извлекаем все фотографии
      final photoDataList = <Map<String, dynamic>>[];
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final officialDir = Directory('public/airports/official');
      if (!await officialDir.exists()) {
        await officialDir.create(recursive: true);
      }

      // Обрабатываем все части, которые содержат "photos" в имени
      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;
        
        // Проверяем, содержит ли поле имя "photos"
        final isPhotoField = RegExp('name=["\']?photos').hasMatch(contentDisposition);
        if (!isPhotoField) continue;
        
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

        // Сохраняем фото в папку official
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final index = photoDataList.length;
        final fileName = '$code.$timestamp.$random.$index.$extension';
        final filePath = 'public/airports/official/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(photoData);

        // Сохраняем метаданные фотографии
        photoDataList.add({
          'url': 'airports/official/$fileName',
          'user_id': userId,
          'phone': userPhone,
          'uploaded_at': DateTime.now().toIso8601String(),
        });
      }

      if (photoDataList.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No photos provided'}),
          headers: jsonContentHeaders,
        );
      }

      // Извлекаем только URL для обратной совместимости
      final photoUrls = photoDataList.map((p) => p['url'] as String).toList();

      // Сохраняем фотографии в БД
      await _airportRepository.uploadAirportPhotos(
        airportCode: code,
        photoUrls: photoUrls,
      );

      // Получаем обновленный аэропорт
      final updatedAirport = await _airportRepository.getAirportByCode(code);
      if (updatedAirport == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch updated airport'}),
          headers: jsonContentHeaders,
        );
      }

      return Response.ok(jsonEncode(updatedAirport.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Удалить фотографию аэропорта
  @Route.delete('/api/airports/<code>/photos')
  @OpenApiRoute()
  Future<Response> deleteAirportPhoto(Request request) async {
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

      // Получаем код аэропорта
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
      }

      // Проверяем, что пользователь является владельцем аэропорта
      final isOwner = await _airportRepository.isAirportOwner(userId, code);
      if (!isOwner) {
        return Response.forbidden(
          jsonEncode({'error': 'Only airport owners can delete photos'}),
          headers: jsonContentHeaders,
        );
      }

      // Получаем URL фотографии из тела запроса
      final body = await request.readAsString();
      final bodyJson = jsonDecode(body) as Map<String, dynamic>;
      final photoUrl = bodyJson['photo_url'] as String?;

      if (photoUrl == null || photoUrl.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'photo_url is required'}),
          headers: jsonContentHeaders,
        );
      }

      // Удаляем фотографию из БД
      await _airportRepository.deleteAirportPhoto(
        airportCode: code,
        photoUrl: photoUrl,
      );

      // Удаляем файл с диска
      try {
        final file = File('public/$photoUrl');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('⚠️ [AirportController] Ошибка удаления файла: $e');
        // Не прерываем выполнение, если файл не удалось удалить
      }

      // Получаем обновленный аэропорт
      final updatedAirport = await _airportRepository.getAirportByCode(code);
      if (updatedAirport == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch updated airport'}),
          headers: jsonContentHeaders,
        );
      }

      return Response.ok(jsonEncode(updatedAirport.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Загрузить фотографии посетителей (доступно всем авторизованным пользователям)
  @Route.post('/api/airports/<code>/visitor-photos')
  @OpenApiRoute()
  Future<Response> uploadVisitorPhotos(Request request) async {
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

      // Получаем код аэропорта
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
      }

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'];
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}),
          headers: jsonContentHeaders,
        );
      }

      // Парсим multipart запрос (используем ту же логику)
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

      // Получаем телефон пользователя из профиля
      final userProfile = await _profileRepository.fetchProfileById(int.parse(userIdStr));
      final userPhone = userProfile.phone;

      // Извлекаем все фотографии
      final photoDataList = <Map<String, dynamic>>[];
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final visitorDir = Directory('public/airports/visitor');
      if (!await visitorDir.exists()) {
        await visitorDir.create(recursive: true);
      }

      // Обрабатываем все части, которые содержат "photos" в имени
      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;
        
        final isPhotoField = RegExp('name=["\']?photos').hasMatch(contentDisposition);
        if (!isPhotoField) continue;
        
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

        // Сохраняем фото в папку visitor
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final index = photoDataList.length;
        final fileName = '$code.$timestamp.$random.$index.$extension';
        final filePath = 'public/airports/visitor/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(photoData);

        // Сохраняем метаданные фотографии
        photoDataList.add({
          'url': 'airports/visitor/$fileName',
          'user_id': int.parse(userIdStr),
          'phone': userPhone,
          'uploaded_at': DateTime.now().toIso8601String(),
        });
      }

      if (photoDataList.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No photos provided'}),
          headers: jsonContentHeaders,
        );
      }

      // Сохраняем фотографии в БД с метаданными
      await _airportRepository.uploadVisitorPhotos(
        airportCode: code,
        photoDataList: photoDataList,
      );

      // Получаем обновленный аэропорт
      final updatedAirport = await _airportRepository.getAirportByCode(code);
      if (updatedAirport == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch updated airport'}),
          headers: jsonContentHeaders,
        );
      }

      return Response.ok(jsonEncode(updatedAirport.toJson()), headers: jsonContentHeaders);
    });
  }

  /// Удалить фотографию посетителя
  @Route.delete('/api/airports/<code>/visitor-photos')
  @OpenApiRoute()
  Future<Response> deleteVisitorPhoto(Request request) async {
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

      // Получаем код аэропорта и photo_url из параметров запроса
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
      }

      // Парсим тело запроса для получения photo_url
      final body = await request.readAsString();
      Map<String, dynamic> requestData;
      try {
        requestData = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid JSON in request body'}),
          headers: jsonContentHeaders,
        );
      }

      final photoUrl = requestData['photo_url'] as String?;
      if (photoUrl == null || photoUrl.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'photo_url is required'}),
          headers: jsonContentHeaders,
        );
      }

      // Получаем аэропорт для получения ID
      final airport = await _airportRepository.getAirportByCode(code);
      if (airport == null) {
        return Response.notFound(
          jsonEncode({'error': 'Airport not found'}),
          headers: jsonContentHeaders,
        );
      }

      // Проверяем, существует ли фотография и принадлежит ли она пользователю
      final photoResult = await _airportRepository.getVisitorPhotoByUrl(airport.id, photoUrl);
      if (photoResult == null) {
        return Response.notFound(
          jsonEncode({'error': 'Photo not found'}),
          headers: jsonContentHeaders,
        );
      }

      // Проверяем, что пользователь является автором фотографии
      if (photoResult['user_id'] != userId) {
        return Response.forbidden(
          jsonEncode({'error': 'You can only delete your own photos'}),
          headers: jsonContentHeaders,
        );
      }

      // Удаляем фотографию из БД
      await _airportRepository.deleteVisitorPhoto(airport.id, photoUrl);

      // Удаляем файл с диска
      try {
        final filePath = 'public/${photoUrl}';
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Игнорируем ошибки удаления файла, главное - удалить из БД
        print('⚠️ [AirportController] Не удалось удалить файл: $e');
      }

      // Получаем обновленный аэропорт
      final updatedAirport = await _airportRepository.getAirportByCode(code);
      if (updatedAirport == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch updated airport'}),
          headers: jsonContentHeaders,
        );
      }

      return Response.ok(jsonEncode(updatedAirport.toJson()), headers: jsonContentHeaders);
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

  /// Проверить, является ли пользователь владельцем аэропорта
  @Route.get('/api/airports/<code>/is-owner')
  @OpenApiRoute()
  Future<Response> checkIsOwner(Request request) async {
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
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
      }

      final isOwner = await _airportRepository.isAirportOwner(userId, code);

      return Response.ok(
        jsonEncode({'is_owner': isOwner}),
        headers: jsonContentHeaders,
      );
    });
  }

  /// Обновить данные аэропорта (только для владельца)
  @Route.put('/api/airports/<code>')
  @OpenApiRoute()
  Future<Response> updateAirport(Request request) async {
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
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
      }

      // Читаем тело запроса
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      try {
        final updatedAirport = await _airportRepository.updateAirport(
          userId: userId,
          airportCode: code,
          name: data['name'] as String?,
          nameEng: data['name_eng'] as String?,
          city: data['city'] as String?,
          region: data['region'] as String?,
          email: data['email'] as String?,
          website: data['website'] as String?,
          notes: data['notes'] as String?,
          runwayLength: data['runway_length'] as int?,
          runwayWidth: data['runway_width'] as int?,
          runwaySurface: data['runway_surface'] as String?,
          runwayName: data['runway_name'] as String?,
          services: data['services'] as Map<String, dynamic>?,
        );

        return Response.ok(
          jsonEncode(updatedAirport?.toJson()),
          headers: jsonContentHeaders,
        );
      } catch (e) {
        if (e.toString().contains('not the owner')) {
          return Response.forbidden(
            jsonEncode({'error': 'You are not the owner of this airport'}),
            headers: jsonContentHeaders,
          );
        }
        rethrow;
      }
    });
  }

  /// Подать заявку на владение аэродромом
  @Route.post('/api/airports/<code>/ownership-request')
  @OpenApiRoute()
  Future<Response> submitOwnershipRequest(Request request) async {
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
      final code = request.params['code'];
      if (code == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Airport code is required'}), headers: jsonContentHeaders);
      }

      // Получаем аэропорт
      final airport = await _airportRepository.getAirportByCode(code);
      if (airport == null) {
        return Response.notFound(
          jsonEncode({'error': 'Аэропорт с кодом $code не найден'}),
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

      // Извлекаем данные формы
      String? email;
      String? phoneFromRequest;
      String? fullName;
      String? comment;
      final documentUrls = <String>[];

      // Обрабатываем текстовые поля (пропускаем файлы)
      final textFieldNames = {'email', 'phone', 'full_name', 'comment'};
      
      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        // Проверяем, является ли это файлом (есть filename в content-disposition)
        final hasFilename = RegExp('filename=').hasMatch(contentDisposition);
        if (hasFilename) {
          // Это файл, пропускаем
          continue;
        }

        final nameMatch = RegExp('name=["\']?([^"\']+)').firstMatch(contentDisposition);
        if (nameMatch == null) continue;

        final fieldName = nameMatch.group(1);
        if (fieldName == null) continue;

        // Пропускаем поля, которые не являются текстовыми
        if (!textFieldNames.contains(fieldName)) {
          continue;
        }

        final data = part['data'] as List<int>?;
        if (data == null || data.isEmpty) continue;

        // Пытаемся декодировать как UTF-8, но с обработкой ошибок
        String value;
        try {
          value = utf8.decode(data, allowMalformed: true).trim();
        } catch (e) {
          // Если не удалось декодировать, пропускаем это поле (вероятно, это бинарные данные)
          continue;
        }

        switch (fieldName) {
          case 'email':
            email = value.isNotEmpty ? value : null;
            break;
          case 'phone':
            phoneFromRequest = value.isNotEmpty ? value : null;
            break;
          case 'full_name':
            fullName = value.isNotEmpty ? value : null;
            break;
          case 'comment':
            comment = value.isNotEmpty ? value : null;
            break;
        }
      }

      // Валидация
      if (email == null || email.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'email is required'}),
          headers: jsonContentHeaders,
        );
      }

      // Обрабатываем документы
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final ownershipDocsDir = Directory('public/ownership_documents');
      if (!await ownershipDocsDir.exists()) {
        await ownershipDocsDir.create(recursive: true);
      }

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isDocumentField = RegExp('name=["\']?documents').hasMatch(contentDisposition);
        if (!isDocumentField) continue;

        final documentData = part['data'] as List<int>?;
        if (documentData == null || documentData.isEmpty) continue;

        // Валидация размера (максимум 10MB для документов)
        if (documentData.length > 10 * 1024 * 1024) {
          return Response.badRequest(
            body: jsonEncode({'error': 'File size exceeds 10MB limit'}),
            headers: jsonContentHeaders,
          );
        }

        // Определяем расширение
        String extension = 'pdf';
        final partContentType = part['content-type'] as String?;
        if (partContentType != null) {
          final partMediaType = MediaType.parse(partContentType);
          if (partMediaType.subtype == 'pdf') {
            extension = 'pdf';
          } else if (partMediaType.subtype == 'jpeg' || partMediaType.subtype == 'jpg') {
            extension = 'jpg';
          } else if (partMediaType.subtype == 'png') {
            extension = 'png';
          }
        }

        // Сохраняем документ
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final index = documentUrls.length;
        final fileName = '$userId.${airport.id}.$timestamp.$random.$index.$extension';
        final filePath = 'public/ownership_documents/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(documentData);

        documentUrls.add('ownership_documents/$fileName');
      }

      // Получаем телефон пользователя из профиля
      final userProfile = await _profileRepository.fetchProfileById(userId);
      final userPhone = userProfile.phone;

      // Сохраняем заявку
      try {
        final ownershipRequest = await _ownershipRepository.submitOwnershipRequest(
          userId: userId,
          airportId: airport.id,
          airportCode: code,
          email: email,
          phone: userPhone,
          phoneFromRequest: phoneFromRequest,
          fullName: fullName,
          comment: comment,
          documentUrls: documentUrls.isNotEmpty ? documentUrls : null,
        );

        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Заявка на владение аэродромом успешно подана',
            'request': ownershipRequest.toJson(),
          }),
          headers: jsonContentHeaders,
        );
      } catch (e) {
        if (e.toString().contains('уже подана')) {
          return Response.badRequest(
            body: jsonEncode({'error': e.toString()}),
            headers: jsonContentHeaders,
          );
        }
        rethrow;
      }
    });
  }
}
