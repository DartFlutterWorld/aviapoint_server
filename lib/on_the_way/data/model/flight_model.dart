import 'package:freezed_annotation/freezed_annotation.dart';

part 'flight_model.freezed.dart';
part 'flight_model.g.dart';

@freezed
class FlightModel with _$FlightModel {
  const factory FlightModel({
    required int id,
    @JsonKey(name: 'pilot_id') required int pilotId,
    @JsonKey(name: 'departure_airport') required String departureAirport,
    @JsonKey(name: 'arrival_airport') required String arrivalAirport,
    @JsonKey(name: 'departure_date') required DateTime departureDate,
    @JsonKey(name: 'available_seats') required int availableSeats,
    @JsonKey(name: 'price_per_seat') required double pricePerSeat,
    @JsonKey(name: 'aircraft_type') String? aircraftType,
    String? description,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _FlightModel;

  factory FlightModel.fromJson(Map<String, dynamic> json) => _$FlightModelFromJson(json);
}
