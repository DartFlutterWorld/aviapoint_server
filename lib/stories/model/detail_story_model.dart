import 'package:json_annotation/json_annotation.dart';

part 'detail_story_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: false,
)
class DetailStoryModel {
  final int id;
  final int position;
  final String image;
  final String buttonColor;
  final String textColor;
  final List<MiniStoriesModel> miniStories;

  DetailStoryModel({
    required this.id,
    required this.position,
    required this.image,
    required this.buttonColor,
    required this.textColor,
    required this.miniStories,
  });

  factory DetailStoryModel.fromJson(Map<String, dynamic> json) => _$DetailStoryModelFromJson(json);
}

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: false,
)
class MiniStoriesModel {
  final int id;
  final String? image;
  final String? video;
  final String textButton;
  final String hyperlink;
  final int timeShow;
  final int position;
  final int story;

  MiniStoriesModel({
    required this.id,
    required this.image,
    required this.video,
    required this.textButton,
    required this.hyperlink,
    required this.timeShow,
    required this.position,
    required this.story,
  });

  factory MiniStoriesModel.fromJson(Map<String, dynamic> json) => _$MiniStoriesModelFromJson(json);
}
