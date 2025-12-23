// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_review_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReviewRequest _$CreateReviewRequestFromJson(Map<String, dynamic> json) =>
    CreateReviewRequest(
      bookingId: (json['booking_id'] as num).toInt(),
      reviewedId: (json['reviewed_id'] as num).toInt(),
      rating: (json['rating'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      replyToReviewId: (json['reply_to_review_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateReviewRequestToJson(
        CreateReviewRequest instance) =>
    <String, dynamic>{
      'booking_id': instance.bookingId,
      'reviewed_id': instance.reviewedId,
      'rating': instance.rating,
      'comment': instance.comment,
      'reply_to_review_id': instance.replyToReviewId,
    };
