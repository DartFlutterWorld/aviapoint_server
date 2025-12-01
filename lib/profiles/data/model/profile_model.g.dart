// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      id: (json['id'] as num).toInt(),
      phone: json['phone'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      subscriptionEndDate: json['subscription_end_date'] == null
          ? null
          : DateTime.parse(json['subscription_end_date'] as String),
      hasActiveSubscription: json['has_active_subscription'] as bool? ?? false,
      subscriptionUpdatedAt: json['subscription_updated_at'] == null
          ? null
          : DateTime.parse(json['subscription_updated_at'] as String),
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'phone': instance.phone,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('email', instance.email);
  writeNotNull('first_name', instance.firstName);
  writeNotNull('last_name', instance.lastName);
  writeNotNull(
      'subscription_end_date', instance.subscriptionEndDate?.toIso8601String());
  val['has_active_subscription'] = instance.hasActiveSubscription;
  writeNotNull('subscription_updated_at',
      instance.subscriptionUpdatedAt?.toIso8601String());
  return val;
}
