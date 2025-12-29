// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_flight_question_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateFlightQuestionRequest _$UpdateFlightQuestionRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateFlightQuestionRequest(
      questionText: json['question_text'] as String?,
      answerText: json['answer_text'] as String?,
    );

Map<String, dynamic> _$UpdateFlightQuestionRequestToJson(
        UpdateFlightQuestionRequest instance) =>
    <String, dynamic>{
      'question_text': instance.questionText,
      'answer_text': instance.answerText,
    };
