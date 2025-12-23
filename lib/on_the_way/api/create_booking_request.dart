import 'package:json_annotation/json_annotation.dart';

part 'create_booking_request.g.dart';

@JsonSerializable()
class CreateBookingRequest {
  @JsonKey(name: 'flight_id')
  final int flightId;
  @JsonKey(name: 'seats_count')
  final int seatsCount;

  CreateBookingRequest({
    required this.flightId,
    required this.seatsCount,
  });

  factory CreateBookingRequest.fromJson(Map<String, dynamic> json) => _$CreateBookingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateBookingRequestToJson(this);
}

