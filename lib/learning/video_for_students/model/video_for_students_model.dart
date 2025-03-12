import 'package:json_annotation/json_annotation.dart';

part 'video_for_students_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class VideoForStudentsModel {
  VideoForStudentsModel({
    required this.id,
    required this.title,
    required this.fileName,
    required this.url,
  });

  final int id;
  final String title;
  final String fileName;
  final String url;

  factory VideoForStudentsModel.fromJson(Map<String, dynamic> json) => _$VideoForStudentsModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoForStudentsModelToJson(this);
}
