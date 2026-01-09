// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogTagModel _$BlogTagModelFromJson(Map<String, dynamic> json) => BlogTagModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      createdAt: BlogTagModel._dateTimeFromJsonNullable(json['created_at']),
    );

Map<String, dynamic> _$BlogTagModelToJson(BlogTagModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': BlogTagModel._dateTimeToJsonNullable(instance.createdAt),
    };
