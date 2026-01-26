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
      author_id: (json['author_id'] as num?)?.toInt(),
      published: json['published'] as bool? ?? true,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$NewsModelToJson(NewsModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'title': instance.title,
    'sub_title': instance.sub_title,
    'source': instance.source,
    'date': instance.date,
    'body': instance.body,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('content', instance.content);
  val['picture_mini'] = instance.picture_mini;
  val['picture_big'] = instance.picture_big;
  val['is_big_news'] = instance.is_big_news;
  val['category_id'] = instance.category_id;
  writeNotNull('author_id', instance.author_id);
  val['published'] = instance.published;
  return val;
}
