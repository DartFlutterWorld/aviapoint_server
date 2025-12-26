import 'package:json_annotation/json_annotation.dart';

part 'feedback_model.g.dart';

@JsonSerializable()
class FeedbackModel {
  final int id;
  @JsonKey(name: 'source_page')
  final String sourcePage; // Страница, с которой была отправлена форма
  @JsonKey(name: 'airport_code')
  final String? airportCode; // Код аэропорта (если связан с аэропортом)
  @JsonKey(name: 'flight_id')
  final int? flightId; // ID полета (если связан с полетом)
  final String? email;
  final String comment;
  final dynamic photos; // JSONB массив URL фотографий
  final String status; // pending, reviewed, resolved
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)
  final DateTime updatedAt;

  FeedbackModel({
    required this.id,
    required this.sourcePage,
    this.airportCode,
    this.flightId,
    this.email,
    required this.comment,
    this.photos,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => _$FeedbackModelFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackModelToJson(this);

  /// Парсинг DateTime из строки, объекта DateTime или int (timestamp)
  static DateTime _dateTimeFromJson(dynamic json) {
    if (json == null) {
      throw FormatException('DateTime cannot be null');
    }
    if (json is String) {
      return DateTime.parse(json);
    } else if (json is DateTime) {
      return json;
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    } else {
      throw FormatException('Invalid DateTime format: $json (type: ${json.runtimeType})');
    }
  }
}

