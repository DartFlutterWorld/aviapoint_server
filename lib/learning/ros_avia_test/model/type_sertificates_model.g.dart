// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_sertificates_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypeSertificatesModel _$TypeSertificatesModelFromJson(
        Map<String, dynamic> json) =>
    TypeSertificatesModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$TypeSertificatesModelToJson(
        TypeSertificatesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image': instance.image,
    };
