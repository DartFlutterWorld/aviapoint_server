// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_flight_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateFlightRequest _$CreateFlightRequestFromJson(Map<String, dynamic> json) =>
    CreateFlightRequest(
      departureAirport: json['departure_airport'] as String,
      arrivalAirport: json['arrival_airport'] as String,
      departureDate: _dateTimeFromJson(json['departure_date']),
      availableSeats: (json['available_seats'] as num).toInt(),
      pricePerSeat: _doubleFromJson(json['price_per_seat']),
      aircraftType: json['aircraft_type'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CreateFlightRequestToJson(
        CreateFlightRequest instance) =>
    <String, dynamic>{
      'departure_airport': instance.departureAirport,
      'arrival_airport': instance.arrivalAirport,
      'departure_date': instance.departureDate.toIso8601String(),
      'available_seats': instance.availableSeats,
      'price_per_seat': instance.pricePerSeat,
      'aircraft_type': instance.aircraftType,
      'description': instance.description,
    };
