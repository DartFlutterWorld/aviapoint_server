// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_blog_article_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateBlogArticleRequest _$UpdateBlogArticleRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateBlogArticleRequest(
      categoryId: (json['category_id'] as num?)?.toInt(),
      aircraftModelId: (json['aircraft_model_id'] as num?)?.toInt(),
      title: json['title'] as String?,
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      status: json['status'] as String?,
      isFeatured: json['is_featured'] as bool?,
      tagIds: (json['tag_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UpdateBlogArticleRequestToJson(
        UpdateBlogArticleRequest instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'aircraft_model_id': instance.aircraftModelId,
      'title': instance.title,
      'excerpt': instance.excerpt,
      'content': instance.content,
      'cover_image_url': instance.coverImageUrl,
      'meta_title': instance.metaTitle,
      'meta_description': instance.metaDescription,
      'status': instance.status,
      'is_featured': instance.isFeatured,
      'tag_ids': instance.tagIds,
    };
