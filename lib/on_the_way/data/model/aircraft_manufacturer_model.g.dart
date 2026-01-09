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
    );

Map<String, dynamic> _$AircraftManufacturerModelToJson(
        AircraftManufacturerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
