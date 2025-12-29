import 'package:json_annotation/json_annotation.dart';

part 'create_flight_question_request.g.dart';

@JsonSerializable()
class CreateFlightQuestionRequest {
  @JsonKey(name: 'question_text')
  final String questionText;

  CreateFlightQuestionRequest({required this.questionText});

  factory CreateFlightQuestionRequest.fromJson(Map<String, dynamic> json) => _$CreateFlightQuestionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateFlightQuestionRequestToJson(this);
}

