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
      avatarUrl: json['avatar_url'] as String?,
      averageRating: _doubleFromJsonNullable(json['average_rating']),
      reviewsCount: _intFromJsonNullable(json['reviews_count']),
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
  writeNotNull('avatar_url', instance.avatarUrl);
  writeNotNull('average_rating', instance.averageRating);
  writeNotNull('reviews_count', instance.reviewsCount);
  return val;
}
