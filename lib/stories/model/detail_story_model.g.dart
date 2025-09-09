// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailStoryModel _$DetailStoryModelFromJson(Map<String, dynamic> json) =>
    DetailStoryModel(
      id: (json['id'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      image: json['image'] as String,
      buttonColor: json['button_color'] as String,
      textColor: json['text_color'] as String,
      miniStories: (json['mini_stories'] as List<dynamic>)
          .map((e) => MiniStoriesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

MiniStoriesModel _$MiniStoriesModelFromJson(Map<String, dynamic> json) =>
    MiniStoriesModel(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String?,
      video: json['video'] as String?,
      textButton: json['text_button'] as String,
      hyperlink: json['hyperlink'] as String,
      timeShow: (json['time_show'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      story: (json['story'] as num).toInt(),
    );
