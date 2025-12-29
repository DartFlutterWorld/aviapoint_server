// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_waypoint_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlightWaypointRequest _$FlightWaypointRequestFromJson(
        Map<String, dynamic> json) =>
    FlightWaypointRequest(
      airportCode: json['airport_code'] as String,
      sequenceOrder: (json['sequence_order'] as num).toInt(),
      arrivalTime: _dateTimeFromJsonNullable(json['arrival_time']),
      departureTime: _dateTimeFromJsonNullable(json['departure_time']),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$FlightWaypointRequestToJson(
        FlightWaypointRequest instance) =>
    <String, dynamic>{
      'airport_code': instance.airportCode,
      'sequence_order': instance.sequenceOrder,
      'arrival_time': instance.arrivalTime?.toIso8601String(),
      'departure_time': instance.departureTime?.toIso8601String(),
      'comment': instance.comment,
    };
