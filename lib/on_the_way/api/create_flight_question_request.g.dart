// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_flight_question_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateFlightQuestionRequest _$CreateFlightQuestionRequestFromJson(
        Map<String, dynamic> json) =>
    CreateFlightQuestionRequest(
      questionText: json['question_text'] as String,
    );

Map<String, dynamic> _$CreateFlightQuestionRequestToJson(
        CreateFlightQuestionRequest instance) =>
    <String, dynamic>{
      'question_text': instance.questionText,
    };
