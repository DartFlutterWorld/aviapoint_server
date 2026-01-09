import 'package:json_annotation/json_annotation.dart';

part 'blog_category.g.dart';

@JsonSerializable()
class BlogCategory {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  final String color;
  @JsonKey(name: 'order_index')
  final int orderIndex;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;

  BlogCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.color = '#0A6EFA',
    this.orderIndex = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory BlogCategory.fromJson(Map<String, dynamic> json) {
    return BlogCategory(
      id: _intFromJson(json['id']),
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      color: json['color'] as String? ?? '#0A6EFA',
      orderIndex: _intFromJsonNullable(json['order_index']) ?? 0,
      isActive: _boolFromJson(json['is_active']) ?? true,
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => _$BlogCategoryToJson(this);

  static int _intFromJson(dynamic json) => json is int ? json : int.parse(json.toString());
  static int? _intFromJsonNullable(dynamic json) => json == null ? null : (json is int ? json : int.tryParse(json.toString()));
  static bool? _boolFromJson(dynamic json) => json is bool ? json : (json == null ? null : json.toString() == 'true' || json == 1);
  static DateTime? _dateTimeFromJsonNullable(dynamic json) => json == null ? null : (json is DateTime ? json : DateTime.parse(json.toString()));
  static String? _dateTimeToJsonNullable(DateTime? dateTime) => dateTime?.toIso8601String();
}

