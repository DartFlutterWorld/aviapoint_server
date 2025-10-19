import 'package:airpoint_server/learning/ros_avia_test/model/answer_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question_with_answers_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Модель Воздушные скорости в аварифных ситуациях
class QuestionWithAnswersModel {
  QuestionWithAnswersModel({
    this.correctAnswer,
    required this.questionId,
    required this.questionText,
    this.explanation,
    required this.answers,
    this.categoryTitle,
  });

  final int questionId;
  final String questionText;
  final String? explanation;
  final int? correctAnswer;
  final List<AnswerModel> answers;
  final String? categoryTitle;

  factory QuestionWithAnswersModel.fromJson(Map<String, dynamic> json) => _$QuestionWithAnswersModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionWithAnswersModelToJson(this);
}
