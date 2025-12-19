import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_booking_request.freezed.dart';
part 'create_booking_request.g.dart';

@freezed
class CreateBookingRequest with _$CreateBookingRequest {
  const factory CreateBookingRequest({@JsonKey(name: 'flight_id') required int flightId, @JsonKey(name: 'seats_count') required int seatsCount}) = _CreateBookingRequest;

  factory CreateBookingRequest.fromJson(Map<String, dynamic> json) => _$CreateBookingRequestFromJson(json);
}
