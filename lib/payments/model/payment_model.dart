import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake, createToJson: true)
class PaymentModel {
  PaymentModel({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.description,
    required this.paymentUrl,
    required this.createdAt,
    required this.paid,
    required this.userId,
    this.subscriptionTypeId = 0, // Может быть 0 для старых записей без subscription_type_id
    required this.periodDays,
    this.paymentSource = 'yookassa',
    this.appleTransactionId,
    this.appleOriginalTransactionId,
  });

  final String id;
  final String status;
  @JsonKey(fromJson: _amountFromJson)
  final double amount;
  final String currency;
  final String description;
  @JsonKey(name: 'payment_url')
  final String paymentUrl;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  final bool paid;
  @JsonKey(name: 'user_id', fromJson: _intFromJson)
  final int userId;
  @JsonKey(name: 'subscription_type_id', fromJson: _intFromJsonNullable)
  final int subscriptionTypeId;
  @JsonKey(name: 'period_days', fromJson: _intFromJson)
  final int periodDays;
  @JsonKey(name: 'payment_source')
  final String paymentSource;
  @JsonKey(name: 'apple_transaction_id')
  final String? appleTransactionId;
  @JsonKey(name: 'apple_original_transaction_id')
  final String? appleOriginalTransactionId;

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  // Конвертеры для DateTime
  static String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();
  static DateTime _dateTimeFromJson(dynamic json) {
    if (json is DateTime) {
      return json;
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    throw ArgumentError('Cannot convert $json (${json.runtimeType}) to DateTime');
  }

  // Конвертеры для числовых полей (обрабатывают строки и числа)
  static double _amountFromJson(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.parse(value);
    }
    throw ArgumentError('Cannot convert $value (${value.runtimeType}) to double');
  }

  static int _intFromJson(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.parse(value);
    }
    throw ArgumentError('Cannot convert $value (${value.runtimeType}) to int');
  }

  static int _intFromJsonNullable(dynamic value) {
    if (value == null) {
      return 0; // Дефолтное значение для старых записей
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
