// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogCategory _$BlogCategoryFromJson(Map<String, dynamic> json) => BlogCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      color: json['color'] as String? ?? '#0A6EFA',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: BlogCategory._dateTimeFromJsonNullable(json['created_at']),
      updatedAt: BlogCategory._dateTimeFromJsonNullable(json['updated_at']),
    );

Map<String, dynamic> _$BlogCategoryToJson(BlogCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'color': instance.color,
      'order_index': instance.orderIndex,
      'is_active': instance.isActive,
      'created_at': BlogCategory._dateTimeToJsonNullable(instance.createdAt),
      'updated_at': BlogCategory._dateTimeToJsonNullable(instance.updatedAt),
    };
