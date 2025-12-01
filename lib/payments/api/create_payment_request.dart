import 'package:json_annotation/json_annotation.dart';

part 'create_payment_request.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class CreatePaymentRequest {
  CreatePaymentRequest({
    required this.amount,
    this.currency = 'RUB',
    required this.description,
    this.returnUrl,
    this.cancelUrl,
    this.userId, // ID пользователя для связи платежа с подпиской
    this.customerPhone, // Телефон покупателя для receipt
    this.subscriptionType, // Тип подписки: 'monthly', 'quarterly', 'yearly', 'custom'
    this.periodDays, // Количество дней для кастомной подписки
  });

  final double amount;
  @JsonKey(defaultValue: 'RUB')
  final String currency;
  final String description;
  @JsonKey(name: 'return_url')
  final String? returnUrl;
  @JsonKey(name: 'cancel_url')
  final String? cancelUrl;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'customer_phone')
  final String? customerPhone;
  @JsonKey(name: 'subscription_type')
  final String? subscriptionType;
  @JsonKey(name: 'period_days')
  final int? periodDays;

  factory CreatePaymentRequest.fromJson(Map<String, dynamic> json) => _$CreatePaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentRequestToJson(this);
}
