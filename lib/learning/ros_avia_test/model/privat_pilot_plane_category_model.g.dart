// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privat_pilot_plane_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivatPilotPlaneCategoryModel _$PrivatPilotPlaneCategoryModelFromJson(
        Map<String, dynamic> json) =>
    PrivatPilotPlaneCategoryModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      image: json['image'] as String,
      type_certificates_id: (json['type_certificates_id'] as num).toInt(),
    );

Map<String, dynamic> _$PrivatPilotPlaneCategoryModelToJson(
        PrivatPilotPlaneCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image': instance.image,
      'type_certificates_id': instance.type_certificates_id,
    };
