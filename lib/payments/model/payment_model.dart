import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
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
    required this.subscriptionType,
    required this.periodDays,
  });

  final String id;
  final String status;
  final double amount;
  final String currency;
  final String description;
  @JsonKey(name: 'payment_url')
  final String paymentUrl;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  final bool paid;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'subscription_type')
  final String subscriptionType;
  @JsonKey(name: 'period_days')
  final int periodDays;

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
}
