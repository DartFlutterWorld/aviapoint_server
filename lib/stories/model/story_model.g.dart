// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryModel _$StoryModelFromJson(Map<String, dynamic> json) => StoryModel(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String?,
      video: json['video'] as String?,
      text_button: json['text_button'] as String,
      hyperlink: json['hyperlink'] as String,
      time_show: (json['time_show'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      color_button: json['color_button'] as String,
      logo_story: json['logo_story'] as String,
      text_color: json['text_color'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$StoryModelToJson(StoryModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('image', instance.image);
  writeNotNull('video', instance.video);
  val['text_button'] = instance.text_button;
  val['hyperlink'] = instance.hyperlink;
  val['time_show'] = instance.time_show;
  val['position'] = instance.position;
  val['color_button'] = instance.color_button;
  val['logo_story'] = instance.logo_story;
  val['text_color'] = instance.text_color;
  val['title'] = instance.title;
  return val;
}
