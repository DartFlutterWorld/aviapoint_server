// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_with_answers_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionWithAnswersModel _$QuestionWithAnswersModelFromJson(
        Map<String, dynamic> json) =>
    QuestionWithAnswersModel(
      correctAnswer: (json['correct_answer'] as num?)?.toInt(),
      questionId: (json['question_id'] as num).toInt(),
      questionText: json['question_text'] as String,
      explanation: json['explanation'] as String?,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => AnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryTitle: json['category_title'] as String?,
    );

Map<String, dynamic> _$QuestionWithAnswersModelToJson(
    QuestionWithAnswersModel instance) {
  final val = <String, dynamic>{
    'question_id': instance.questionId,
    'question_text': instance.questionText,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('explanation', instance.explanation);
  writeNotNull('correct_answer', instance.correctAnswer);
  val['answers'] = instance.answers;
  writeNotNull('category_title', instance.categoryTitle);
  return val;
}
