// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parts_market_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartsMarketModel _$PartsMarketModelFromJson(Map<String, dynamic> json) =>
    PartsMarketModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      price: PartsMarketModel._priceFromJson(json['price']),
      partsSubcategoryId: (json['parts_subcategory_id'] as num?)?.toInt(),
      partsMainCategoryId: (json['parts_main_category_id'] as num?)?.toInt(),
      sellerId: (json['seller_id'] as num).toInt(),
      manufacturerId: (json['manufacturer_id'] as num?)?.toInt(),
      manufacturerName: json['manufacturer_name'] as String?,
      location: json['location'] as String?,
      mainImageUrl: json['main_image_url'] as String?,
      additionalImageUrls: json['additional_image_urls'] == null
          ? const []
          : PartsMarketModel._imageUrlsFromJson(json['additional_image_urls']),
      partNumber: json['part_number'] as String?,
      oemNumber: json['oem_number'] as String?,
      condition: json['condition'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      currency: json['currency'] as String? ?? 'RUB',
      weightKg: PartsMarketModel._doubleFromJsonNullable(json['weight_kg']),
      dimensionsLengthCm: PartsMarketModel._doubleFromJsonNullable(
          json['dimensions_length_cm']),
      dimensionsWidthCm:
          PartsMarketModel._doubleFromJsonNullable(json['dimensions_width_cm']),
      dimensionsHeightCm: PartsMarketModel._doubleFromJsonNullable(
          json['dimensions_height_cm']),
      compatibleAircraftModelsText:
          json['compatible_aircraft_models_text'] as String?,
      compatibleAircraftModelIds:
          PartsMarketModel._compatibleAircraftModelIdsFromJson(
              json['compatible_aircraft_model_ids']),
      isPublished: json['is_published'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      publishedUntil:
          PartsMarketModel._dateTimeFromJsonNullable(json['published_until']),
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      favoritesCount: (json['favorites_count'] as num?)?.toInt() ?? 0,
      createdAt: PartsMarketModel._dateTimeFromJsonNullable(json['created_at']),
      updatedAt: PartsMarketModel._dateTimeFromJsonNullable(json['updated_at']),
      soldAt: PartsMarketModel._dateTimeFromJsonNullable(json['sold_at']),
      sellerFirstName: json['seller_first_name'] as String?,
      sellerLastName: json['seller_last_name'] as String?,
      sellerPhone: json['seller_phone'] as String?,
      sellerTelegram: json['seller_telegram'] as String?,
      sellerMax: json['seller_max'] as String?,
      mainCategoryName: json['main_category_name'] as String?,
      subcategoryName: json['subcategory_name'] as String?,
      manufacturerNameDisplay: json['manufacturer_name_display'] as String?,
    );

Map<String, dynamic> _$PartsMarketModelToJson(PartsMarketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'parts_subcategory_id': instance.partsSubcategoryId,
      'parts_main_category_id': instance.partsMainCategoryId,
      'seller_id': instance.sellerId,
      'manufacturer_id': instance.manufacturerId,
      'manufacturer_name': instance.manufacturerName,
      'location': instance.location,
      'main_image_url': instance.mainImageUrl,
      'additional_image_urls':
          PartsMarketModel._imageUrlsToJson(instance.additionalImageUrls),
      'part_number': instance.partNumber,
      'oem_number': instance.oemNumber,
      'condition': instance.condition,
      'quantity': instance.quantity,
      'currency': instance.currency,
      'weight_kg': instance.weightKg,
      'dimensions_length_cm': instance.dimensionsLengthCm,
      'dimensions_width_cm': instance.dimensionsWidthCm,
      'dimensions_height_cm': instance.dimensionsHeightCm,
      'compatible_aircraft_models_text': instance.compatibleAircraftModelsText,
      'compatible_aircraft_model_ids': instance.compatibleAircraftModelIds,
      'is_published': instance.isPublished,
      'is_active': instance.isActive,
      'published_until':
          PartsMarketModel._dateTimeToJsonNullable(instance.publishedUntil),
      'views_count': instance.viewsCount,
      'favorites_count': instance.favoritesCount,
      'created_at':
          PartsMarketModel._dateTimeToJsonNullable(instance.createdAt),
      'updated_at':
          PartsMarketModel._dateTimeToJsonNullable(instance.updatedAt),
      'sold_at': PartsMarketModel._dateTimeToJsonNullable(instance.soldAt),
      'seller_first_name': instance.sellerFirstName,
      'seller_last_name': instance.sellerLastName,
      'seller_phone': instance.sellerPhone,
      'seller_telegram': instance.sellerTelegram,
      'seller_max': instance.sellerMax,
      'main_category_name': instance.mainCategoryName,
      'subcategory_name': instance.subcategoryName,
      'manufacturer_name_display': instance.manufacturerNameDisplay,
    };
