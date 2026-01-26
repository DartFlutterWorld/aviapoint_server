import 'package:json_annotation/json_annotation.dart';

part 'news_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class NewsModel {
  NewsModel({
    required this.id,
    required this.title,
    required this.sub_title,
    required this.source,
    required this.date,
    required this.body,
    required this.picture_mini,
    required this.picture_big,
    required this.is_big_news,
    required this.category_id,
    this.author_id,
    required this.published,
    this.content,
  });

  final int id;
  final String title;
  final String sub_title;
  final String source;
  final String date;
  final String body;
  final String? content; // Quill Delta JSON
  final String picture_mini;
  final String picture_big;
  final bool is_big_news;
  final int category_id;
  @JsonKey(name: 'author_id')
  final int? author_id;
  @JsonKey(defaultValue: true)
  final bool published;

  factory NewsModel.fromJson(Map<String, dynamic> json) => _$NewsModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewsModelToJson(this);
}
