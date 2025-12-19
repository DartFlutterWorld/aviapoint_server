import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required int id,
    @JsonKey(name: 'booking_id') required int bookingId,
    @JsonKey(name: 'reviewer_id') required int reviewerId,
    @JsonKey(name: 'reviewed_id') required int reviewedId,
    required int rating,
    String? comment,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);
}
