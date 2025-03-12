// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hand_book_main_categories_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandBookMainCategoriesModel _$HandBookMainCategoriesModelFromJson(
        Map<String, dynamic> json) =>
    HandBookMainCategoriesModel(
      mainCategoryId: (json['main_category_id'] as num).toInt(),
      title: json['title'] as String,
      subTitle: json['sub_title'] as String,
      picture: json['picture'] as String,
    );

Map<String, dynamic> _$HandBookMainCategoriesModelToJson(
        HandBookMainCategoriesModel instance) =>
    <String, dynamic>{
      'main_category_id': instance.mainCategoryId,
      'title': instance.title,
      'sub_title': instance.subTitle,
      'picture': instance.picture,
    };
