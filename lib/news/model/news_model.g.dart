// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsModel _$NewsModelFromJson(Map<String, dynamic> json) => NewsModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      sub_title: json['sub_title'] as String,
      source: json['source'] as String,
      date: json['date'] as String,
      body: json['body'] as String,
      picture_mini: json['picture_mini'] as String,
      picture_big: json['picture_big'] as String,
      is_big_news: json['is_big_news'] as bool,
      category_id: (json['category_id'] as num).toInt(),
    );

Map<String, dynamic> _$NewsModelToJson(NewsModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sub_title': instance.sub_title,
      'source': instance.source,
      'date': instance.date,
      'body': instance.body,
      'picture_mini': instance.picture_mini,
      'picture_big': instance.picture_big,
      'is_big_news': instance.is_big_news,
      'category_id': instance.category_id,
    };
