// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aircraft_market_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AircraftMarketModel _$AircraftMarketModelFromJson(Map<String, dynamic> json) =>
    AircraftMarketModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toInt(),
      aircraftSubcategoriesId:
          (json['aircraft_subcategories_id'] as num?)?.toInt(),
      sellerId: (json['seller_id'] as num).toInt(),
      location: json['location'] as String?,
      mainImageUrl: json['main_image_url'] as String?,
      additionalImageUrls: json['additional_image_urls'] == null
          ? const []
          : AircraftMarketModel._imageUrlsFromJson(
              json['additional_image_urls']),
      brand: json['brand'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      createdAt:
          AircraftMarketModel._dateTimeFromJsonNullable(json['created_at']),
      updatedAt:
          AircraftMarketModel._dateTimeFromJsonNullable(json['updated_at']),
      publishedUntil: AircraftMarketModel._dateTimeFromJsonNullable(
          json['published_until']),
      year: (json['year'] as num?)?.toInt(),
      totalFlightHours: (json['total_flight_hours'] as num?)?.toInt(),
      enginePower: (json['engine_power'] as num?)?.toInt(),
      engineVolume: (json['engine_volume'] as num?)?.toInt(),
      seats: (json['seats'] as num?)?.toInt(),
      condition: json['condition'] as String?,
      isShareSale: json['is_share_sale'] as bool?,
      shareNumerator: (json['share_numerator'] as num?)?.toInt(),
      shareDenominator: (json['share_denominator'] as num?)?.toInt(),
      isLeasing: json['is_leasing'] as bool?,
      leasingConditions: json['leasing_conditions'] as String?,
      sellerFirstName: json['seller_first_name'] as String?,
      sellerLastName: json['seller_last_name'] as String?,
      sellerPhone: json['seller_phone'] as String?,
      sellerTelegram: json['seller_telegram'] as String?,
      sellerMax: json['seller_max'] as String?,
    );

Map<String, dynamic> _$AircraftMarketModelToJson(
        AircraftMarketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'aircraft_subcategories_id': instance.aircraftSubcategoriesId,
      'seller_id': instance.sellerId,
      'location': instance.location,
      'main_image_url': instance.mainImageUrl,
      'additional_image_urls':
          AircraftMarketModel._imageUrlsToJson(instance.additionalImageUrls),
      'brand': instance.brand,
      'is_active': instance.isActive,
      'views_count': instance.viewsCount,
      'created_at':
          AircraftMarketModel._dateTimeToJsonNullable(instance.createdAt),
      'updated_at':
          AircraftMarketModel._dateTimeToJsonNullable(instance.updatedAt),
      'published_until':
          AircraftMarketModel._dateTimeToJsonNullable(instance.publishedUntil),
      'year': instance.year,
      'total_flight_hours': instance.totalFlightHours,
      'engine_power': instance.enginePower,
      'engine_volume': instance.engineVolume,
      'seats': instance.seats,
      'condition': instance.condition,
      'is_share_sale': instance.isShareSale,
      'share_numerator': instance.shareNumerator,
      'share_denominator': instance.shareDenominator,
      'is_leasing': instance.isLeasing,
      'leasing_conditions': instance.leasingConditions,
      'seller_first_name': instance.sellerFirstName,
      'seller_last_name': instance.sellerLastName,
      'seller_phone': instance.sellerPhone,
      'seller_telegram': instance.sellerTelegram,
      'seller_max': instance.sellerMax,
    };
