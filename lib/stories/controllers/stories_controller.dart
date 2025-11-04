import 'dart:async';
import 'dart:convert';

import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/learning/video_for_students/repositories/video_for_students_repository.dart';
import 'package:aviapoint_server/stories/repositories/stories_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'stories_controller.g.dart';

class StoriesController {
  final StoriesRepository _storiesRepository;
  StoriesController({required StoriesRepository storiesRepository}) : _storiesRepository = storiesRepository;

  Router get router => _$StoriesControllerRouter(this);

  ///
  /// Получение всех видео сториков
  ///
  /// Получение всех видео сториков
  ///

  @Route.get('/stories')
  @OpenApiRoute()
  Future<Response> getStories(Request request) async {
    final body = await _storiesRepository.getStories();

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
  /// Получение конкретного сторика
  ///
  /// Получение конкретного сторика
  ///

  @Route.get('/stories/<id>')
  @OpenApiRoute()
  Future<Response> getStory(Request request) async {
    return wrapResponse(
      () async {
        // final id = request.context['id'] as String;
        final id = int.parse(request.params['id']!);

        return Response.ok(
          jsonEncode(await _storiesRepository.fetchStoryId(id)),
          headers: jsonContentHeaders,
        );
      },
    );
  }
}
