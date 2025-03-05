// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_for_students_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoForStudentsModel _$VideoForStudentsModelFromJson(
        Map<String, dynamic> json) =>
    VideoForStudentsModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      fileName: json['fileName'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$VideoForStudentsModelToJson(
        VideoForStudentsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'fileName': instance.fileName,
      'url': instance.url,
    };
