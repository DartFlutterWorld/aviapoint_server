import 'package:json_annotation/json_annotation.dart';

part 'app_settings_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AppSettingsModel {
  final int id;
  final String key;
  final bool value;
  final String? description;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;

  AppSettingsModel({
    required this.id,
    required this.key,
    required this.value,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) => _$AppSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsModelToJson(this);
}

DateTime? _dateTimeFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is String) return DateTime.tryParse(json);
  if (json is DateTime) return json;
  return null;
}

String? _dateTimeToJsonNullable(DateTime? dateTime) => dateTime?.toIso8601String();
