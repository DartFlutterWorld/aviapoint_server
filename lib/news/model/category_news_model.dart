import 'package:json_annotation/json_annotation.dart';

part 'category_news_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class CategoryNewsModel {
  CategoryNewsModel({
    required this.id,
    required this.title,
  });

  final int id;
  final String title;

  factory CategoryNewsModel.fromJson(Map<String, dynamic> json) => _$CategoryNewsModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryNewsModelToJson(this);
}
