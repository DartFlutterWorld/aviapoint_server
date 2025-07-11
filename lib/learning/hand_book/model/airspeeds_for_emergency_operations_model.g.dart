// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airspeeds_for_emergency_operations_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirspeedsForEmergencyOperationsModel
    _$AirspeedsForEmergencyOperationsModelFromJson(Map<String, dynamic> json) =>
        AirspeedsForEmergencyOperationsModel(
          id: (json['id'] as num).toInt(),
          title: json['title'] as String? ?? '',
          name: json['name'] as String,
          doing: (json['doing'] as num).toInt(),
        );

Map<String, dynamic> _$AirspeedsForEmergencyOperationsModelToJson(
        AirspeedsForEmergencyOperationsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'name': instance.name,
      'doing': instance.doing,
    };
