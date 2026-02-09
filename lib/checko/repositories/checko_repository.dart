import 'dart:convert';

import 'package:aviapoint_server/core/config/config.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';

/// Репозиторий для работы с API Checko (организации и ИП) и БД.
class CheckoRepository {
  static const String _baseUrl = 'https://api.checko.ru/v2';
  final http.Client _client;
  final Connection _connection;

  CheckoRepository({required Connection connection, http.Client? client})
      : _connection = connection,
        _client = client ?? http.Client();

  /// Попробовать найти закэшированные данные об организации по ИНН.
  ///
  /// Возвращает raw_data или null, если записей нет.
  Future<Map<String, dynamic>?> getCachedCompanyByInn(String inn) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT raw_data
        FROM checko_companies
        WHERE inn = @inn
        ORDER BY updated_at DESC
        LIMIT 1
      '''),
      parameters: <String, dynamic>{'inn': inn},
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first.toColumnMap();
    final raw = row['raw_data'];
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is String) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    return null;
  }

  /// Запрос информации об организации (ЕГРЮЛ).
  ///
  /// Проксирует запрос к `https://api.checko.ru/v2/company`.
  Future<Map<String, dynamic>> fetchCompany({
    String? ogrn,
    String? inn,
    String? kpp,
    String? okpo,
    bool source = false,
  }) async {
    _ensureApiKeyConfigured();

    if ((ogrn == null || ogrn.isEmpty) && (inn == null || inn.isEmpty) && (okpo == null || okpo.isEmpty)) {
      throw ArgumentError('Необходимо указать хотя бы один из параметров: ogrn, inn или okpo');
    }

    final uri = Uri.parse('$_baseUrl/company').replace(
      queryParameters: <String, String>{
        'key': Config.checkoApiKey,
        if (ogrn != null && ogrn.isNotEmpty) 'ogrn': ogrn,
        if (inn != null && inn.isNotEmpty) 'inn': inn,
        if (kpp != null && kpp.isNotEmpty) 'kpp': kpp,
        if (okpo != null && okpo.isNotEmpty) 'okpo': okpo,
        if (source) 'source': 'true',
      },
    );

    logger.info('🔎 [CheckoRepository] GET $uri');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      logger.severe(
        '❌ [CheckoRepository] Ошибка ответа Checko company: '
        'status=${response.statusCode}, body=${response.body}',
      );

      return <String, dynamic>{
        'meta': {
          'status': 'error',
          'http_status': response.statusCode,
          'message': 'Checko company request failed',
        },
        'raw_body': response.body,
      };
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{
      'meta': {
        'status': 'error',
        'message': 'Unexpected response format from Checko company API',
      },
      'data': decoded,
    };
  }

  /// Сохранить/обновить данные об организации (глобальный кэш по ИНН).
  ///
  /// Использует уникальный ключ (inn).
  Future<void> saveCompany({
    required String inn,
    String? ogrn,
    String? kpp,
    String? okpo,
    required Map<String, dynamic> rawData,
  }) async {
    await _connection.execute(
      Sql.named('''
        INSERT INTO checko_companies (
          inn,
          ogrn,
          kpp,
          okpo,
          raw_data,
          created_at,
          updated_at
        )
        VALUES (
          @inn,
          @ogrn,
          @kpp,
          @okpo,
          @raw_data::jsonb,
          NOW(),
          NOW()
        )
        ON CONFLICT (inn) DO UPDATE
        SET
          ogrn      = EXCLUDED.ogrn,
          kpp       = EXCLUDED.kpp,
          okpo      = EXCLUDED.okpo,
          raw_data  = EXCLUDED.raw_data,
          updated_at = NOW()
      '''),
      parameters: <String, dynamic>{
        'inn': inn,
        'ogrn': ogrn,
        'kpp': kpp,
        'okpo': okpo,
        'raw_data': jsonEncode(rawData),
      },
    );
  }

  // Ранее здесь были методы, привязанные к userId, они больше не нужны:
  // кэш глобальный по ИНН и хранится один раз на всю систему.

  /// Запрос информации об индивидуальном предпринимателе (ЕГРИП).
  ///
  /// Проксирует запрос к `https://api.checko.ru/v2/entrepreneur`.
  Future<Map<String, dynamic>> fetchEntrepreneur({
    String? ogrn,
    String? inn,
    String? okpo,
    bool source = false,
  }) async {
    _ensureApiKeyConfigured();

    if ((ogrn == null || ogrn.isEmpty) && (inn == null || inn.isEmpty) && (okpo == null || okpo.isEmpty)) {
      throw ArgumentError('Необходимо указать хотя бы один из параметров: ogrn, inn или okpo');
    }

    final uri = Uri.parse('$_baseUrl/entrepreneur').replace(
      queryParameters: <String, String>{
        'key': Config.checkoApiKey,
        if (ogrn != null && ogrn.isNotEmpty) 'ogrn': ogrn,
        if (inn != null && inn.isNotEmpty) 'inn': inn,
        if (okpo != null && okpo.isNotEmpty) 'okpo': okpo,
        if (source) 'source': 'true',
      },
    );

    logger.info('🔎 [CheckoRepository] GET $uri');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      logger.severe(
        '❌ [CheckoRepository] Ошибка ответа Checko entrepreneur: '
        'status=${response.statusCode}, body=${response.body}',
      );

      return <String, dynamic>{
        'meta': {
          'status': 'error',
          'http_status': response.statusCode,
          'message': 'Checko entrepreneur request failed',
        },
        'raw_body': response.body,
      };
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{
      'meta': {
        'status': 'error',
        'message': 'Unexpected response format from Checko entrepreneur API',
      },
      'data': decoded,
    };
  }

  /// Попробовать найти закэшированные данные об ИП по ИНН.
  ///
  /// Возвращает raw_data или null, если записей нет.
  Future<Map<String, dynamic>?> getCachedEntrepreneurByInn(String inn) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT raw_data
        FROM checko_entrepreneurs
        WHERE inn = @inn
        ORDER BY updated_at DESC
        LIMIT 1
      '''),
      parameters: <String, dynamic>{'inn': inn},
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first.toColumnMap();
    final raw = row['raw_data'];
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is String) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    return null;
  }

  /// Сохранить/обновить данные об ИП (глобальный кэш по ИНН).
  ///
  /// Использует уникальный ключ (inn).
  Future<void> saveEntrepreneur({
    required String inn,
    String? ogrn,
    String? okpo,
    required Map<String, dynamic> rawData,
  }) async {
    await _connection.execute(
      Sql.named('''
        INSERT INTO checko_entrepreneurs (
          inn,
          ogrn,
          okpo,
          raw_data,
          created_at,
          updated_at
        )
        VALUES (
          @inn,
          @ogrn,
          @okpo,
          @raw_data::jsonb,
          NOW(),
          NOW()
        )
        ON CONFLICT (inn) DO UPDATE
        SET
          ogrn       = EXCLUDED.ogrn,
          okpo       = EXCLUDED.okpo,
          raw_data   = EXCLUDED.raw_data,
          updated_at = NOW()
      '''),
      parameters: <String, dynamic>{
        'inn': inn,
        'ogrn': ogrn,
        'okpo': okpo,
        'raw_data': jsonEncode(rawData),
      },
    );
  }

  // Методы getEntrepreneurForUser / getCompanyForUser, завязанные на userId, удалены:
  // теперь кэш не зависит от пользователя.

  void _ensureApiKeyConfigured() {
    if (Config.checkoApiKey.isEmpty) {
      throw StateError(
        'CHECKO_API_KEY не задан. '
        'Установите переменную окружения CHECKO_API_KEY или добавьте её в .env.local для локальной разработки.',
      );
    }
  }
}

