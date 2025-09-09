import 'package:json_annotation/json_annotation.dart';

part 'type_sertificates_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Модель Воздушные скорости в аварифных ситуациях
class TypeSertificatesModel {
  TypeSertificatesModel({
    required this.id,
    required this.title,
    required this.image,
  });

  final int id;
  final String title;
  final String image;

  factory TypeSertificatesModel.fromJson(Map<String, dynamic> json) => _$TypeSertificatesModelFromJson(json);

  Map<String, dynamic> toJson() => _$TypeSertificatesModelToJson(this);
}
