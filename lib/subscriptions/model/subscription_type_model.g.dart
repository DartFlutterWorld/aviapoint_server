// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionTypeModel _$SubscriptionTypeModelFromJson(
        Map<String, dynamic> json) =>
    SubscriptionTypeModel(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      periodDays: SubscriptionTypeModel._intFromJson(json['period_days']),
      price: SubscriptionTypeModel._intFromJson(json['price']),
      isActive: json['is_active'] as bool,
      createdAt: SubscriptionTypeModel._dateTimeFromJson(json['created_at']),
      description: json['description'] as String,
    );

Map<String, dynamic> _$SubscriptionTypeModelToJson(
        SubscriptionTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'period_days': instance.periodDays,
      'price': instance.price,
      'is_active': instance.isActive,
      'created_at': SubscriptionTypeModel._dateTimeToJson(instance.createdAt),
      'description': instance.description,
    };
