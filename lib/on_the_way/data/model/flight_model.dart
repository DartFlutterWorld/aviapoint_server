import 'package:json_annotation/json_annotation.dart';

part 'flight_model.g.dart';

@JsonSerializable()
class FlightModel {
  final int id;
  @JsonKey(name: 'pilot_id')
  final int pilotId;
  @JsonKey(name: 'departure_airport')
  final String departureAirport;
  @JsonKey(name: 'arrival_airport')
  final String arrivalAirport;
  @JsonKey(name: 'departure_date', toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime departureDate;
  @JsonKey(name: 'available_seats')
  final int availableSeats;
  @JsonKey(name: 'total_seats')
  final int? totalSeats;
  @JsonKey(name: 'price_per_seat')
  final double pricePerSeat;
  @JsonKey(name: 'aircraft_type')
  final String? aircraftType;
  final String? description;
  final String? status;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;

  // Данные пилота (создателя полёта) - загружаются через JOIN в SQL
  @JsonKey(name: 'pilot_first_name')
  final String? pilotFirstName;
  @JsonKey(name: 'pilot_last_name')
  final String? pilotLastName;
  @JsonKey(name: 'pilot_avatar_url')
  final String? pilotAvatarUrl;
  @JsonKey(name: 'pilot_average_rating', fromJson: _doubleFromJsonNullable)
  final double? pilotAverageRating;

  FlightModel({
    required this.id,
    required this.pilotId,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureDate,
    required this.availableSeats,
    required this.pricePerSeat,
    this.totalSeats,
    this.aircraftType,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.pilotFirstName,
    this.pilotLastName,
    this.pilotAvatarUrl,
    this.pilotAverageRating,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) => _$FlightModelFromJson(json);
  Map<String, dynamic> toJson() => _$FlightModelToJson(this);
}

/// Конвертирует DateTime в ISO8601 строку
String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();

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

/// Парсит nullable double
double? _doubleFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is double) return json;
  if (json is num) return json.toDouble();
  if (json is String) return double.tryParse(json);
  return null;
}
