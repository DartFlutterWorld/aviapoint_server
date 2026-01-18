// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceHistoryModel _$PriceHistoryModelFromJson(Map<String, dynamic> json) =>
    PriceHistoryModel(
      id: (json['id'] as num).toInt(),
      aircraftMarketId: (json['aircraft_market_id'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      createdAt: PriceHistoryModel._dateTimeFromJson(json['created_at']),
    );

Map<String, dynamic> _$PriceHistoryModelToJson(PriceHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'aircraft_market_id': instance.aircraftMarketId,
      'price': instance.price,
      'created_at': PriceHistoryModel._dateTimeToJson(instance.createdAt),
    };
