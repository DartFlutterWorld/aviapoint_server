// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ros_avia_test_category_with_questions_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RosAviaTestCategoryWithQuestionsModel
    _$RosAviaTestCategoryWithQuestionsModelFromJson(
            Map<String, dynamic> json) =>
        RosAviaTestCategoryWithQuestionsModel(
          categoryId: (json['category_id'] as num).toInt(),
          categoryTitle: json['category_title'] as String,
          categoryImage: json['category_image'] as String?,
          categoryPosition: (json['category_position'] as num).toInt(),
          questionsCount: (json['questions_count'] as num).toInt(),
          questionsWithAnswers: (json['questions_with_answers']
                  as List<dynamic>)
              .map((e) =>
                  QuestionWithAnswersModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$RosAviaTestCategoryWithQuestionsModelToJson(
    RosAviaTestCategoryWithQuestionsModel instance) {
  final val = <String, dynamic>{
    'category_id': instance.categoryId,
    'category_title': instance.categoryTitle,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('category_image', instance.categoryImage);
  val['category_position'] = instance.categoryPosition;
  val['questions_count'] = instance.questionsCount;
  val['questions_with_answers'] = instance.questionsWithAnswers;
  return val;
}
