// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettingsModel _$AppSettingsModelFromJson(Map<String, dynamic> json) =>
    AppSettingsModel(
      id: (json['id'] as num).toInt(),
      key: json['key'] as String,
      value: _boolFromJson(json['value']),
      description: json['description'] as String?,
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
    );

Map<String, dynamic> _$AppSettingsModelToJson(AppSettingsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'description': instance.description,
      'created_at': _dateTimeToJsonNullable(instance.createdAt),
      'updated_at': _dateTimeToJsonNullable(instance.updatedAt),
    };
