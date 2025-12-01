// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentRequest _$CreatePaymentRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePaymentRequest(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'RUB',
      description: json['description'] as String,
      returnUrl: json['return_url'] as String?,
      cancelUrl: json['cancel_url'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
      customerPhone: json['customer_phone'] as String?,
      subscriptionType: json['subscription_type'] as String?,
      periodDays: (json['period_days'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreatePaymentRequestToJson(
    CreatePaymentRequest instance) {
  final val = <String, dynamic>{
    'amount': instance.amount,
    'currency': instance.currency,
    'description': instance.description,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('return_url', instance.returnUrl);
  writeNotNull('cancel_url', instance.cancelUrl);
  writeNotNull('user_id', instance.userId);
  writeNotNull('customer_phone', instance.customerPhone);
  writeNotNull('subscription_type', instance.subscriptionType);
  writeNotNull('period_days', instance.periodDays);
  return val;
}
