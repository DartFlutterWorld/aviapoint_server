// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirportReviewModel _$AirportReviewModelFromJson(Map<String, dynamic> json) =>
    AirportReviewModel(
      id: (json['id'] as num).toInt(),
      airportCode: json['airport_code'] as String,
      reviewerId: (json['reviewer_id'] as num).toInt(),
      rating: (json['rating'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      photoUrls: _photoUrlsFromJson(json['photo_urls']),
      replyToReviewId: _intFromJsonNullable(json['reply_to_review_id']),
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
      reviewerFirstName: json['reviewer_first_name'] as String?,
      reviewerLastName: json['reviewer_last_name'] as String?,
      reviewerAvatarUrl: json['reviewer_avatar_url'] as String?,
    );

Map<String, dynamic> _$AirportReviewModelToJson(AirportReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'airport_code': instance.airportCode,
      'reviewer_id': instance.reviewerId,
      'rating': instance.rating,
      'comment': instance.comment,
      'photo_urls': _photoUrlsToJson(instance.photoUrls),
      'reply_to_review_id': instance.replyToReviewId,
      'created_at': _dateTimeToJsonNullable(instance.createdAt),
      'updated_at': _dateTimeToJsonNullable(instance.updatedAt),
      'reviewer_first_name': instance.reviewerFirstName,
      'reviewer_last_name': instance.reviewerLastName,
      'reviewer_avatar_url': instance.reviewerAvatarUrl,
    };
