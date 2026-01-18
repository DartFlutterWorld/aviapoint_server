// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketCategoryModel _$MarketCategoryModelFromJson(Map<String, dynamic> json) =>
    MarketCategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      iconUrl: json['icon_url'] as String?,
      productType: json['product_type'] as String,
      parentId: (json['parent_id'] as num?)?.toInt(),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isMain: json['is_main'] as bool? ?? false,
    );

Map<String, dynamic> _$MarketCategoryModelToJson(
        MarketCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_en': instance.nameEn,
      'icon_url': instance.iconUrl,
      'product_type': instance.productType,
      'parent_id': instance.parentId,
      'display_order': instance.displayOrder,
      'is_main': instance.isMain,
    };
