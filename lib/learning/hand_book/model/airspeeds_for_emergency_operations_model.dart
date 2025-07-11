import 'package:json_annotation/json_annotation.dart';

part 'airspeeds_for_emergency_operations_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
// Модель Воздушные скорости в аварифных ситуациях
class AirspeedsForEmergencyOperationsModel {
  AirspeedsForEmergencyOperationsModel({
    required this.id,
    required this.title,
    required this.name,
    required this.doing,
  });

  final int id;
  @JsonKey(defaultValue: '')
  final String title;
  final String name;
  final int doing;

  factory AirspeedsForEmergencyOperationsModel.fromJson(Map<String, dynamic> json) => _$AirspeedsForEmergencyOperationsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AirspeedsForEmergencyOperationsModelToJson(this);
}
