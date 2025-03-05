// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preflight_inspection_categories_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreflightInspectionCategoriesModel _$PreflightInspectionCategoriesModelFromJson(
        Map<String, dynamic> json) =>
    PreflightInspectionCategoriesModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      mainCategoryId: (json['mainCategoryId'] as num).toInt(),
      titleEng: json['titleEng'] as String,
      picture: json['picture'] as String,
    );

Map<String, dynamic> _$PreflightInspectionCategoriesModelToJson(
        PreflightInspectionCategoriesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'mainCategoryId': instance.mainCategoryId,
      'titleEng': instance.titleEng,
      'picture': instance.picture,
    };
