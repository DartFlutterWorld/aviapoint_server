import 'package:json_annotation/json_annotation.dart';

part 'create_review_request.g.dart';

@JsonSerializable()
class CreateReviewRequest {
  @JsonKey(name: 'booking_id')
  final int bookingId;
  @JsonKey(name: 'reviewed_id')
  final int reviewedId;
  final int? rating;
  final String? comment;
  @JsonKey(name: 'reply_to_review_id')
  final int? replyToReviewId;

  CreateReviewRequest({required this.bookingId, required this.reviewedId, this.rating, this.comment, this.replyToReviewId});

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) => _$CreateReviewRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReviewRequestToJson(this);
}
