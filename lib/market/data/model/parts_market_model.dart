import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'parts_market_model.g.dart';

@JsonSerializable()
class PartsMarketModel {
  final int id;
  final String title;
  final String? description;
  @JsonKey(name: 'price', fromJson: _priceFromJson)
  final int price;
  @JsonKey(name: 'parts_subcategory_id')
  final int? partsSubcategoryId;
  @JsonKey(name: 'parts_main_category_id')
  final int? partsMainCategoryId;
  @JsonKey(name: 'seller_id')
  final int sellerId;
  @JsonKey(name: 'manufacturer_id')
  final int? manufacturerId;
  @JsonKey(name: 'manufacturer_name')
  final String? manufacturerName;
  final String? location;
  @JsonKey(name: 'main_image_url')
  final String? mainImageUrl;
  @JsonKey(name: 'additional_image_urls', fromJson: _imageUrlsFromJson, toJson: _imageUrlsToJson)
  final List<String> additionalImageUrls;
  @JsonKey(name: 'part_number')
  final String? partNumber;
  @JsonKey(name: 'oem_number')
  final String? oemNumber;
  final String? condition;
  final int quantity;
  final String currency;
  @JsonKey(name: 'weight_kg', fromJson: _doubleFromJsonNullable)
  final double? weightKg;
  @JsonKey(name: 'dimensions_length_cm', fromJson: _doubleFromJsonNullable)
  final double? dimensionsLengthCm;
  @JsonKey(name: 'dimensions_width_cm', fromJson: _doubleFromJsonNullable)
  final double? dimensionsWidthCm;
  @JsonKey(name: 'dimensions_height_cm', fromJson: _doubleFromJsonNullable)
  final double? dimensionsHeightCm;
  @JsonKey(name: 'compatible_aircraft_models_text')
  final String? compatibleAircraftModelsText;
  @JsonKey(name: 'compatible_aircraft_model_ids', fromJson: _compatibleAircraftModelIdsFromJson)
  final List<int>? compatibleAircraftModelIds;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'published_until', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? publishedUntil;
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @JsonKey(name: 'favorites_count')
  final int favoritesCount;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;
  @JsonKey(name: 'sold_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? soldAt;
  @JsonKey(name: 'is_favorite', includeFromJson: false, includeToJson: false)
  final bool? isFavorite; // Флаг избранного (вычисляется отдельно)

  // Контактная информация продавца (из JOIN с profiles)
  @JsonKey(name: 'seller_first_name')
  final String? sellerFirstName;
  @JsonKey(name: 'seller_last_name')
  final String? sellerLastName;
  @JsonKey(name: 'seller_phone')
  final String? sellerPhone;
  @JsonKey(name: 'seller_telegram')
  final String? sellerTelegram;
  @JsonKey(name: 'seller_max')
  final String? sellerMax;

  // Названия категорий (из JOIN)
  @JsonKey(name: 'main_category_name')
  final String? mainCategoryName;
  @JsonKey(name: 'subcategory_name')
  final String? subcategoryName;
  @JsonKey(name: 'manufacturer_name_display')
  final String? manufacturerNameDisplay;

  PartsMarketModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.partsSubcategoryId,
    this.partsMainCategoryId,
    required this.sellerId,
    this.manufacturerId,
    this.manufacturerName,
    this.location,
    this.mainImageUrl,
    this.additionalImageUrls = const [],
    this.partNumber,
    this.oemNumber,
    this.condition,
    this.quantity = 1,
    this.currency = 'RUB',
    this.weightKg,
    this.dimensionsLengthCm,
    this.dimensionsWidthCm,
    this.dimensionsHeightCm,
    this.compatibleAircraftModelsText,
    this.compatibleAircraftModelIds,
    this.isPublished = false,
    this.isActive = true,
    this.publishedUntil,
    this.viewsCount = 0,
    this.favoritesCount = 0,
    this.createdAt,
    this.updatedAt,
    this.soldAt,
    this.isFavorite,
    this.sellerFirstName,
    this.sellerLastName,
    this.sellerPhone,
    this.sellerTelegram,
    this.sellerMax,
    this.mainCategoryName,
    this.subcategoryName,
    this.manufacturerNameDisplay,
  });

  factory PartsMarketModel.fromJson(Map<String, dynamic> json) => _$PartsMarketModelFromJson(json);
  Map<String, dynamic> toJson() => _$PartsMarketModelToJson(this);

  static List<String> _imageUrlsFromJson(dynamic json) {
    if (json == null) return [];
    if (json is String) {
      try {
        final decoded = jsonDecode(json) as List;
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    if (json is List) {
      return json.map((e) => e.toString()).toList();
    }
    return [];
  }

  static String _imageUrlsToJson(List<String> urls) {
    return jsonEncode(urls);
  }

  static DateTime? _dateTimeFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is DateTime) return json;
    if (json is String) {
      try {
        return DateTime.parse(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static String? _dateTimeToJsonNullable(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toIso8601String();
  }

  static List<int>? _compatibleAircraftModelIdsFromJson(dynamic json) {
    if (json == null) return null;
    if (json is List) {
      return json.map((e) => e is int ? e : int.tryParse(e.toString())).where((e) => e != null).cast<int>().toList();
    }
    if (json is String) {
      try {
        final decoded = jsonDecode(json) as List;
        return decoded.map((e) => e is int ? e : int.tryParse(e.toString())).where((e) => e != null).cast<int>().toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static int _priceFromJson(dynamic json) {
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) {
      // Сначала пытаемся парсить как int
      final intParsed = int.tryParse(json);
      if (intParsed != null) return intParsed;
      // Если не получилось, пытаемся парсить как double и конвертируем в int
      final doubleParsed = double.tryParse(json);
      if (doubleParsed != null) return doubleParsed.toInt();
    }
    throw ArgumentError('Cannot convert $json (${json.runtimeType}) to int');
  }

  static double? _doubleFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is double) return json;
    if (json is num) return json.toDouble();
    if (json is String) {
      final parsed = double.tryParse(json);
      if (parsed != null) return parsed;
    }
    return null;
  }
}
