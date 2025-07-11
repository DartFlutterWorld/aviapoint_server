import 'package:json_annotation/json_annotation.dart';

part 'emergency_categories_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Суб категории для Аварийных процедур
class EmergencyCategoriesModel {
  EmergencyCategoriesModel({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.subTitleEng,
    required this.mainCategoryId,
    required this.titleEng,
    required this.picture,
  });

  final int id;
  final String title;
  @JsonKey(defaultValue: '')
  final String subTitle;
  final int mainCategoryId;
  final String titleEng;
  @JsonKey(defaultValue: '')
  final String subTitleEng;
  @JsonKey(defaultValue: '')
  final String picture;

  factory EmergencyCategoriesModel.fromJson(Map<String, dynamic> json) => _$EmergencyCategoriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyCategoriesModelToJson(this);
}
