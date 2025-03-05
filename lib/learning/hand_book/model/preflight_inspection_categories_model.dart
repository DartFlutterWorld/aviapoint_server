import 'package:json_annotation/json_annotation.dart';

part 'preflight_inspection_categories_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.none,
  createToJson: true,
)
// Суб категории для Предполётных процедур
class PreflightInspectionCategoriesModel {
  PreflightInspectionCategoriesModel({
    required this.id,
    required this.title,
    required this.mainCategoryId,
    required this.titleEng,
    required this.picture,
  });

  final int id;
  final String title;
  final int mainCategoryId;
  final String titleEng;
  final String picture;

  factory PreflightInspectionCategoriesModel.fromJson(Map<String, dynamic> json) => _$PreflightInspectionCategoriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$PreflightInspectionCategoriesModelToJson(this);
}
