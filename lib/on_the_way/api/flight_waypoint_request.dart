import 'package:json_annotation/json_annotation.dart';

part 'flight_waypoint_request.g.dart';

@JsonSerializable()
class FlightWaypointRequest {
  @JsonKey(name: 'airport_code')
  final String airportCode;
  @JsonKey(name: 'sequence_order')
  final int sequenceOrder;
  @JsonKey(name: 'arrival_time', fromJson: _dateTimeFromJsonNullable)
  final DateTime? arrivalTime;
  @JsonKey(name: 'departure_time', fromJson: _dateTimeFromJsonNullable)
  final DateTime? departureTime;
  final String? comment;

  FlightWaypointRequest({
    required this.airportCode,
    required this.sequenceOrder,
    this.arrivalTime,
    this.departureTime,
    this.comment,
  });

  factory FlightWaypointRequest.fromJson(Map<String, dynamic> json) => _$FlightWaypointRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FlightWaypointRequestToJson(this);
}

/// Парсит nullable DateTime
DateTime? _dateTimeFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is String) {
    return DateTime.parse(json);
  } else if (json is DateTime) {
    return json;
  } else if (json is int) {
    return DateTime.fromMillisecondsSinceEpoch(json);
  }
  return null;
}

