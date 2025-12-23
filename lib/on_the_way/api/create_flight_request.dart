import 'package:json_annotation/json_annotation.dart';

part 'create_flight_request.g.dart';

@JsonSerializable()
class CreateFlightRequest {
  @JsonKey(name: 'departure_airport')
  final String departureAirport;
  @JsonKey(name: 'arrival_airport')
  final String arrivalAirport;
  @JsonKey(name: 'departure_date', fromJson: _dateTimeFromJson)
  final DateTime departureDate;
  @JsonKey(name: 'available_seats')
  final int availableSeats;
  @JsonKey(name: 'price_per_seat', fromJson: _doubleFromJson)
  final double pricePerSeat;
  @JsonKey(name: 'aircraft_type')
  final String? aircraftType;
  final String? description;

  CreateFlightRequest({
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureDate,
    required this.availableSeats,
    required this.pricePerSeat,
    this.aircraftType,
    this.description,
  });

  factory CreateFlightRequest.fromJson(Map<String, dynamic> json) => _$CreateFlightRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateFlightRequestToJson(this);
}

/// Конвертер для double полей из БД (приходит как строка или число)
double _doubleFromJson(dynamic value) {
  if (value is String) {
    return double.parse(value);
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  throw ArgumentError('Cannot convert $value (${value.runtimeType}) to double');
}

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
