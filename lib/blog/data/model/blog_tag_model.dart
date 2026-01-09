import 'package:json_annotation/json_annotation.dart';

part 'blog_tag_model.g.dart';

@JsonSerializable()
class BlogTagModel {
  final int id;
  final String name;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;

  BlogTagModel({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory BlogTagModel.fromJson(Map<String, dynamic> json) {
    return BlogTagModel(
      id: _intFromJson(json['id']),
      name: json['name'] as String,
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
    );
  }

  static int _intFromJson(dynamic json) {
    if (json == null) throw FormatException('Integer cannot be null');
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.parse(json);
    throw FormatException('Invalid integer format: $json');
  }

  static DateTime? _dateTimeFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is String) return DateTime.tryParse(json);
    if (json is DateTime) return json;
    return null;
  }

  static String? _dateTimeToJsonNullable(DateTime? dateTime) => dateTime?.toIso8601String();

  Map<String, dynamic> toJson() => _$BlogTagModelToJson(this);
}

