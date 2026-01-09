import 'dart:convert';
import 'dart:math';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:crypto/crypto.dart';

class TokenService {
  final String _secretKey;
  final Duration _accessTokenExpiry;
  final Duration _refreshTokenExpiry;

  TokenService({
    required String secretKey,
    Duration? accessTokenExpiry,
    Duration? refreshTokenExpiry,
  })  : _secretKey = secretKey,
        _accessTokenExpiry = accessTokenExpiry ?? const Duration(hours: 1),
        _refreshTokenExpiry = refreshTokenExpiry ?? const Duration(days: 30);

  // Геттеры для параметров
  Duration get accessTokenExpiry => _accessTokenExpiry;
  Duration get refreshTokenExpiry => _refreshTokenExpiry;

  String generateAccessToken(String userId) => _generateJWT(userId, _accessTokenExpiry);

  String generateRefreshToken(String userId) => _generateJWT(userId, _refreshTokenExpiry, purpose: 'refresh');

  String _generateJWT(String userId, Duration expiry, {String purpose = 'access'}) {
    final header = _base64UrlEncode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}));
    // Используем UTC для iat и exp, чтобы избежать проблем с часовыми поясами
    final now = DateTime.now().toUtc();
    final payload = _base64UrlEncode(jsonEncode({
      'sub': userId,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(expiry).millisecondsSinceEpoch ~/ 1000,
      'jti': _generateSecureRandomString(32),
      if (purpose != 'access') 'purpose': purpose,
    }));

    final signature = _base64UrlEncodeBytes(Hmac(sha256, utf8.encode(_secretKey)).convert(utf8.encode('$header.$payload')).bytes);

    return '$header.$payload.$signature';
  }

  bool validateToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Token validation failed: invalid format (parts: ${parts.length})');
        return false;
      }

      if (!_verifySignature(parts[0], parts[1], parts[2])) {
        print('Token validation failed: invalid signature');
        return false;
      }

      final payloadMap = JwtDecoder.decode(token);
      // exp в JWT - это UTC timestamp в секундах
      final expiry = DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000, isUtc: true);
      final now = DateTime.now().toUtc();
      final isValid = expiry.isAfter(now);

      if (!isValid) {
        print('Token validation failed: expired. Expiry: $expiry (UTC), Now: $now (UTC)');
      }

      return isValid;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  String? getUserIdFromToken(String token) {
    try {
      return JwtDecoder.decode(token)['sub'] as String?;
    } catch (e) {
      return null;
    }
  }

  String _generateSecureRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return _base64UrlEncodeBytes(values);
  }

  bool _verifySignature(String header, String payload, String signature) {
    final computedSig = _base64UrlEncodeBytes(Hmac(sha256, utf8.encode(_secretKey)).convert(utf8.encode('$header.$payload')).bytes);
    return computedSig == signature;
  }

  String _base64UrlEncode(String input) => base64Url.encode(utf8.encode(input)).replaceAll('=', '');

  String _base64UrlEncodeBytes(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');
}
