import 'package:json_annotation/json_annotation.dart';

part 'create_blog_article_request.g.dart';

@JsonSerializable()
class CreateBlogArticleRequest {
  @JsonKey(name: 'category_id')
  final int? categoryId;
  
  @JsonKey(name: 'aircraft_model_id')
  final int? aircraftModelId;
  
  final String title;
  final String? excerpt;
  final String content;
  
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  
  @JsonKey(name: 'meta_title')
  final String? metaTitle;
  
  @JsonKey(name: 'meta_description')
  final String? metaDescription;
  
  final String? status;
  
  @JsonKey(name: 'is_featured')
  final bool? isFeatured;
  
  @JsonKey(name: 'tag_ids')
  final List<int>? tagIds;

  CreateBlogArticleRequest({
    this.categoryId,
    this.aircraftModelId,
    required this.title,
    this.excerpt,
    required this.content,
    this.coverImageUrl,
    this.metaTitle,
    this.metaDescription,
    this.status,
    this.isFeatured,
    this.tagIds,
  });

  factory CreateBlogArticleRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBlogArticleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBlogArticleRequestToJson(this);
}

