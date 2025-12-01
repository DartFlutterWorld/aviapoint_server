import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class ProfileModel {
  ProfileModel({
    required this.id,
    required this.phone,
    this.email,
    this.firstName,
    this.lastName,
    this.subscriptionEndDate,
    this.hasActiveSubscription = false,
    this.subscriptionUpdatedAt,
  });

  final int id;
  final String phone;
  final String? email;
  final String? firstName;
  final String? lastName;

  // Денормализованные поля подписки для быстрого доступа
  @JsonKey(name: 'subscription_end_date')
  final DateTime? subscriptionEndDate;
  @JsonKey(name: 'has_active_subscription')
  final bool hasActiveSubscription;
  @JsonKey(name: 'subscription_updated_at')
  final DateTime? subscriptionUpdatedAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
