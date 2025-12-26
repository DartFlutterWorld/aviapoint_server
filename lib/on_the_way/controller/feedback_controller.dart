import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/on_the_way/repositories/feedback_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http_parser/http_parser.dart';

part 'feedback_controller.g.dart';

class FeedbackController {
  final FeedbackRepository _feedbackRepository;

  FeedbackController({required FeedbackRepository feedbackRepository}) : _feedbackRepository = feedbackRepository;

  Router get router => _$FeedbackControllerRouter(this);

  /// Отправить обратную связь
  @Route.post('/api/feedback')
  @OpenApiRoute()
  Future<Response> submitFeedback(Request request) async {
    return wrapResponse(() async {
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
      String? sourcePage;
      String? airportCode;
      int? flightId;
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

        final data = part['data'] as List<int>?;
        if (data == null) continue;

        final value = utf8.decode(data).trim();
        if (value.isEmpty) continue;

        switch (fieldName) {
          case 'source_page':
            sourcePage = value;
            break;
          case 'airport_code':
            airportCode = value;
            break;
          case 'flight_id':
            flightId = int.tryParse(value);
            break;
          case 'email':
            email = value;
            break;
          case 'comment':
            comment = value;
            break;
        }
      }

      // Валидация обязательных полей
      if (sourcePage == null || sourcePage.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'source_page is required'}),
          headers: jsonContentHeaders,
        );
      }

      if (comment == null || comment.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'comment is required'}),
          headers: jsonContentHeaders,
        );
      }

      // Обрабатываем фотографии
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final feedbackDir = Directory('public/feedback');
      if (!await feedbackDir.exists()) {
        await feedbackDir.create(recursive: true);
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
        final fileName = 'feedback.$timestamp.$random.$index.$extension';
        final filePath = 'public/feedback/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(photoData);

        photoUrls.add('feedback/$fileName');
      }

      // Сохраняем обратную связь
      final feedback = await _feedbackRepository.submitFeedback(
        sourcePage: sourcePage,
        airportCode: airportCode,
        flightId: flightId,
        email: email,
        comment: comment,
        photoUrls: photoUrls.isNotEmpty ? photoUrls : null,
      );

      return Response.ok(
        jsonEncode({'success': true, 'message': 'Обратная связь успешно отправлена', 'feedback': feedback.toJson()}),
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


