import 'package:json_annotation/json_annotation.dart';

part 'update_blog_article_request.g.dart';

@JsonSerializable()
class UpdateBlogArticleRequest {
  @JsonKey(name: 'category_id')
  final int? categoryId;
  
  @JsonKey(name: 'aircraft_model_id')
  final int? aircraftModelId;
  
  final String? title;
  final String? excerpt;
  final String? content;
  
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

  UpdateBlogArticleRequest({
    this.categoryId,
    this.aircraftModelId,
    this.title,
    this.excerpt,
    this.content,
    this.coverImageUrl,
    this.metaTitle,
    this.metaDescription,
    this.status,
    this.isFeatured,
    this.tagIds,
  });

  factory UpdateBlogArticleRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBlogArticleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBlogArticleRequestToJson(this);
}

