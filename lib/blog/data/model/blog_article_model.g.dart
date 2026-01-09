// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_article_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogArticleModel _$BlogArticleModelFromJson(Map<String, dynamic> json) =>
    BlogArticleModel(
      id: (json['id'] as num).toInt(),
      authorId: (json['author_id'] as num).toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      aircraftModelId: (json['aircraft_model_id'] as num?)?.toInt(),
      title: json['title'] as String,
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      status: json['status'] as String? ?? 'draft',
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      publishedAt:
          BlogArticleModel._dateTimeFromJsonNullable(json['published_at']),
      createdAt: BlogArticleModel._dateTimeFromJsonNullable(json['created_at']),
      updatedAt: BlogArticleModel._dateTimeFromJsonNullable(json['updated_at']),
      author: json['author'] == null
          ? null
          : ProfileModel.fromJson(json['author'] as Map<String, dynamic>),
      category: json['category'] == null
          ? null
          : BlogCategoryModel.fromJson(
              json['category'] as Map<String, dynamic>),
      aircraftModel: json['aircraft_model'] == null
          ? null
          : AircraftModel.fromJson(
              json['aircraft_model'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => BlogTagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BlogArticleModelToJson(BlogArticleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_id': instance.authorId,
      'category_id': instance.categoryId,
      'aircraft_model_id': instance.aircraftModelId,
      'title': instance.title,
      'excerpt': instance.excerpt,
      'content': instance.content,
      'cover_image_url': instance.coverImageUrl,
      'status': instance.status,
      'view_count': instance.viewCount,
      'published_at':
          BlogArticleModel._dateTimeToJsonNullable(instance.publishedAt),
      'created_at':
          BlogArticleModel._dateTimeToJsonNullable(instance.createdAt),
      'updated_at':
          BlogArticleModel._dateTimeToJsonNullable(instance.updatedAt),
      'author': instance.author,
      'category': instance.category,
      'aircraft_model': instance.aircraftModel,
      'tags': instance.tags,
    };
