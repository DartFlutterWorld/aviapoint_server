import 'package:airpoint_server/learning/ros_avia_test/model/question_with_answers_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ros_avia_test_category_with_questions_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Модель Воздушные скорости в аварифных ситуациях
class RosAviaTestCategoryWithQuestionsModel {
  RosAviaTestCategoryWithQuestionsModel({
    required this.categoryId,
    required this.categoryTitle,
    this.categoryImage,
    required this.categoryPosition,
    required this.questionsCount,
    required this.questionsWithAnswers,
  });

  final int categoryId;
  final String categoryTitle;
  final String? categoryImage;
  final int categoryPosition;
  final int questionsCount;
  final List<QuestionWithAnswersModel> questionsWithAnswers;

  factory RosAviaTestCategoryWithQuestionsModel.fromJson(Map<String, dynamic> json) => _$RosAviaTestCategoryWithQuestionsModelFromJson(json);

  Map<String, dynamic> toJson() => _$RosAviaTestCategoryWithQuestionsModelToJson(this);
}
