// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
      id: (json['id'] as num).toInt(),
      bookingId: (json['booking_id'] as num).toInt(),
      reviewerId: (json['reviewer_id'] as num).toInt(),
      reviewedId: (json['reviewed_id'] as num).toInt(),
      rating: (json['rating'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      replyToReviewId: _intFromJsonNullable(json['reply_to_review_id']),
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      reviewerFirstName: json['reviewer_first_name'] as String?,
      reviewerLastName: json['reviewer_last_name'] as String?,
      reviewerAvatarUrl: json['reviewer_avatar_url'] as String?,
      flightId: _intFromJsonNullable(json['flight_id']),
    );

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'reviewer_id': instance.reviewerId,
      'reviewed_id': instance.reviewedId,
      'rating': instance.rating,
      'comment': instance.comment,
      'reply_to_review_id': instance.replyToReviewId,
      'created_at': _dateTimeToJsonNullable(instance.createdAt),
      'reviewer_first_name': instance.reviewerFirstName,
      'reviewer_last_name': instance.reviewerLastName,
      'reviewer_avatar_url': instance.reviewerAvatarUrl,
      'flight_id': instance.flightId,
    };
