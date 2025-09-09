import 'package:json_annotation/json_annotation.dart';

part 'answer_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Модель Воздушные скорости в аварифных ситуациях
class AnswerModel {
  AnswerModel({
    required this.answerId,
    required this.answerText,
    required this.isCorrect,
    required this.isOfficial,
    required this.position,
  });

  final int answerId;
  final String answerText;
  final bool isCorrect;
  final bool isOfficial;
  final int position;

  factory AnswerModel.fromJson(Map<String, dynamic> json) => _$AnswerModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerModelToJson(this);
}
