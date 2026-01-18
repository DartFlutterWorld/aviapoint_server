import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake, createToJson: true)
class ProfileModel {
  ProfileModel({
    required this.id,
    required this.phone,
    this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.telegram,
    this.max,
    this.averageRating,
    this.reviewsCount,
    this.ownedAirports,
    this.isAdmin = false,
  });

  final int id;
  final String phone;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? telegram;
  final String? max;
  @JsonKey(fromJson: _doubleFromJsonNullable)
  final double? averageRating;
  @JsonKey(fromJson: _intFromJsonNullable)
  final int? reviewsCount;
  final dynamic ownedAirports; // JSONB массив ID аэропортов
  @JsonKey(defaultValue: false)
  final bool isAdmin;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}

/// Парсит nullable double
double? _doubleFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is double) return json;
  if (json is num) return json.toDouble();
  if (json is String) return double.tryParse(json);
  return null;
}

/// Парсит nullable int
int? _intFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is int) return json;
  if (json is num) return json.toInt();
  if (json is String) return int.tryParse(json);
  return null;
}
