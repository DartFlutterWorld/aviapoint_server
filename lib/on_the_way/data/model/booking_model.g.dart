// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
      id: (json['id'] as num).toInt(),
      flightId: (json['flight_id'] as num).toInt(),
      passengerId: (json['passenger_id'] as num).toInt(),
      seatsCount: (json['seats_count'] as num).toInt(),
      totalPrice: (json['total_price'] as num).toInt(),
      status: json['status'] as String?,
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
      passengerFirstName: json['passenger_first_name'] as String?,
      passengerLastName: json['passenger_last_name'] as String?,
      passengerAvatarUrl: json['passenger_avatar_url'] as String?,
      passengerPhone: json['passenger_phone'] as String?,
      passengerEmail: json['passenger_email'] as String?,
      passengerTelegram: json['passenger_telegram'] as String?,
      passengerMax: json['passenger_max'] as String?,
      passengerAverageRating:
          _doubleFromJsonNullable(json['passenger_average_rating']),
      flightDepartureDate:
          _dateTimeFromJsonNullable(json['flight_departure_date']),
      flightDepartureAirport: json['flight_departure_airport'] as String?,
      flightArrivalAirport: json['flight_arrival_airport'] as String?,
      flightWaypoints: json['flight_waypoints'],
    );

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flight_id': instance.flightId,
      'passenger_id': instance.passengerId,
      'seats_count': instance.seatsCount,
      'total_price': instance.totalPrice,
      'status': instance.status,
      'created_at': _dateTimeToJsonNullable(instance.createdAt),
      'updated_at': _dateTimeToJsonNullable(instance.updatedAt),
      'passenger_first_name': instance.passengerFirstName,
      'passenger_last_name': instance.passengerLastName,
      'passenger_avatar_url': instance.passengerAvatarUrl,
      'passenger_phone': instance.passengerPhone,
      'passenger_email': instance.passengerEmail,
      'passenger_telegram': instance.passengerTelegram,
      'passenger_max': instance.passengerMax,
      'passenger_average_rating': instance.passengerAverageRating,
      'flight_departure_date':
          _dateTimeToJsonNullable(instance.flightDepartureDate),
      'flight_departure_airport': instance.flightDepartureAirport,
      'flight_arrival_airport': instance.flightArrivalAirport,
      'flight_waypoints': instance.flightWaypoints,
    };
