import 'package:json_annotation/json_annotation.dart';

part 'subscription_type_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class SubscriptionTypeModel {
  SubscriptionTypeModel({
    required this.id,
    required this.code,
    required this.name,
    required this.periodDays,
    required this.price,
    required this.isActive,
    required this.createdAt,
    required this.description,
  });

  final int id;
  final String code;
  final String name;
  @JsonKey(name: 'period_days', fromJson: _intFromJson)
  final int periodDays;
  @JsonKey(fromJson: _intFromJson)
  final int price;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  final String description; // Описание типа подписки

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

  // Конвертер для integer полей из БД
  static int _intFromJson(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw ArgumentError('Cannot convert $value (${value.runtimeType}) to int');
  }

  factory SubscriptionTypeModel.fromJson(Map<String, dynamic> json) => _$SubscriptionTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionTypeModelToJson(this);
}
