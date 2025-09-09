import 'package:json_annotation/json_annotation.dart';

part 'story_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  // fieldRename: FieldRename.snake,
  createToJson: true,
)
class StoryModel {
  StoryModel({
    required this.id,
    required this.image,
    this.video,
    required this.text_button,
    required this.hyperlink,
    required this.time_show,
    required this.position,
    required this.color_button,
    required this.logo_story,
    required this.text_color,
  });

  final int id;
  final String? image;
  final String? video;
  final String text_button;
  final String hyperlink;
  final int time_show;
  final int position;
  final String color_button;
  final String logo_story;
  final String text_color;

  factory StoryModel.fromJson(Map<String, dynamic> json) => _$StoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoryModelToJson(this);
}
