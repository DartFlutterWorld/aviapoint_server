// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlightModel _$FlightModelFromJson(Map<String, dynamic> json) => FlightModel(
      id: (json['id'] as num).toInt(),
      pilotId: (json['pilot_id'] as num).toInt(),
      departureAirport: json['departure_airport'] as String,
      arrivalAirport: json['arrival_airport'] as String,
      departureDate: _dateTimeFromJson(json['departure_date']),
      availableSeats: (json['available_seats'] as num).toInt(),
      pricePerSeat: (json['price_per_seat'] as num).toDouble(),
      totalSeats: (json['total_seats'] as num?)?.toInt(),
      aircraftType: json['aircraft_type'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
      pilotFirstName: json['pilot_first_name'] as String?,
      pilotLastName: json['pilot_last_name'] as String?,
      pilotAvatarUrl: json['pilot_avatar_url'] as String?,
      pilotAverageRating: _doubleFromJsonNullable(json['pilot_average_rating']),
    );

Map<String, dynamic> _$FlightModelToJson(FlightModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pilot_id': instance.pilotId,
      'departure_airport': instance.departureAirport,
      'arrival_airport': instance.arrivalAirport,
      'departure_date': _dateTimeToJson(instance.departureDate),
      'available_seats': instance.availableSeats,
      'total_seats': instance.totalSeats,
      'price_per_seat': instance.pricePerSeat,
      'aircraft_type': instance.aircraftType,
      'description': instance.description,
      'status': instance.status,
      'created_at': _dateTimeToJsonNullable(instance.createdAt),
      'updated_at': _dateTimeToJsonNullable(instance.updatedAt),
      'pilot_first_name': instance.pilotFirstName,
      'pilot_last_name': instance.pilotLastName,
      'pilot_avatar_url': instance.pilotAvatarUrl,
      'pilot_average_rating': instance.pilotAverageRating,
    };
