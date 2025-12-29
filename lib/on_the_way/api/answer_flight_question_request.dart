import 'package:json_annotation/json_annotation.dart';

part 'answer_flight_question_request.g.dart';

@JsonSerializable()
class AnswerFlightQuestionRequest {
  @JsonKey(name: 'answer_text')
  final String answerText;

  AnswerFlightQuestionRequest({required this.answerText});

  factory AnswerFlightQuestionRequest.fromJson(Map<String, dynamic> json) => _$AnswerFlightQuestionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerFlightQuestionRequestToJson(this);
}

