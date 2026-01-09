import 'package:aviapoint_server/on_the_way/data/model/aircraft_model.dart';
import 'package:aviapoint_server/profiles/data/model/profile_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'blog_category_model.dart';
import 'blog_tag_model.dart';

part 'blog_article_model.g.dart';

@JsonSerializable()
class BlogArticleModel {
  final int id;
  @JsonKey(name: 'author_id')
  final int authorId;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'aircraft_model_id')
  final int? aircraftModelId;
  final String title;
  final String? excerpt;
  final String content;
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  final String status; // draft, published, archived
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'published_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? publishedAt;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;

  // Joined data
  final ProfileModel? author;
  final BlogCategoryModel? category;
  @JsonKey(name: 'aircraft_model')
  final AircraftModel? aircraftModel;
  final List<BlogTagModel>? tags;

  BlogArticleModel({
    required this.id,
    required this.authorId,
    this.categoryId,
    this.aircraftModelId,
    required this.title,
    this.excerpt,
    required this.content,
    this.coverImageUrl,
    this.status = 'draft',
    this.viewCount = 0,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.author,
    this.category,
    this.aircraftModel,
    this.tags,
  });

  factory BlogArticleModel.fromJson(Map<String, dynamic> json) {
    return BlogArticleModel(
      id: _intFromJson(json['id']),
      authorId: _intFromJson(json['author_id']),
      categoryId: _intFromJsonNullable(json['category_id']),
      aircraftModelId: _intFromJsonNullable(json['aircraft_model_id']),
      title: json['title'] as String,
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      status: json['status'] as String? ?? 'draft',
      viewCount: _intFromJsonNullable(json['view_count']) ?? 0,
      publishedAt: _dateTimeFromJsonNullable(json['published_at']),
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
      author: json['author'] != null ? ProfileModel.fromJson(json['author'] as Map<String, dynamic>) : null,
      category: json['category'] != null ? BlogCategoryModel.fromJson(json['category'] as Map<String, dynamic>) : null,
      aircraftModel: json['aircraft_model'] != null ? AircraftModel.fromJson(json['aircraft_model'] as Map<String, dynamic>) : null,
      tags: json['tags'] != null ? (json['tags'] as List).map((e) => BlogTagModel.fromJson(e as Map<String, dynamic>)).toList() : null,
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

  Map<String, dynamic> toJson() => _$BlogArticleModelToJson(this);
}

