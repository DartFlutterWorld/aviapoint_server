import 'package:json_annotation/json_annotation.dart';

part 'privat_pilot_plane_category_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Модель Воздушные скорости в аварифных ситуациях
class PrivatPilotPlaneCategoryModel {
  PrivatPilotPlaneCategoryModel({
    required this.id,
    required this.title,
    required this.image,
    required this.type_certificates_id,
  });

  final int id;
  final String title;
  final String image;
  final int type_certificates_id;

  factory PrivatPilotPlaneCategoryModel.fromJson(Map<String, dynamic> json) => _$PrivatPilotPlaneCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$PrivatPilotPlaneCategoryModelToJson(this);
}
