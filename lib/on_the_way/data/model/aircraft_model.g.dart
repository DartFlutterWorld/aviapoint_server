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
      'manufacturer': instance.manufacturer,
    };
