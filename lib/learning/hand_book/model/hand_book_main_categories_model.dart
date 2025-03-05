import 'package:json_annotation/json_annotation.dart';

part 'hand_book_main_categories_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.none,
  createToJson: true,
)
class HandBookMainCategoriesModel {
  HandBookMainCategoriesModel({
    required this.mainCategoryId,
    required this.title,
    required this.subTitle,
    required this.picture,
  });

  final int mainCategoryId;
  final String title;
  final String subTitle;
  final String picture;

  factory HandBookMainCategoriesModel.fromJson(Map<String, dynamic> json) => _$HandBookMainCategoriesModelFromJson(json);

  Map<String, dynamic> toJson() => _$HandBookMainCategoriesModelToJson(this);
}
