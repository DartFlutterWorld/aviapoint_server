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
    required this.paymentId,
    required this.subscriptionTypeId,
    required this.periodDays,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.amount,
  });

  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'payment_id')
  final String paymentId;
  @JsonKey(name: 'subscription_type_id')
  final int subscriptionTypeId;
  @JsonKey(name: 'period_days')
  final int periodDays;
  @JsonKey(name: 'start_date', toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime startDate;
  @JsonKey(name: 'end_date', toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime endDate;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  final int amount; // Цена подписки из платежа

  // Конвертеры для DateTime
  static String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();
  static DateTime _dateTimeFromJson(dynamic json) {
    if (json == null) {
      throw FormatException('DateTime cannot be null');
    }
    if (json is String) {
      return DateTime.parse(json);
    } else if (json is DateTime) {
      return json;
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    } else {
      throw FormatException('Invalid DateTime format: $json (type: ${json.runtimeType})');
    }
  }

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
