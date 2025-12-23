import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel {
  final int id;
  @JsonKey(name: 'booking_id')
  final int bookingId;
  @JsonKey(name: 'reviewer_id')
  final int reviewerId;
  @JsonKey(name: 'reviewed_id')
  final int reviewedId;
  final int? rating;
  final String? comment;
  @JsonKey(name: 'reply_to_review_id', fromJson: _intFromJsonNullable)
  final int? replyToReviewId;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'reviewer_first_name')
  final String? reviewerFirstName;
  @JsonKey(name: 'reviewer_last_name')
  final String? reviewerLastName;
  @JsonKey(name: 'reviewer_avatar_url')
  final String? reviewerAvatarUrl;
  @JsonKey(name: 'flight_id', fromJson: _intFromJsonNullable)
  final int? flightId;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewedId,
    this.rating,
    this.comment,
    this.replyToReviewId,
    this.createdAt,
    this.reviewerFirstName,
    this.reviewerLastName,
    this.reviewerAvatarUrl,
    this.flightId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
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

/// Парсит int (не nullable)
int _intFromJson(dynamic json) {
  if (json is int) return json;
  if (json is num) return json.toInt();
  if (json is String) return int.parse(json);
  throw FormatException('Cannot parse int from $json');
}
