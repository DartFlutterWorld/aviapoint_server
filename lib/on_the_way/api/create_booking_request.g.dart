// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_booking_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookingRequest _$CreateBookingRequestFromJson(
        Map<String, dynamic> json) =>
    CreateBookingRequest(
      flightId: (json['flight_id'] as num).toInt(),
      seatsCount: (json['seats_count'] as num).toInt(),
    );

Map<String, dynamic> _$CreateBookingRequestToJson(
        CreateBookingRequest instance) =>
    <String, dynamic>{
      'flight_id': instance.flightId,
      'seats_count': instance.seatsCount,
    };
