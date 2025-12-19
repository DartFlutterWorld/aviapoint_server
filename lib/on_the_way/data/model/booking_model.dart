import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required int id,
    @JsonKey(name: 'flight_id') required int flightId,
    @JsonKey(name: 'passenger_id') required int passengerId,
    @JsonKey(name: 'seats_count') required int seatsCount,
    @JsonKey(name: 'total_price') required double totalPrice,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);
}
