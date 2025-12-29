import 'package:json_annotation/json_annotation.dart';

part 'update_flight_question_request.g.dart';

@JsonSerializable()
class UpdateFlightQuestionRequest {
  @JsonKey(name: 'question_text')
  final String? questionText;
  @JsonKey(name: 'answer_text')
  final String? answerText;

  UpdateFlightQuestionRequest({this.questionText, this.answerText});

  factory UpdateFlightQuestionRequest.fromJson(Map<String, dynamic> json) => _$UpdateFlightQuestionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateFlightQuestionRequestToJson(this);
}

