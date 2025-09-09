import 'package:json_annotation/json_annotation.dart';

part 'type_correct_answer_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Модель Воздушные скорости в аварифных ситуациях
class TypeCorrectAnswerModel {
  TypeCorrectAnswerModel({
    required this.id,
    required this.title,
  });

  final int id;
  final String title;

  factory TypeCorrectAnswerModel.fromJson(Map<String, dynamic> json) => _$TypeCorrectAnswerModelFromJson(json);

  Map<String, dynamic> toJson() => _$TypeCorrectAnswerModelToJson(this);
}
