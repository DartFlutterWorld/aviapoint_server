// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_profiles_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetProfilesRequest _$GetProfilesRequestFromJson(Map<String, dynamic> json) =>
    GetProfilesRequest(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['phone'] as String,
    );

Map<String, dynamic> _$GetProfilesRequestToJson(GetProfilesRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.email,
    };
