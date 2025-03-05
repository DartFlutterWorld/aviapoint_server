import 'dart:async';
import 'dart:convert';

import 'package:airpoint_server/core/wrap_response.dart';
import 'package:airpoint_server/learning/video_for_students/repositories/video_for_students_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'video_for_students_cantroller.g.dart';

class VideoForStudentsController {
  final VideoForStudentsRepository _videoForStudentsRepository;
  VideoForStudentsController({required VideoForStudentsRepository videoForStudentsRepository}) : _videoForStudentsRepository = videoForStudentsRepository;

  Router get router => _$VideoForStudentsControllerRouter(this);

  ///
  /// Получение всех видео для студентов
  ///
  /// Получение всех обучающих видео для студентов
  ///

  @Route.get('/learning/video_for_students')
  @OpenApiRoute()
  Future<Response> getVideoForStudents(Request request) async {
    final body = await _videoForStudentsRepository.fetchVideoForStudents();

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
  /// Получение конкретного видео для студентов
  ///
  /// Получение конкретного обучающих видео для студентов
  ///

  @Route.get('/learning/video_for_students/<id>')
  @OpenApiRoute()
  Future<Response> getVideoById(Request request) async {
    return wrapResponse(
      () async {
        // final id = request.context['id'] as String;
        final id = int.parse(request.params['id']!);

        return Response.ok(
          jsonEncode(await _videoForStudentsRepository.fetchVideoById(id)),
          headers: jsonContentHeaders,
        );
      },
    );
  }
}
