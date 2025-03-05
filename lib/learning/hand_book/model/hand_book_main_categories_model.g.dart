// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hand_book_main_categories_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandBookMainCategoriesModel _$HandBookMainCategoriesModelFromJson(
        Map<String, dynamic> json) =>
    HandBookMainCategoriesModel(
      mainCategoryId: (json['mainCategoryId'] as num).toInt(),
      title: json['title'] as String,
      subTitle: json['subTitle'] as String,
      picture: json['picture'] as String,
    );

Map<String, dynamic> _$HandBookMainCategoriesModelToJson(
        HandBookMainCategoriesModel instance) =>
    <String, dynamic>{
      'mainCategoryId': instance.mainCategoryId,
      'title': instance.title,
      'subTitle': instance.subTitle,
      'picture': instance.picture,
    };
