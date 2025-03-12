import 'package:json_annotation/json_annotation.dart';

part 'preflight_inspetion_check_list_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Суб категории для Предполётных процедур
class PreflightInspectionCheckLisModel {
  PreflightInspectionCheckLisModel({
    required this.id,
    required this.preflightInspectionCategoryId,
    required this.title,
    required this.doing,
    required this.picture,
    required this.titleEng,
    required this.doingEng,
  });

  final int id;
  final int preflightInspectionCategoryId;
  final String title;
  final String doing;
  final String? picture;
  final String titleEng;
  final String doingEng;

  factory PreflightInspectionCheckLisModel.fromJson(Map<String, dynamic> json) => _$PreflightInspectionCheckLisModelFromJson(json);

  Map<String, dynamic> toJson() => _$PreflightInspectionCheckLisModelToJson(this);
}
