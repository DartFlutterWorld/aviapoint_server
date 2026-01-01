import 'package:json_annotation/json_annotation.dart';

part 'create_airport_review_request.g.dart';

@JsonSerializable()
class CreateAirportReviewRequest {
  @JsonKey(name: 'airport_code')
  final String airportCode;
  @JsonKey(name: 'reviewer_id')
  final int reviewerId;
  final int rating;
  final String? comment;
  @JsonKey(name: 'reply_to_review_id')
  final int? replyToReviewId;

  CreateAirportReviewRequest({
    required this.airportCode,
    required this.reviewerId,
    required this.rating,
    this.comment,
    this.replyToReviewId,
  });

  factory CreateAirportReviewRequest.fromJson(Map<String, dynamic> json) => _$CreateAirportReviewRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAirportReviewRequestToJson(this);
}

