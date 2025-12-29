// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlightQuestionModel _$FlightQuestionModelFromJson(Map<String, dynamic> json) =>
    FlightQuestionModel(
      id: (json['id'] as num).toInt(),
      flightId: (json['flight_id'] as num).toInt(),
      authorId: _intFromJsonNullable(json['author_id']),
      questionText: json['question_text'] as String,
      answerText: json['answer_text'] as String?,
      answeredById: _intFromJsonNullable(json['answered_by_id']),
      answeredAt: _dateTimeFromJsonNullable(json['answered_at']),
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
      authorFirstName: json['author_first_name'] as String?,
      authorLastName: json['author_last_name'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      answeredByFirstName: json['answered_by_first_name'] as String?,
      answeredByLastName: json['answered_by_last_name'] as String?,
      answeredByAvatarUrl: json['answered_by_avatar_url'] as String?,
    );

Map<String, dynamic> _$FlightQuestionModelToJson(
        FlightQuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flight_id': instance.flightId,
      'author_id': instance.authorId,
      'question_text': instance.questionText,
      'answer_text': instance.answerText,
      'answered_by_id': instance.answeredById,
      'answered_at': _dateTimeToJsonNullable(instance.answeredAt),
      'created_at': _dateTimeToJsonNullable(instance.createdAt),
      'updated_at': _dateTimeToJsonNullable(instance.updatedAt),
      'author_first_name': instance.authorFirstName,
      'author_last_name': instance.authorLastName,
      'author_avatar_url': instance.authorAvatarUrl,
      'answered_by_first_name': instance.answeredByFirstName,
      'answered_by_last_name': instance.answeredByLastName,
      'answered_by_avatar_url': instance.answeredByAvatarUrl,
    };
