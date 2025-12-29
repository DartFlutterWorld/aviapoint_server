import 'package:json_annotation/json_annotation.dart';

part 'flight_question_model.g.dart';

@JsonSerializable()
class FlightQuestionModel {
  final int id;
  @JsonKey(name: 'flight_id')
  final int flightId;
  @JsonKey(name: 'author_id', fromJson: _intFromJsonNullable)
  final int? authorId;
  @JsonKey(name: 'question_text')
  final String questionText;
  @JsonKey(name: 'answer_text')
  final String? answerText;
  @JsonKey(name: 'answered_by_id', fromJson: _intFromJsonNullable)
  final int? answeredById;
  @JsonKey(name: 'answered_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? answeredAt;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;
  // Данные автора вопроса (загружаются через JOIN)
  @JsonKey(name: 'author_first_name')
  final String? authorFirstName;
  @JsonKey(name: 'author_last_name')
  final String? authorLastName;
  @JsonKey(name: 'author_avatar_url')
  final String? authorAvatarUrl;
  // Данные пилота, который ответил (загружаются через JOIN)
  @JsonKey(name: 'answered_by_first_name')
  final String? answeredByFirstName;
  @JsonKey(name: 'answered_by_last_name')
  final String? answeredByLastName;
  @JsonKey(name: 'answered_by_avatar_url')
  final String? answeredByAvatarUrl;

  FlightQuestionModel({
    required this.id,
    required this.flightId,
    this.authorId,
    required this.questionText,
    this.answerText,
    this.answeredById,
    this.answeredAt,
    this.createdAt,
    this.updatedAt,
    this.authorFirstName,
    this.authorLastName,
    this.authorAvatarUrl,
    this.answeredByFirstName,
    this.answeredByLastName,
    this.answeredByAvatarUrl,
  });

  factory FlightQuestionModel.fromJson(Map<String, dynamic> json) => _$FlightQuestionModelFromJson(json);
  Map<String, dynamic> toJson() => _$FlightQuestionModelToJson(this);
}

/// Конвертирует nullable DateTime в ISO8601 строку или null
String? _dateTimeToJsonNullable(DateTime? dateTime) => dateTime?.toIso8601String();

/// Парсит DateTime из строки, объекта DateTime или int (timestamp)
DateTime _dateTimeFromJson(dynamic json) {
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

/// Парсит nullable DateTime
DateTime? _dateTimeFromJsonNullable(dynamic json) {
  if (json == null) {
    return null;
  }
  return _dateTimeFromJson(json);
}

/// Парсит nullable int
int? _intFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is int) return json;
  if (json is num) return json.toInt();
  if (json is String) return int.tryParse(json);
  return null;
}

