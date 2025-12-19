import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_flight_request.freezed.dart';
part 'create_flight_request.g.dart';

@freezed
class CreateFlightRequest with _$CreateFlightRequest {
  const factory CreateFlightRequest({
    @JsonKey(name: 'departure_airport') required String departureAirport,
    @JsonKey(name: 'arrival_airport') required String arrivalAirport,
    @JsonKey(name: 'departure_date') required DateTime departureDate,
    @JsonKey(name: 'available_seats') required int availableSeats,
    @JsonKey(name: 'price_per_seat') required double pricePerSeat,
    @JsonKey(name: 'aircraft_type') String? aircraftType,
    String? description,
  }) = _CreateFlightRequest;

  factory CreateFlightRequest.fromJson(Map<String, dynamic> json) => _$CreateFlightRequestFromJson(json);
}
