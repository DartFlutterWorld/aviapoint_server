// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      paymentId: json['payment_id'] as String,
      subscriptionTypeId: (json['subscription_type_id'] as num).toInt(),
      periodDays: (json['period_days'] as num).toInt(),
      startDate: SubscriptionModel._dateTimeFromJson(json['start_date']),
      endDate: SubscriptionModel._dateTimeFromJson(json['end_date']),
      isActive: json['is_active'] as bool,
      createdAt: SubscriptionModel._dateTimeFromJson(json['created_at']),
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'payment_id': instance.paymentId,
      'subscription_type_id': instance.subscriptionTypeId,
      'period_days': instance.periodDays,
      'start_date': SubscriptionModel._dateTimeToJson(instance.startDate),
      'end_date': SubscriptionModel._dateTimeToJson(instance.endDate),
      'is_active': instance.isActive,
      'created_at': SubscriptionModel._dateTimeToJson(instance.createdAt),
      'amount': instance.amount,
    };
