// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      paymentId: json['payment_id'] as String?,
      subscriptionTypeId: (json['subscription_type_id'] as num?)?.toInt(),
      periodDays: (json['period_days'] as num).toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool,
      autoRenew: json['auto_renew'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'user_id': instance.userId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('payment_id', instance.paymentId);
  writeNotNull('subscription_type_id', instance.subscriptionTypeId);
  val['period_days'] = instance.periodDays;
  val['start_date'] = instance.startDate.toIso8601String();
  val['end_date'] = instance.endDate.toIso8601String();
  val['is_active'] = instance.isActive;
  val['auto_renew'] = instance.autoRenew;
  val['created_at'] = instance.createdAt.toIso8601String();
  writeNotNull('updated_at', instance.updatedAt?.toIso8601String());
  return val;
}
