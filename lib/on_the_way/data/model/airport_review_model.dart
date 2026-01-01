import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'airport_review_model.g.dart';

@JsonSerializable()
class AirportReviewModel {
  final int id;
  @JsonKey(name: 'airport_code')
  final String airportCode;
  @JsonKey(name: 'reviewer_id')
  final int reviewerId;
  final int? rating;
  final String? comment;
  @JsonKey(name: 'photo_urls', fromJson: _photoUrlsFromJson, toJson: _photoUrlsToJson)
  final List<String>? photoUrls;
  @JsonKey(name: 'reply_to_review_id', fromJson: _intFromJsonNullable)
  final int? replyToReviewId;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;
  @JsonKey(name: 'reviewer_first_name')
  final String? reviewerFirstName;
  @JsonKey(name: 'reviewer_last_name')
  final String? reviewerLastName;
  @JsonKey(name: 'reviewer_avatar_url')
  final String? reviewerAvatarUrl;

  AirportReviewModel({
    required this.id,
    required this.airportCode,
    required this.reviewerId,
    this.rating,
    this.comment,
    this.photoUrls,
    this.replyToReviewId,
    this.createdAt,
    this.updatedAt,
    this.reviewerFirstName,
    this.reviewerLastName,
    this.reviewerAvatarUrl,
  });

  factory AirportReviewModel.fromJson(Map<String, dynamic> json) => _$AirportReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$AirportReviewModelToJson(this);
}

/// Парсит массив фотографий из JSON (может быть JSONB массив или строка)
List<String>? _photoUrlsFromJson(dynamic json) {
  if (json == null) return null;
  if (json is List) {
    return json.map((e) => e.toString()).toList();
  }
  if (json is String) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      return null;
    }
  }
  return null;
}

/// Конвертирует массив фотографий в JSON
dynamic _photoUrlsToJson(List<String>? photoUrls) {
  if (photoUrls == null || photoUrls.isEmpty) return null;
  return photoUrls;
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

