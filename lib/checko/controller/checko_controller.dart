import 'dart:convert';

import 'package:aviapoint_server/checko/repositories/checko_repository.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';

part 'checko_controller.g.dart';

/// Контроллер для работы с API Checko.
///
/// Прокси-эндпоинты:
/// - /api/checko/company
/// - /api/checko/entrepreneur
class CheckoController {
  final CheckoRepository _repository;
  CheckoController({required CheckoRepository repository}) : _repository = repository;

  Router get router => _$CheckoControllerRouter(this);

  /// Получение информации об организации (ЕГРЮЛ) через Checko.
  ///
  /// Пример:
  /// GET /api/checko/company?inn=7707083893
  /// GET /api/checko/company?ogrn=1027700132195
  @Route.get('/api/checko/company')
  @OpenApiRoute()
  Future<Response> getCompany(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;
      final ogrn = params['ogrn'];
      final inn = params['inn'];
      final kpp = params['kpp'];
      final okpo = params['okpo'];
      final source = params['source'] == 'true';

      if ((ogrn == null || ogrn.isEmpty) && (inn == null || inn.isEmpty) && (okpo == null || okpo.isEmpty)) {
        return Response.badRequest(
          body: jsonEncode(<String, dynamic>{
            'error': 'validation_error',
            'message': 'Необходимо указать хотя бы один из параметров: ogrn, inn или okpo',
          }),
          headers: jsonContentHeaders,
        );
      }

      logger.info(
        '📡 [CheckoController] /company request: ogrn=$ogrn, inn=$inn, kpp=$kpp, okpo=$okpo, source=$source',
      );

      final data = await _repository.fetchCompany(
        ogrn: ogrn,
        inn: inn,
        kpp: kpp,
        okpo: okpo,
        source: source,
      );

      return Response.ok(
        jsonEncode(data),
        headers: jsonContentHeaders,
      );
    });
  }

  /// Получение информации об индивидуальном предпринимателе (ЕГРИП) через Checko.
  ///
  /// Пример:
  /// GET /api/checko/entrepreneur?inn=123456789012
  /// GET /api/checko/entrepreneur?ogrn=304770000000000
  @Route.get('/api/checko/entrepreneur')
  @OpenApiRoute()
  Future<Response> getEntrepreneur(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;
      final ogrn = params['ogrn'];
      final inn = params['inn'];
      final okpo = params['okpo'];
      final source = params['source'] == 'true';

      if ((ogrn == null || ogrn.isEmpty) && (inn == null || inn.isEmpty) && (okpo == null || okpo.isEmpty)) {
        return Response.badRequest(
          body: jsonEncode(<String, dynamic>{
            'error': 'validation_error',
            'message': 'Необходимо указать хотя бы один из параметров: ogrn, inn или okpo',
          }),
          headers: jsonContentHeaders,
        );
      }

      logger.info(
        '📡 [CheckoController] /entrepreneur request: ogrn=$ogrn, inn=$inn, okpo=$okpo, source=$source',
      );

      final data = await _repository.fetchEntrepreneur(
        ogrn: ogrn,
        inn: inn,
        okpo: okpo,
        source: source,
      );

      return Response.ok(
        jsonEncode(data),
        headers: jsonContentHeaders,
      );
    });
  }

  /// Универсальный эндпоинт: по длине ИНН сам решает, в какой Checko API идти.
  ///
  /// - 10 цифр → организация (ЕГРЮЛ) → /v2/company
  /// - 12 цифр → ИП (ЕГРИП) → /v2/entrepreneur
  ///
  /// GET /api/checko/by-inn?inn=7707083893
  /// GET /api/checko/by-inn?inn=123456789012
  @Route.get('/api/checko/by-inn')
  @OpenApiRoute()
  Future<Response> getByInn(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;
      final inn = params['inn']?.trim();
      final source = params['source'] == 'true';

      if (inn == null || inn.isEmpty) {
        return Response.badRequest(
          body: jsonEncode(<String, dynamic>{
            'error': 'validation_error',
            'message': 'Параметр inn обязателен',
          }),
          headers: jsonContentHeaders,
        );
      }

      // Допустим только цифры
      if (!RegExp(r'^\d+$').hasMatch(inn)) {
        return Response.badRequest(
          body: jsonEncode(<String, dynamic>{
            'error': 'validation_error',
            'message': 'ИНН должен содержать только цифры',
          }),
          headers: jsonContentHeaders,
        );
      }

      logger.info('📡 [CheckoController] /by-inn request: inn=$inn, length=${inn.length}, source=$source');

      Map<String, dynamic> data;

      if (inn.length == 10) {
        // Юридическое лицо
        // 1) Пытаемся взять из локального кэша по ИНН
        data = await _repository.getCachedCompanyByInn(inn) ?? <String, dynamic>{};

        if (data.isEmpty) {
          // 2) Если в кэше нет — идём в Checko
          data = await _repository.fetchCompany(
            inn: inn,
            source: source,
          );

          // 3) Сохраняем как кэш
          try {
            await _repository.saveCompany(
              inn: inn,
              ogrn: (data['data']?['ОГРН'] as String?) ?? (data['data']?['ogrn'] as String?),
              kpp: (data['data']?['КПП'] as String?) ?? (data['data']?['kpp'] as String?),
              okpo: (data['data']?['ОКПО'] as String?) ?? (data['data']?['okpo'] as String?),
              rawData: data,
            );
          } catch (e, stackTrace) {
            logger.severe('❌ [CheckoController] Не удалось сохранить данные компании в БД (by-inn): $e');
            logger.severe('Stack trace: $stackTrace');
          }
        } else {
          logger.info('✅ [CheckoController] Найдены кэшированные данные компании по ИНН $inn');
        }
      } else if (inn.length == 12) {
        // ИП
        // 1) Пытаемся взять из локального кэша по ИНН
        data = await _repository.getCachedEntrepreneurByInn(inn) ?? <String, dynamic>{};

        if (data.isEmpty) {
          // 2) Если в кэше нет — идём в Checko
          data = await _repository.fetchEntrepreneur(
            inn: inn,
            source: source,
          );

          // 3) Сохраняем как кэш
          try {
            await _repository.saveEntrepreneur(
              inn: inn,
              ogrn: (data['data']?['ОГРН'] as String?) ?? (data['data']?['ogrn'] as String?),
              okpo: (data['data']?['ОКПО'] as String?) ?? (data['data']?['okpo'] as String?),
              rawData: data,
            );
          } catch (e, stackTrace) {
            logger.severe('❌ [CheckoController] Не удалось сохранить данные ИП в БД (by-inn): $e');
            logger.severe('Stack trace: $stackTrace');
          }
        } else {
          logger.info('✅ [CheckoController] Найдены кэшированные данные ИП по ИНН $inn');
        }
      } else {
        return Response.badRequest(
          body: jsonEncode(<String, dynamic>{
            'error': 'validation_error',
            'message': 'Длина ИНН должна быть 10 (организация) или 12 (ИП) символов',
          }),
          headers: jsonContentHeaders,
        );
      }

      return Response.ok(
        jsonEncode(data),
        headers: jsonContentHeaders,
      );
    });
  }
}

