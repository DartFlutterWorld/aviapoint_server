import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/setup_dependencies/setup_dependencies.dart';
import 'package:aviapoint_server/profiles/api/create_user_request.dart';
import 'package:aviapoint_server/profiles/api/update_profile_request.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'dart:convert' show utf8;
import 'package:path/path.dart' as path;

part 'profile_cantroller.g.dart';

class ProfileController {
  final ProfileRepository _profileRepository;
  ProfileController({required ProfileRepository profileRepository}) : _profileRepository = profileRepository;

  Router get router => _$ProfileControllerRouter(this);

  @protected

  ///
  /// Создание пользователя
  ///
  /// Возвращает в ответе данные пользователя
  ///
  @Route.post('/api/user')
  @OpenApiRoute()
  Future<Response> createUser(Request request) async {
    final body = await request.readAsString();
    final createTodoRequest = CreateUserRequest.fromJson(jsonDecode(body));

    return wrapResponse(() async {
      // userId из контекста не используется, так как createUser создает нового пользователя
      // final userId = request.context['user_id'] as String;

      return Response.ok(
        jsonEncode(
          await _profileRepository.createUser(
            // id: 1,
            // name: createTodoRequest.name,
            phone: createTodoRequest.email,
          ),
        ),
        headers: jsonContentHeaders,
      );
    });
  }

  ///
  /// Получение профилей пользователей
  ///
  /// Получение всех профилей пользователей
  ///

  @Route.get('/api/profiles')
  @OpenApiRoute()
  Future<Response> getUsers(Request request) async {
    final body = await _profileRepository.fetchProiles();

    return wrapResponse(() async {
      return Response.ok(jsonEncode(body), headers: jsonContentHeaders);
    });
  }

  ///
  /// Получение профиля
  ///
  /// Получение всех профиля пользователя
  ///

  @Route.post('/api/profile')
  @OpenApiRoute()
  Future<Response> getProfile(Request request) async {
    return wrapResponse(() async {
      // Проверяем аутентификацию в самом методе
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      // Валидация токена
      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        logger.severe('Invalid token received. Token: ${token.substring(0, 20)}...');
        // Проверяем, истек ли токен или он невалидный по другой причине
        try {
          final payload = JwtDecoder.decode(token);
          final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
          final now = DateTime.now();
          if (now.isAfter(expiry)) {
            // Токен истек - возвращаем специальный код для обновления
            return Response.unauthorized(
              jsonEncode({'error': 'Token expired', 'code': 'TOKEN_EXPIRED', 'message': 'Access token has expired. Please refresh your token using the refresh_token.'}),
              headers: {...jsonContentHeaders, 'X-Token-Status': 'expired'},
            );
          }
        } catch (e) {
          // Токен невалидный по другой причине
        }
        return Response.unauthorized(jsonEncode({'error': 'Invalid token', 'code': 'INVALID_TOKEN'}), headers: {...jsonContentHeaders, 'X-Token-Status': 'invalid'});
      }

      // Получаем ID пользователя из токена
      final id = tokenService.getUserIdFromToken(token);
      if (id == null || id.isEmpty) {
        logger.severe('Cannot extract user ID from token');
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final result = await _profileRepository.fetchProfileById(int.parse(id));

      return Response.ok(jsonEncode(result), headers: jsonContentHeaders);
    });
  }

  ///
  /// Обновление профиля
  ///
  /// Обновление данных профиля пользователя
  ///

  @Route.put('/api/profile')
  @OpenApiRoute()
  Future<Response> updateProfile(Request request) async {
    return wrapResponse(() async {
      // Проверяем аутентификацию в самом методе
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      // Валидация токена
      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        logger.severe('Invalid token received. Token: ${token.substring(0, 20)}...');
        // Проверяем, истек ли токен или он невалидный по другой причине
        try {
          final payload = JwtDecoder.decode(token);
          final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
          final now = DateTime.now();
          if (now.isAfter(expiry)) {
            // Токен истек - возвращаем специальный код для обновления
            return Response.unauthorized(
              jsonEncode({'error': 'Token expired', 'code': 'TOKEN_EXPIRED', 'message': 'Access token has expired. Please refresh your token using the refresh_token.'}),
              headers: {...jsonContentHeaders, 'X-Token-Status': 'expired'},
            );
          }
        } catch (e) {
          // Токен невалидный по другой причине
        }
        return Response.unauthorized(jsonEncode({'error': 'Invalid token', 'code': 'INVALID_TOKEN'}), headers: {...jsonContentHeaders, 'X-Token-Status': 'invalid'});
      }

      // Получаем ID пользователя из токена
      final id = tokenService.getUserIdFromToken(token);
      if (id == null || id.isEmpty) {
        logger.severe('Cannot extract user ID from token');
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      // Парсим тело запроса
      final body = await request.readAsString();
      final updateProfileRequest = UpdateProfileRequest.fromJson(jsonDecode(body));

      final result = await _profileRepository.updateProfile(id: int.parse(id), email: updateProfileRequest.email, firstName: updateProfileRequest.firstName, lastName: updateProfileRequest.lastName);

      return Response.ok(jsonEncode(result), headers: jsonContentHeaders);
    });
  }

  ///
  /// Загрузка фото профиля
  ///
  /// Загрузка фотографии пользователя
  ///

  @Route.post('/api/profile/photo')
  @OpenApiRoute()
  Future<Response> uploadProfilePhoto(Request request) async {
    // Простая проверка, что код обновлен
    print('=== UPLOAD PHOTO METHOD CALLED ===');
    logger.info('=== UPLOAD PHOTO METHOD CALLED ===');
    logger.info('Upload photo: method started, headers: ${request.headers}');
    return wrapResponse(() async {
      logger.info('Upload photo: inside wrapResponse');
      // Проверяем аутентификацию
      final authHeader = request.headers['Authorization'];
      logger.info('Upload photo: authHeader = ${authHeader != null ? "present" : "missing"}');
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
      }

      final token = authHeader.substring(7);
      final tokenService = getIt.get<TokenService>();

      // Валидация токена
      final isValid = tokenService.validateToken(token);
      if (!isValid) {
        logger.severe('Invalid token received. Token: ${token.substring(0, 20)}...');
        try {
          final payload = JwtDecoder.decode(token);
          final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
          final now = DateTime.now();
          if (now.isAfter(expiry)) {
            return Response.unauthorized(
              jsonEncode({'error': 'Token expired', 'code': 'TOKEN_EXPIRED', 'message': 'Access token has expired. Please refresh your token using the refresh_token.'}),
              headers: {...jsonContentHeaders, 'X-Token-Status': 'expired'},
            );
          }
        } catch (e) {
          // Токен невалидный по другой причине
        }
        return Response.unauthorized(jsonEncode({'error': 'Invalid token', 'code': 'INVALID_TOKEN'}), headers: {...jsonContentHeaders, 'X-Token-Status': 'invalid'});
      }

      // Получаем ID пользователя из токена
      final id = tokenService.getUserIdFromToken(token);
      if (id == null || id.isEmpty) {
        logger.severe('Cannot extract user ID from token');
        return Response.unauthorized(jsonEncode({'error': 'Invalid token: no user ID'}));
      }

      final userId = int.parse(id);

      // Проверяем Content-Type
      final contentType = request.headers['Content-Type'];
      logger.info('Upload photo: contentType = $contentType');
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        logger.severe('Upload photo: invalid Content-Type: $contentType');
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

      logger.info('Upload photo: bodySize=${bodyBytes.length}, boundary=$boundary');

      // Парсим multipart вручную
      // Разделяем части по boundary
      final boundaryMarker = '--$boundary';
      final boundaryBytes = utf8.encode(boundaryMarker);
      final parts = <Map<String, dynamic>>[];

      // Находим все части
      int searchStart = 0;
      while (true) {
        final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (boundaryIndex == -1) break;

        searchStart = boundaryIndex + boundaryBytes.length;
        // Пропускаем CRLF
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

        // Ищем следующий boundary или конец
        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

        if (partEnd > searchStart) {
          final partBytes = bodyBytes.sublist(searchStart, partEnd);
          // Парсим заголовки и тело
          final partData = _parseMultipartPart(partBytes);
          if (partData != null) {
            parts.add(partData);
          }
        }

        if (nextBoundaryIndex == -1) break;
        searchStart = nextBoundaryIndex;
      }

      logger.info('Upload photo: parsed ${parts.length} parts');

      // Ищем поле с фото
      List<int>? photoData;
      String? extension = 'jpg'; // По умолчанию jpg

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        logger.info('Upload photo: checking part with content-disposition=$contentDisposition');
        if (contentDisposition != null && contentDisposition.contains('name="photo"')) {
          photoData = part['data'] as List<int>?;
          logger.info('Upload photo: found photo field, dataSize=${photoData?.length ?? 0}');

          // Определяем расширение из Content-Type
          final partContentType = part['content-type'] as String?;
          if (partContentType != null) {
            final partMediaType = MediaType.parse(partContentType);
            if (partMediaType.subtype == 'jpeg' || partMediaType.subtype == 'jpg') {
              extension = 'jpg';
            } else if (partMediaType.subtype == 'png') {
              extension = 'png';
            }
          }

          // Если расширение не определилось, пробуем из filename
          if (extension == 'jpg') {
            final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
            if (filenameMatch != null) {
              final filename = filenameMatch.group(1);
              if (filename != null && filename.isNotEmpty) {
                final fileExt = path.extension(filename).replaceFirst('.', '').toLowerCase();
                if (fileExt.isNotEmpty && (fileExt == 'jpg' || fileExt == 'jpeg' || fileExt == 'png')) {
                  extension = fileExt == 'jpeg' ? 'jpg' : fileExt;
                }
              }
            }
          }
          break;
        }
      }

      if (photoData == null || photoData.isEmpty) {
        logger.severe('Upload photo: photoData is null or empty. Parts count: ${parts.length}');
        for (int i = 0; i < parts.length; i++) {
          final part = parts[i];
          logger.severe('Upload photo: part $i - content-disposition: ${part['content-disposition']}, dataSize: ${(part['data'] as List<int>?)?.length ?? 0}');
        }
        return Response.badRequest(body: jsonEncode({'error': 'Photo field is required'}), headers: jsonContentHeaders);
      }

      // Валидация размера (максимум 5MB)
      if (photoData.length > 5 * 1024 * 1024) {
        return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 5MB limit'}), headers: jsonContentHeaders);
      }

      // Создаем директорию profiles если её нет
      // Используем абсолютный путь для надежности
      final currentDir = Directory.current.path;
      logger.info('Upload photo: current working directory = $currentDir');

      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        logger.info('Upload photo: creating public directory');
        await publicDir.create(recursive: true);
      }

      final profilesDir = Directory('public/profiles');
      if (!await profilesDir.exists()) {
        logger.info('Upload photo: creating profiles directory');
        await profilesDir.create(recursive: true);
      }

      // Проверяем, что директория доступна для записи
      final testFile = File('public/profiles/.write_test');
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
        logger.info('Upload photo: directory is writable');
      } catch (e) {
        logger.severe('Upload photo: directory is NOT writable: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': 'Directory is not writable', 'details': e.toString()}),
          headers: jsonContentHeaders,
        );
      }

      // Удаляем старое фото если есть
      final oldProfile = await _profileRepository.fetchProfileById(userId);
      logger.info('Upload photo: oldProfile.avatarUrl = ${oldProfile.avatarUrl}');
      if (oldProfile.avatarUrl != null && oldProfile.avatarUrl!.isNotEmpty) {
        try {
          final oldFilePath = oldProfile.avatarUrl!.startsWith('profiles/') ? 'public/${oldProfile.avatarUrl}' : 'public/profiles/${oldProfile.avatarUrl}';
          logger.info('Upload photo: attempting to delete old file: $oldFilePath');
          final oldFile = File(oldFilePath);
          if (await oldFile.exists()) {
            await oldFile.delete();
            logger.info('Upload photo: old file deleted successfully');
          } else {
            logger.info('Upload photo: old file does not exist: $oldFilePath');
          }
        } catch (e, stackTrace) {
          logger.severe('Upload photo: failed to delete old avatar: $e');
          logger.severe('Upload photo: stackTrace: $stackTrace');
        }
      } else {
        logger.info('Upload photo: no old avatar to delete');
      }

      // Сохраняем новое фото
      final fileName = '$userId.$extension';
      final filePath = 'public/profiles/$fileName';
      logger.info('Upload photo: saving file to $filePath, size=${photoData.length} bytes');

      try {
        final file = File(filePath);

        // Проверяем, существует ли файл перед записью
        final fileExistsBefore = await file.exists();
        if (fileExistsBefore) {
          logger.info('Upload photo: file already exists, will overwrite');
          // Пытаемся удалить существующий файл перед записью
          try {
            await file.delete();
            logger.info('Upload photo: existing file deleted before write');
          } catch (e) {
            logger.info('Upload photo: failed to delete existing file before write: $e');
          }
        }

        // Записываем новый файл
        await file.writeAsBytes(photoData);
        logger.info('Upload photo: file written successfully');

        // Проверяем, что файл действительно создан и имеет правильный размер
        if (await file.exists()) {
          final fileSize = await file.length();
          logger.info('Upload photo: file exists, size=$fileSize bytes (expected ${photoData.length} bytes)');
          if (fileSize != photoData.length) {
            logger.severe('Upload photo: file size mismatch! Expected ${photoData.length}, got $fileSize');
          }
        } else {
          logger.severe('Upload photo: file was not created!');
        }
      } catch (e, stackTrace) {
        logger.severe('Upload photo: failed to save file: $e');
        logger.severe('Upload photo: stackTrace: $stackTrace');
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to save photo', 'details': e.toString()}),
          headers: jsonContentHeaders,
        );
      }

      // Обновляем avatar_url в БД
      final avatarUrl = 'profiles/$fileName';
      logger.info('Upload photo: updating avatar_url in DB: $avatarUrl');
      final result = await _profileRepository.updateAvatarUrl(id: userId, avatarUrl: avatarUrl);
      logger.info('Upload photo: avatar_url updated successfully');

      return Response.ok(jsonEncode(result), headers: jsonContentHeaders);
    });
  }

  // Вспомогательный метод для поиска байтов в массиве
  int _indexOfBytes(List<int> haystack, List<int> needle, int start) {
    if (needle.isEmpty) return start;
    if (start >= haystack.length) return -1;

    for (int i = start; i <= haystack.length - needle.length; i++) {
      bool found = true;
      for (int j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }

  // Парсинг одной части multipart
  Map<String, dynamic>? _parseMultipartPart(List<int> partBytes) {
    // Ищем разделитель заголовков и тела (пустая строка CRLF CRLF)
    final headerEnd = _indexOfBytes(partBytes, [13, 10, 13, 10], 0);
    if (headerEnd == -1) return null;

    // Парсим заголовки
    final headerBytes = partBytes.sublist(0, headerEnd);
    final headerText = utf8.decode(headerBytes);
    final headers = <String, String>{};

    for (final line in headerText.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final colonIndex = trimmed.indexOf(':');
      if (colonIndex > 0) {
        final key = trimmed.substring(0, colonIndex).trim().toLowerCase();
        final value = trimmed.substring(colonIndex + 1).trim();
        headers[key] = value;
      }
    }

    // Тело части (пропускаем CRLF после заголовков)
    final bodyStart = headerEnd + 4;
    final bodyEnd = partBytes.length;
    // Убираем trailing CRLF если есть
    int actualBodyEnd = bodyEnd;
    if (bodyEnd > bodyStart + 2 && partBytes[bodyEnd - 2] == 13 && partBytes[bodyEnd - 1] == 10) {
      actualBodyEnd = bodyEnd - 2;
    }

    final data = partBytes.sublist(bodyStart, actualBodyEnd);

    return {'content-disposition': headers['content-disposition'], 'content-type': headers['content-type'], 'data': data};
  }
}
