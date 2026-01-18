import 'package:json_annotation/json_annotation.dart';

part 'price_history_model.g.dart';

@JsonSerializable()
class PriceHistoryModel {
  final int id;
  @JsonKey(name: 'aircraft_market_id')
  final int aircraftMarketId;
  final int price;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  PriceHistoryModel({
    required this.id,
    required this.aircraftMarketId,
    required this.price,
    required this.createdAt,
  });

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) {
    // Обрабатываем DateTime из PostgreSQL (может быть DateTime или String)
    DateTime createdAt;
    final createdAtValue = json['created_at'];
    if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else if (createdAtValue is String) {
      createdAt = DateTime.parse(createdAtValue);
    } else {
      throw FormatException('Invalid DateTime format for created_at: $createdAtValue');
    }

    return PriceHistoryModel(
      id: json['id'] as int,
      aircraftMarketId: json['aircraft_market_id'] as int,
      price: json['price'] as int,
      createdAt: createdAt,
    );
  }

  static DateTime _dateTimeFromJson(dynamic json) {
    if (json == null) throw FormatException('DateTime cannot be null');
    if (json is DateTime) return json;
    if (json is String) return DateTime.parse(json);
    throw FormatException('Invalid DateTime format: $json');
  }

  static String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();

  Map<String, dynamic> toJson() => _$PriceHistoryModelToJson(this);
}
