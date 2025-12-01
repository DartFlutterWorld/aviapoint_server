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
    this.paymentUrl,
    required this.createdAt,
    required this.paid,
    this.userId, // ID пользователя, связанного с платежом
  });

  final String id;
  final String status;
  final double amount;
  final String currency;
  final String description;
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final bool paid;
  @JsonKey(name: 'user_id')
  final int? userId;

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}
