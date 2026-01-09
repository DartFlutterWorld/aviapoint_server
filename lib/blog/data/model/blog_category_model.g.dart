// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogCategoryModel _$BlogCategoryModelFromJson(Map<String, dynamic> json) =>
    BlogCategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
      color: json['color'] as String?,
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt:
          BlogCategoryModel._dateTimeFromJsonNullable(json['created_at']),
      updatedAt:
          BlogCategoryModel._dateTimeFromJsonNullable(json['updated_at']),
    );

Map<String, dynamic> _$BlogCategoryModelToJson(BlogCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon_url': instance.iconUrl,
      'color': instance.color,
      'order_index': instance.orderIndex,
      'is_active': instance.isActive,
      'created_at':
          BlogCategoryModel._dateTimeToJsonNullable(instance.createdAt),
      'updated_at':
          BlogCategoryModel._dateTimeToJsonNullable(instance.updatedAt),
    };
