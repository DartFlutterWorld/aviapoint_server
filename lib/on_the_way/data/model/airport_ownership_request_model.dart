import 'package:json_annotation/json_annotation.dart';

part 'airport_ownership_request_model.g.dart';

@JsonSerializable()
class AirportOwnershipRequestModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'airport_id')
  final int airportId;
  @JsonKey(name: 'airport_code')
  final String? airportCode; // Код ICAO аэропорта
  final String email;
  final String? phone; // Телефон пользователя из профиля
  @JsonKey(name: 'phone_from_request')
  final String? phoneFromRequest; // Телефон из формы заявки
  @JsonKey(name: 'full_name')
  final String? fullName; // ФИО пользователя из формы заявки
  final dynamic documents; // JSONB массив URL документов
  final String status; // pending, approved, rejected
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)
  final DateTime updatedAt;
  @JsonKey(name: 'reviewed_at', fromJson: _dateTimeFromJsonNullable)
  final DateTime? reviewedAt;
  @JsonKey(name: 'reviewed_by', fromJson: _intFromJsonNullable)
  final int? reviewedBy;

  AirportOwnershipRequestModel({
    required this.id,
    required this.userId,
    required this.airportId,
    this.airportCode,
    required this.email,
    this.phone,
    this.phoneFromRequest,
    this.fullName,
    this.documents,
    this.status = 'pending',
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory AirportOwnershipRequestModel.fromJson(Map<String, dynamic> json) => _$AirportOwnershipRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$AirportOwnershipRequestModelToJson(this);

  /// Парсинг DateTime
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

  static DateTime? _dateTimeFromJsonNullable(dynamic json) {
    if (json == null) return null;
    return _dateTimeFromJson(json);
  }

  static int? _intFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.tryParse(json);
    return null;
  }
}

