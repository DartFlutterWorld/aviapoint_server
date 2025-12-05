import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:aviapoint_server/telegram/telegram_bot_service.dart';
import 'package:dio/dio.dart' as mydio;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_open_api/shelf_open_api.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_controller.g.dart';

class AuthController {
  final ProfileRepository _profileRepository;
  final TokenService _tokenService;
  AuthController({required ProfileRepository profileRepository, required TokenService tokenService}) : _profileRepository = profileRepository, _tokenService = tokenService;

  Router get router => _$AuthControllerRouter(this);

  String smsCode = '';

  @protected
  ///
  /// Отправление sms
  ///
  /// Отправление sms пользователю на телефон
  ///
  @Route.post('/auth/sms')
  @OpenApiRoute()
  Future<Response> sendSms(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final phone = json['phone'] as String;

    // Тестовый номер телефона - не отправляем SMS
    const testPhone = '+79000000000';
    if (phone == testPhone || phone == '79000000000' || phone == '9000000000') {
      smsCode = '0000';
      print('Test phone detected: $phone, SMS code: $smsCode');
      // Возвращаем тот же формат, что и при обычной отправке SMS
      // SmsDto требует: err_code (nullable) и text (required String)
      final testResponse = {
        'err_code': '0',
        'text': '0000', // Обязательное поле для SmsDto
        'id_sms': 'test-${DateTime.now().millisecondsSinceEpoch}',
        'phone': phone,
        'cost': '0.00',
        'balance': '0.00',
      };
      return Response.ok(jsonEncode(testResponse), headers: jsonContentHeaders);
    }

    final random = Random();
    // Генерируем число от 1000 до 9999 (включительно)
    final code = 1000 + random.nextInt(9000);
    smsCode = code.toString();
    print('smsCode: $smsCode');

    final dio = mydio.Dio();
    final response = await dio.get(
      'https://ssl.bs00.ru/',
      queryParameters: {
        'method': 'push_msg',
        'key': 'Z9XmMsMf576ameBMDPG6863eeb732a4cea5dd10274ea72049fa863d63164b2cf',
        'text': code,
        'phone': phone,
        // 'phone': 'error',
        'sender_name': 'AviaPoint',
        'format': 'json',
      },
    );

    final responseData = response.data is String ? jsonDecode(response.data) as Map<String, dynamic> : response.data as Map<String, dynamic>;
    final errorCode = responseData['response']['msg']['err_code'];
    print('Sms отправлено ${response.data}');
    print('SMS response structure: ${responseData['response']['msg']}');
    if (errorCode == '0') {
      final msgData = responseData['response']['msg'] as Map<String, dynamic>;
      return Response.ok(jsonEncode(msgData), headers: jsonContentHeaders);
    } else {
      final msgData = responseData['response']['msg'] as Map<String, dynamic>;
      return Response.notFound(jsonEncode(msgData), headers: jsonContentHeaders);
    }
  }

  ///
  /// Логин
  ///
  /// Логин по телефону и смс
  ///
  @Route.post('/auth/login')
  @OpenApiRoute()
  Future<Response> login(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final phone = json['phone'] as String;
    final sms = json['sms'] as String;

    // Тестовый номер телефона - принимаем код 0000
    const testPhone = '+79000000000';
    final isTestPhone = phone == testPhone || phone == '79000000000' || phone == '9000000000';
    final isValidCode = isTestPhone ? (sms == '0000') : (smsCode == sms);

    if (isValidCode) {
      try {
        final profile = await _profileRepository.fetchProfileByPhone(phone);

        final token = _tokenService.generateAccessToken(profile.id.toString());
        final refreshToken = _tokenService.generateRefreshToken(profile.id.toString());
        return Response.ok(jsonEncode({"token": token, "refresh_token": refreshToken, "profile": profile, "expires_in": _tokenService.accessTokenExpiry.inSeconds}), headers: jsonContentHeaders);
      } on Object catch (e, s) {
        final profile = await _profileRepository.createUser(phone: phone);
        final token = _tokenService.generateAccessToken(profile.id.toString());
        final refreshToken = _tokenService.generateRefreshToken(profile.id.toString());

        // Отправляем уведомление в Telegram о новой регистрации
        TelegramBotService().notifyUserRegistration(userId: profile.id, phone: profile.phone, firstName: profile.firstName, lastName: profile.lastName, email: profile.email);

        return Response.ok(jsonEncode({"token": token, "refresh_token": refreshToken, "profile": profile, "expires_in": _tokenService.accessTokenExpiry.inSeconds}), headers: jsonContentHeaders);
      }
    }

    return Response.unauthorized(jsonEncode({'error': 'Invalid SMS code'}));
  }

  @Route.post('/auth/refresh')
  @OpenApiRoute()
  Future<Response> refreshToken(Request request) async {
    try {
      // Читаем тело запроса
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Проверяем наличие refresh_token
      final refreshToken = json['refresh_token']?.toString();
      if (refreshToken == null || refreshToken.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Refresh token is required'}), headers: jsonContentHeaders);
      }

      // Валидация токена через TokenService
      if (!_tokenService.validateToken(refreshToken)) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid or expired refresh token'}), headers: jsonContentHeaders);
      }

      // Проверяем тип токена
      final payload = JwtDecoder.decode(refreshToken);
      if (payload['purpose'] != 'refresh') {
        return Response.badRequest(body: jsonEncode({'error': 'Not a refresh token'}), headers: jsonContentHeaders);
      }

      // Получаем ID пользователя
      final userId = payload['sub']?.toString();
      if (userId == null || userId.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid user in token'}), headers: jsonContentHeaders);
      }

      // Генерируем новые токены
      final newAccessToken = _tokenService.generateAccessToken(userId);
      final newRefreshToken = _tokenService.generateRefreshToken(userId);
      final profile = await _profileRepository.fetchProfileById(int.parse(userId));

      return Response.ok(
        jsonEncode({"token": newAccessToken, "refresh_token": newRefreshToken, "expires_in": _tokenService.accessTokenExpiry.inSeconds, "profile": profile, "token_type": "Bearer"}),
        headers: jsonContentHeaders,
      );
    } catch (e, s) {
      print('Refresh token error: $e\n$s');
      return Response.internalServerError(body: jsonEncode({'error': 'Token refresh failed'}), headers: jsonContentHeaders);
    }
  }
}
