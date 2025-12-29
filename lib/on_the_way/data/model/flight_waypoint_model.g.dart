// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_waypoint_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlightWaypointModel _$FlightWaypointModelFromJson(Map<String, dynamic> json) =>
    FlightWaypointModel(
      id: (json['id'] as num).toInt(),
      flightId: (json['flight_id'] as num).toInt(),
      airportCode: json['airport_code'] as String,
      sequenceOrder: (json['sequence_order'] as num).toInt(),
      arrivalTime: _dateTimeFromJsonNullable(json['arrival_time']),
      departureTime: _dateTimeFromJsonNullable(json['departure_time']),
      comment: json['comment'] as String?,
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      airportName: json['airport_name'] as String?,
      airportCity: json['airport_city'] as String?,
      airportRegion: json['airport_region'] as String?,
      airportType: json['airport_type'] as String?,
      airportIdentRu: json['airport_ident_ru'] as String?,
    );

Map<String, dynamic> _$FlightWaypointModelToJson(
        FlightWaypointModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flight_id': instance.flightId,
      'airport_code': instance.airportCode,
      'sequence_order': instance.sequenceOrder,
      'arrival_time': _dateTimeToJsonNullable(instance.arrivalTime),
      'departure_time': _dateTimeToJsonNullable(instance.departureTime),
      'comment': instance.comment,
      'created_at': _dateTimeToJsonNullable(instance.createdAt),
      'airport_name': instance.airportName,
      'airport_city': instance.airportCity,
      'airport_region': instance.airportRegion,
      'airport_type': instance.airportType,
      'airport_ident_ru': instance.airportIdentRu,
    };
