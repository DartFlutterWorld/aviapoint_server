// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aircraft_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AircraftModel _$AircraftModelFromJson(Map<String, dynamic> json) =>
    AircraftModel(
      id: (json['id'] as num).toInt(),
      manufacturerId: (json['manufacturer_id'] as num).toInt(),
      modelCode: json['model_code'] as String,
      fullName: json['full_name'] as String,
      category: json['category'] as String?,
      engineType: json['engine_type'] as String?,
      engineCount: (json['engine_count'] as num?)?.toInt() ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: AircraftModel._dateTimeFromJsonNullable(json['created_at']),
      updatedAt: AircraftModel._dateTimeFromJsonNullable(json['updated_at']),
      manufacturer: json['manufacturer'] == null
          ? null
          : AircraftManufacturerModel.fromJson(
              json['manufacturer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AircraftModelToJson(AircraftModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'manufacturer_id': instance.manufacturerId,
      'model_code': instance.modelCode,
      'full_name': instance.fullName,
      'category': instance.category,
      'engine_type': instance.engineType,
      'engine_count': instance.engineCount,
      'is_active': instance.isActive,
      'created_at': AircraftModel._dateTimeToJsonNullable(instance.createdAt),
      'updated_at': AircraftModel._dateTimeToJsonNullable(instance.updatedAt),
      'manufacturer': instance.manufacturer,
    };
