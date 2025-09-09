// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_news_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryNewsModel _$CategoryNewsModelFromJson(Map<String, dynamic> json) =>
    CategoryNewsModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$CategoryNewsModelToJson(CategoryNewsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };
