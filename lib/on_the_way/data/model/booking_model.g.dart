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
    };
