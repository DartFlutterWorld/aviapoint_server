import 'package:json_annotation/json_annotation.dart';

part 'app_settings_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AppSettingsModel {
  final int id;
  final String key;
  @JsonKey(fromJson: _boolFromJson)
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

/// Безопасный парсинг bool из bool, String или int (PostgreSQL может возвращать разные форматы)
bool _boolFromJson(dynamic json) {
  // Логируем для отладки
  print('🔵 [AppSettingsModel] _boolFromJson: value=$json, type=${json.runtimeType}');
  
  if (json == null) {
    throw FormatException('Boolean value cannot be null');
  }
  if (json is bool) {
    print('✅ [AppSettingsModel] _boolFromJson: returning bool value: $json');
    return json;
  }
  if (json is String) {
    final lower = json.toLowerCase();
    // PostgreSQL может вернуть 't' или 'f'
    if (lower == 'true' || lower == 't' || lower == '1') {
      print('✅ [AppSettingsModel] _boolFromJson: parsed string to true');
      return true;
    }
    if (lower == 'false' || lower == 'f' || lower == '0') {
      print('✅ [AppSettingsModel] _boolFromJson: parsed string to false');
      return false;
    }
    throw FormatException('Invalid boolean string format: $json');
  }
  if (json is int) {
    final result = json != 0;
    print('✅ [AppSettingsModel] _boolFromJson: parsed int to bool: $result');
    return result;
  }
  throw FormatException('Cannot convert ${json.runtimeType} to bool');
}

DateTime? _dateTimeFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is String) return DateTime.tryParse(json);
  if (json is DateTime) return json;
  return null;
}

String? _dateTimeToJsonNullable(DateTime? dateTime) => dateTime?.toIso8601String();
