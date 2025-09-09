// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswerModel _$AnswerModelFromJson(Map<String, dynamic> json) => AnswerModel(
      answerId: (json['answer_id'] as num).toInt(),
      answerText: json['answer_text'] as String,
      isCorrect: json['is_correct'] as bool,
      isOfficial: json['is_official'] as bool,
      position: (json['position'] as num).toInt(),
    );

Map<String, dynamic> _$AnswerModelToJson(AnswerModel instance) =>
    <String, dynamic>{
      'answer_id': instance.answerId,
      'answer_text': instance.answerText,
      'is_correct': instance.isCorrect,
      'is_official': instance.isOfficial,
      'position': instance.position,
    };
