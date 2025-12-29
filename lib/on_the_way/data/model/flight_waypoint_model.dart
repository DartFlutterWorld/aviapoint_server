import 'package:json_annotation/json_annotation.dart';

part 'flight_waypoint_model.g.dart';

@JsonSerializable()
class FlightWaypointModel {
  final int id;
  @JsonKey(name: 'flight_id')
  final int flightId;
  @JsonKey(name: 'airport_code')
  final String airportCode;
  @JsonKey(name: 'sequence_order')
  final int sequenceOrder;
  @JsonKey(name: 'arrival_time', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? arrivalTime;
  @JsonKey(name: 'departure_time', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? departureTime;
  final String? comment;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;

  // Дополнительная информация об аэропорте (загружается через JOIN)
  @JsonKey(name: 'airport_name')
  final String? airportName;
  @JsonKey(name: 'airport_city')
  final String? airportCity;
  @JsonKey(name: 'airport_region')
  final String? airportRegion;
  @JsonKey(name: 'airport_type')
  final String? airportType;
  @JsonKey(name: 'airport_ident_ru')
  final String? airportIdentRu;

  FlightWaypointModel({
    required this.id,
    required this.flightId,
    required this.airportCode,
    required this.sequenceOrder,
    this.arrivalTime,
    this.departureTime,
    this.comment,
    this.createdAt,
    this.airportName,
    this.airportCity,
    this.airportRegion,
    this.airportType,
    this.airportIdentRu,
  });

  factory FlightWaypointModel.fromJson(Map<String, dynamic> json) => _$FlightWaypointModelFromJson(json);
  Map<String, dynamic> toJson() => _$FlightWaypointModelToJson(this);
}

/// Конвертирует DateTime в ISO8601 строку
String? _dateTimeToJsonNullable(DateTime? dateTime) {
  return dateTime?.toIso8601String();
}

/// Парсит nullable DateTime из строки, объекта DateTime или int (timestamp)
/// Аналогично реализации в flight_model.dart и других моделях
DateTime? _dateTimeFromJsonNullable(dynamic json) {
  if (json == null) return null;
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

