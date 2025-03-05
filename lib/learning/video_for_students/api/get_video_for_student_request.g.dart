// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_video_for_student_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetVideoForStudentsRequest _$GetVideoForStudentsRequestFromJson(
        Map<String, dynamic> json) =>
    GetVideoForStudentsRequest(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$GetVideoForStudentsRequestToJson(
        GetVideoForStudentsRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
    };
