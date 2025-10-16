import 'package:json_annotation/json_annotation.dart';

part 'ros_avia_test_category_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Модель Воздушные скорости в аварифных ситуациях
class RosAviaTestCategoryModel {
  RosAviaTestCategoryModel({
    required this.id,
    required this.title,
    required this.image,
  });

  final int id;
  final String title;
  final String image;

  factory RosAviaTestCategoryModel.fromJson(Map<String, dynamic> json) => _$RosAviaTestCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$RosAviaTestCategoryModelToJson(this);
}
