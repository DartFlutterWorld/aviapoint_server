import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_review_request.freezed.dart';
part 'create_review_request.g.dart';

@freezed
class CreateReviewRequest with _$CreateReviewRequest {
  const factory CreateReviewRequest({@JsonKey(name: 'booking_id') required int bookingId, @JsonKey(name: 'reviewed_id') required int reviewedId, required int rating, String? comment}) =
      _CreateReviewRequest;

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) => _$CreateReviewRequestFromJson(json);
}
