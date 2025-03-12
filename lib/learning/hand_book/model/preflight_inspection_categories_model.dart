import 'package:json_annotation/json_annotation.dart';

part 'preflight_inspection_categories_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Суб категории для Предполётных процедур
class PreflightInspectionCategoriesModel {
  PreflightInspectionCategoriesModel({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.mainCategoryId,
    required this.titleEng,
    required this.picture,
  });

  final int id;
  final String title;
  final String subTitle;
  final int mainCategoryId;
  final String titleEng;
  final String picture;

  factory PreflightInspectionCategoriesModel.fromJson(Map<String, dynamic> json) => _$PreflightInspectionCategoriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$PreflightInspectionCategoriesModelToJson(this);
}
