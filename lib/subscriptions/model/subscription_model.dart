import 'package:json_annotation/json_annotation.dart';

part 'subscription_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class SubscriptionModel {
  SubscriptionModel({
    required this.id,
    required this.userId,
    this.paymentId,
    this.subscriptionTypeId,
    required this.periodDays,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.autoRenew = false,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'payment_id')
  final String? paymentId;
  @JsonKey(name: 'subscription_type_id')
  final int? subscriptionTypeId;
  @JsonKey(name: 'period_days')
  final int periodDays;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'auto_renew', defaultValue: false)
  final bool autoRenew;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) => _$SubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);
}

extension SubscriptionModelExtension on SubscriptionModel {
  /// Проверяет, активна ли подписка
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Возвращает количество оставшихся дней
  int get remainingDays {
    if (!isCurrentlyActive) return 0;
    final now = DateTime.now();
    final remaining = endDate.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Проверяет, истекла ли подписка
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }
}
