import 'package:aviapoint_server/core/config/config.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:jose/jose.dart';

/// Сервис для верификации Apple In-App Purchases через App Store Server API
class AppleIAPService {
  final Dio _dio;
  static const String _productionUrl = 'https://api.storekit.itunes.apple.com';
  static const String _sandboxUrl = 'https://api.storekit-sandbox.itunes.apple.com';

  AppleIAPService() : _dio = Dio() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  /// Верифицирует receipt data от iOS приложения
  /// Возвращает информацию о транзакции и подписке
  Future<AppleIAPVerificationResult> verifyReceipt({
    required String receiptData,
    required String transactionId,
    String? originalTransactionId,
    bool isSandbox = false,
  }) async {
    try {
      logger.info('Verifying Apple IAP receipt: transactionId=$transactionId, isSandbox=$isSandbox');

      // Используем App Store Server API v2 для верификации
      // Для этого нужен JWT токен с ключом от App Store Connect
      final jwt = _generateJWT();
      final baseUrl = isSandbox ? _sandboxUrl : _productionUrl;

      // Получаем информацию о транзакции
      final transactionResponse = await _dio.get(
        '$baseUrl/inApps/v1/transactions/$transactionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
          },
        ),
      );

      if (transactionResponse.statusCode != 200) {
        throw Exception('Failed to verify transaction: ${transactionResponse.statusCode}');
      }

      final transactionData = transactionResponse.data as Map<String, dynamic>;
      final signedTransactionInfo = transactionData['signedTransactionInfo'] as String;

      // Декодируем JWT с информацией о транзакции
      final transactionJwt = JsonWebSignature.fromCompactSerialization(signedTransactionInfo);
      final transactionPayload = transactionJwt.unverifiedPayload.jsonContent as Map<String, dynamic>;

      logger.info('Transaction verified: ${transactionPayload['productId']}');

      // Извлекаем информацию о подписке
      final productId = transactionPayload['productId'] as String? ?? '';
      final purchaseDate = _parseTimestamp(transactionPayload['purchaseDate'] as int?);
      final expiresDate = _parseTimestamp(transactionPayload['expiresDate'] as int?);
      final originalTransactionIdFromApple = transactionPayload['originalTransactionId'] as String? ?? transactionId;
      final isTrialPeriod = transactionPayload['isTrialPeriod'] as bool? ?? false;
      final environment = transactionPayload['environment'] as String? ?? (isSandbox ? 'Sandbox' : 'Production');

      return AppleIAPVerificationResult(
        isValid: true,
        transactionId: transactionId,
        originalTransactionId: originalTransactionIdFromApple,
        productId: productId,
        purchaseDate: purchaseDate,
        expiresDate: expiresDate,
        isTrialPeriod: isTrialPeriod,
        environment: environment,
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to verify Apple IAP receipt: $e');
      logger.severe('Stack trace: $stackTrace');
      return AppleIAPVerificationResult(
        isValid: false,
        transactionId: transactionId,
        error: e.toString(),
      );
    }
  }

  /// Генерирует JWT токен для аутентификации в App Store Server API
  String _generateJWT() {
    try {
      // Получаем ключ из конфигурации
      final keyId = Config.appleIAPKeyId;
      final issuerId = Config.appleIAPIssuerId;
      final privateKey = Config.appleIAPPrivateKey;

      if (keyId.isEmpty || issuerId.isEmpty || privateKey.isEmpty) {
        throw Exception('Apple IAP credentials not configured. Please set APPLE_IAP_KEY_ID, APPLE_IAP_ISSUER_ID, and APPLE_IAP_PRIVATE_KEY environment variables.');
      }

      // Создаем JWT с ES256 подписью
      // Примечание: keyId должен быть установлен в заголовке JWT для Apple App Store Server API
      // Пакет jose может требовать дополнительной настройки для этого
      // В production может потребоваться ручная сборка JWT или использование другого пакета
      final key = JsonWebKey.fromPem(privateKey);
      
      final builder = JsonWebSignatureBuilder()
        ..jsonContent = {
          'iss': issuerId,
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'aud': 'appstoreconnect-v1',
          'bid': Config.appleBundleId,
        }
        ..addRecipient(
          key,
          algorithm: 'ES256',
        );
      
      // TODO: Добавить keyId в заголовок JWT
      // Apple требует keyId в заголовке для аутентификации
      // Может потребоваться ручная сборка JWT или использование другого подхода
      logger.info('⚠️  keyId not set in JWT header. Apple may reject the request. KeyId: $keyId');

      final jws = builder.build();
      return jws.toCompactSerialization();
    } catch (e, stackTrace) {
      logger.severe('Failed to generate JWT for Apple IAP: $e');
      logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Парсит timestamp из миллисекунд в DateTime
  DateTime? _parseTimestamp(int? timestampMs) {
    if (timestampMs == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestampMs);
  }
}

/// Результат верификации Apple IAP
class AppleIAPVerificationResult {
  final bool isValid;
  final String transactionId;
  final String? originalTransactionId;
  final String? productId;
  final DateTime? purchaseDate;
  final DateTime? expiresDate;
  final bool isTrialPeriod;
  final String? environment;
  final String? error;

  AppleIAPVerificationResult({
    required this.isValid,
    required this.transactionId,
    this.originalTransactionId,
    this.productId,
    this.purchaseDate,
    this.expiresDate,
    this.isTrialPeriod = false,
    this.environment,
    this.error,
  });
}
