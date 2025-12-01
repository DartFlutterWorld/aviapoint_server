// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String,
      paymentUrl: json['payment_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      paid: json['paid'] as bool,
      userId: (json['user_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'status': instance.status,
    'amount': instance.amount,
    'currency': instance.currency,
    'description': instance.description,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('payment_url', instance.paymentUrl);
  val['created_at'] = instance.createdAt.toIso8601String();
  val['paid'] = instance.paid;
  writeNotNull('user_id', instance.userId);
  return val;
}
