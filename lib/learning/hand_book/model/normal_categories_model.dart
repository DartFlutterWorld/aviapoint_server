import 'package:json_annotation/json_annotation.dart';

part 'normal_categories_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Суб категории для Предполётных процедур
class NormalCategoriesModel {
  NormalCategoriesModel({
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

  factory NormalCategoriesModel.fromJson(Map<String, dynamic> json) => _$NormalCategoriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$NormalCategoriesModelToJson(this);
}
