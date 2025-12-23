import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class BookingModel {
  final int id;
  @JsonKey(name: 'flight_id')
  final int flightId;
  @JsonKey(name: 'passenger_id')
  final int passengerId;
  @JsonKey(name: 'seats_count')
  final int seatsCount;
  @JsonKey(name: 'total_price')
  final int totalPrice;
  final String? status;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;

  BookingModel({required this.id, required this.flightId, required this.passengerId, required this.seatsCount, required this.totalPrice, this.status, this.createdAt, this.updatedAt});

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);
  Map<String, dynamic> toJson() => _$BookingModelToJson(this);
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
