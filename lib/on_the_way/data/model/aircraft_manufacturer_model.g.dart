// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aircraft_manufacturer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AircraftManufacturerModel _$AircraftManufacturerModelFromJson(
        Map<String, dynamic> json) =>
    AircraftManufacturerModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      country: json['country'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: AircraftManufacturerModel._dateTimeFromJsonNullable(
          json['created_at']),
      updatedAt: AircraftManufacturerModel._dateTimeFromJsonNullable(
          json['updated_at']),
    );

Map<String, dynamic> _$AircraftManufacturerModelToJson(
        AircraftManufacturerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'website': instance.website,
      'description': instance.description,
      'is_active': instance.isActive,
      'created_at':
          AircraftManufacturerModel._dateTimeToJsonNullable(instance.createdAt),
      'updated_at':
          AircraftManufacturerModel._dateTimeToJsonNullable(instance.updatedAt),
    };
