import 'package:json_annotation/json_annotation.dart';

part 'blog_comment_model.g.dart';

@JsonSerializable()
class BlogCommentModel {
  final int id;
  @JsonKey(name: 'article_id')
  final int articleId;
  @JsonKey(name: 'author_id')
  final int authorId;
  @JsonKey(name: 'parent_comment_id', fromJson: _intFromJsonNullable)
  final int? parentCommentId;
  final String content;
  @JsonKey(name: 'is_approved')
  final bool isApproved;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;

  // Joined data from profiles
  @JsonKey(name: 'author_first_name')
  final String? authorFirstName;
  @JsonKey(name: 'author_last_name')
  final String? authorLastName;
  @JsonKey(name: 'author_avatar_url')
  final String? authorAvatarUrl;
  @JsonKey(name: 'author_rating', fromJson: _doubleFromJsonNullable)
  final double? authorRating;

  BlogCommentModel({
    required this.id,
    required this.articleId,
    required this.authorId,
    this.parentCommentId,
    required this.content,
    this.isApproved = true,
    this.createdAt,
    this.updatedAt,
    this.authorFirstName,
    this.authorLastName,
    this.authorAvatarUrl,
    this.authorRating,
  });

  factory BlogCommentModel.fromJson(Map<String, dynamic> json) => _$BlogCommentModelFromJson(json);
  Map<String, dynamic> toJson() => _$BlogCommentModelToJson(this);
}

/// Конвертирует nullable DateTime в ISO8601 строку или null
String? _dateTimeToJsonNullable(DateTime? dateTime) => dateTime?.toIso8601String();

/// Парсит DateTime из строки, объекта DateTime или int (timestamp)
DateTime _dateTimeFromJson(dynamic json) {
  if (json == null) {
    throw FormatException('DateTime cannot be null');
  }
  if (json is String) {
    return DateTime.parse(json);
  } else if (json is DateTime) {
    return json;
  } else if (json is int) {
    return DateTime.fromMillisecondsSinceEpoch(json);
  } else {
    throw FormatException('Invalid DateTime format: $json (type: ${json.runtimeType})');
  }
}

/// Парсит nullable DateTime
DateTime? _dateTimeFromJsonNullable(dynamic json) {
  if (json == null) {
    return null;
  }
  return _dateTimeFromJson(json);
}

/// Парсит nullable int
int? _intFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is int) return json;
  if (json is num) return json.toInt();
  if (json is String) return int.tryParse(json);
  return null;
}

/// Парсит nullable double
double? _doubleFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is double) return json;
  if (json is num) return json.toDouble();
  if (json is String) return double.tryParse(json);
  return null;
}
