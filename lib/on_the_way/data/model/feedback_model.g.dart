// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedbackModel _$FeedbackModelFromJson(Map<String, dynamic> json) =>
    FeedbackModel(
      id: (json['id'] as num).toInt(),
      sourcePage: json['source_page'] as String,
      airportCode: json['airport_code'] as String?,
      flightId: (json['flight_id'] as num?)?.toInt(),
      email: json['email'] as String?,
      comment: json['comment'] as String,
      photos: json['photos'],
      status: json['status'] as String? ?? 'pending',
      createdAt: FeedbackModel._dateTimeFromJson(json['created_at']),
      updatedAt: FeedbackModel._dateTimeFromJson(json['updated_at']),
    );

Map<String, dynamic> _$FeedbackModelToJson(FeedbackModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_page': instance.sourcePage,
      'airport_code': instance.airportCode,
      'flight_id': instance.flightId,
      'email': instance.email,
      'comment': instance.comment,
      'photos': instance.photos,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
