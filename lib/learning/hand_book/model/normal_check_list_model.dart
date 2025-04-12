import 'package:json_annotation/json_annotation.dart';

part 'normal_check_list_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Суб категории для Предполётных процедур
class NormalCheckLisModel {
  NormalCheckLisModel({
    required this.id,
    required this.normalCategoryId,
    required this.title,
    required this.doing,
    required this.picture,
    required this.titleEng,
    required this.doingEng,
    required this.checkList,
    this.subCategory,
    this.subCategoryEng,
  });

  final int id;
  final int normalCategoryId;
  final String title;
  final String doing;
  final String? picture;
  final String titleEng;
  final String doingEng;
  final bool checkList;
  final String? subCategory;
  final String? subCategoryEng;

  factory NormalCheckLisModel.fromJson(Map<String, dynamic> json) => _$NormalCheckLisModelFromJson(json);

  Map<String, dynamic> toJson() => _$NormalCheckLisModelToJson(this);
}
