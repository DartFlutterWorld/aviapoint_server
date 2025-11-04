import 'dart:async';
import 'dart:convert';

import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/learning/video_for_students/repositories/video_for_students_repository.dart';
import 'package:aviapoint_server/news/repositories/news_repository.dart';
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

  @Route.get('/category_news')
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

  @Route.get('/news')
  @OpenApiRoute()
  Future<Response> getnews(Request request) async {
    final body = await _newsRepository.getNews();

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
  /// Получение конкретной новости
  ///
  /// Получение конкретной новости
  ///

  @Route.get('/news/<id>')
  @OpenApiRoute()
  Future<Response> getNewsById(Request request) async {
    return wrapResponse(
      () async {
        final id = int.parse(request.params['id']!);

        return Response.ok(
          jsonEncode(await _newsRepository.getNewsById(id)),
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

  @Route.get('/news/category/<id>')
  @OpenApiRoute()
  Future<Response> getNewsByCategory(Request request) async {
    return wrapResponse(
      () async {
        final id = int.parse(request.params['id']!);

        return Response.ok(
          jsonEncode(await _newsRepository.getNewsByCategory(id)),
          headers: jsonContentHeaders,
        );
      },
    );
  }
}
