import 'package:json_annotation/json_annotation.dart';

part 'blog_category_model.g.dart';

@JsonSerializable()
class BlogCategoryModel {
  final int id;
  final String name;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  final String? color;
  @JsonKey(name: 'order_index')
  final int orderIndex;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;

  BlogCategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
    this.color,
    this.orderIndex = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) {
    return BlogCategoryModel(
      id: _intFromJson(json['id']),
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
      color: json['color'] as String?,
      orderIndex: _intFromJsonNullable(json['order_index']) ?? 0,
      isActive: _boolFromJson(json['is_active']) ?? true,
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
    );
  }

  static int _intFromJson(dynamic json) {
    if (json == null) throw FormatException('Integer cannot be null');
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.parse(json);
    throw FormatException('Invalid integer format: $json');
  }

  static int? _intFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.tryParse(json);
    return null;
  }

  static bool? _boolFromJson(dynamic json) {
    if (json == null) return null;
    if (json is bool) return json;
    if (json is String) return json.toLowerCase() == 'true' || json == '1';
    if (json is int) return json != 0;
    return null;
  }

  static DateTime? _dateTimeFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is String) return DateTime.tryParse(json);
    if (json is DateTime) return json;
    return null;
  }

  static String? _dateTimeToJsonNullable(DateTime? dateTime) => dateTime?.toIso8601String();

  Map<String, dynamic> toJson() => _$BlogCategoryModelToJson(this);
}

