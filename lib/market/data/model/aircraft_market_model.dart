import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'aircraft_market_model.g.dart';

@JsonSerializable()
class AircraftMarketModel {
  final int id;
  final String title;
  final String? description;
  final int price;
  final String currency;
  @JsonKey(name: 'aircraft_subcategories_id')
  final int? aircraftSubcategoriesId;
  @JsonKey(name: 'seller_id')
  final int sellerId;
  final String? location;
  @JsonKey(name: 'main_image_url')
  final String? mainImageUrl;
  @JsonKey(name: 'additional_image_urls', fromJson: _imageUrlsFromJson, toJson: _imageUrlsToJson)
  final List<String> additionalImageUrls;
  final String? brand;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;
  @JsonKey(name: 'published_until', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? publishedUntil;
  @JsonKey(name: 'is_favorite', includeFromJson: false, includeToJson: false)
  final bool? isFavorite; // Флаг избранного (вычисляется отдельно)

  // Характеристики самолёта
  final int? year;
  @JsonKey(name: 'total_flight_hours')
  final int? totalFlightHours;
  @JsonKey(name: 'engine_power')
  final int? enginePower;
  @JsonKey(name: 'engine_volume')
  final int? engineVolume;
  final int? seats;
  final String? condition;

  // Продажа доли
  @JsonKey(name: 'is_share_sale')
  final bool? isShareSale;
  @JsonKey(name: 'share_numerator')
  final int? shareNumerator;
  @JsonKey(name: 'share_denominator')
  final int? shareDenominator;

  // Лизинг
  @JsonKey(name: 'is_leasing')
  final bool? isLeasing;
  @JsonKey(name: 'leasing_conditions')
  final String? leasingConditions;

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

  AircraftMarketModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.currency = 'RUB',
    this.aircraftSubcategoriesId,
    required this.sellerId,
    this.location,
    this.mainImageUrl,
    this.additionalImageUrls = const [],
    this.brand,
    this.isPublished = true,
    this.isActive = true,
    this.viewsCount = 0,
    this.createdAt,
    this.updatedAt,
    this.publishedUntil,
    this.isFavorite,
    this.year,
    this.totalFlightHours,
    this.enginePower,
    this.engineVolume,
    this.seats,
    this.condition,
    this.isShareSale,
    this.shareNumerator,
    this.shareDenominator,
    this.isLeasing,
    this.leasingConditions,
    this.sellerFirstName,
    this.sellerLastName,
    this.sellerPhone,
    this.sellerTelegram,
    this.sellerMax,
  });

  factory AircraftMarketModel.fromJson(Map<String, dynamic> json) {
    return AircraftMarketModel(
      id: _intFromJson(json['id']),
      title: json['title'] as String,
      description: json['description'] as String?,
      price: _intFromJson(json['price']),
      currency: (json['currency'] as String?) ?? 'RUB',
      aircraftSubcategoriesId: _intFromJsonNullable(json['aircraft_subcategories_id']),
      sellerId: _intFromJson(json['seller_id']),
      location: json['location'] as String?,
      mainImageUrl: (json['main_image_url'] as String?)?.isNotEmpty == true ? json['main_image_url'] as String? : null,
      additionalImageUrls: _imageUrlsFromJson(json['additional_image_urls']),
      brand: json['brand'] as String?,
      isPublished: _boolFromJson(json['is_published']) ?? true,
      isActive: _boolFromJson(json['is_active']) ?? true,
      viewsCount: _intFromJsonNullable(json['views_count']) ?? 0,
      createdAt: _dateTimeFromJsonNullable(json['created_at']),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
      publishedUntil: _dateTimeFromJsonNullable(json['published_until']),
      isFavorite: _boolFromJson(json['is_favorite']),
      year: _intFromJsonNullable(json['year']),
      totalFlightHours: _intFromJsonNullable(json['total_flight_hours']),
      enginePower: _intFromJsonNullable(json['engine_power']),
      engineVolume: _intFromJsonNullable(json['engine_volume']),
      seats: _intFromJsonNullable(json['seats']),
      condition: json['condition'] as String?,
      isShareSale: _boolFromJson(json['is_share_sale']),
      shareNumerator: _intFromJsonNullable(json['share_numerator']),
      shareDenominator: _intFromJsonNullable(json['share_denominator']),
      isLeasing: _boolFromJson(json['is_leasing']),
      leasingConditions: json['leasing_conditions'] as String?,
      sellerFirstName: json['seller_first_name'] as String?,
      sellerLastName: json['seller_last_name'] as String?,
      sellerPhone: json['seller_phone'] as String?,
      sellerTelegram: json['seller_telegram'] as String?,
      sellerMax: json['seller_max'] as String?,
    );
  }

  static int _intFromJson(dynamic json) {
    if (json == null) throw FormatException('Integer cannot be null');
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.parse(json);
    throw FormatException('Invalid integer format: $json');
  }

  static int? _intFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.tryParse(json);
    return null;
  }

  static bool? _boolFromJson(dynamic json) {
    if (json == null) return null;
    if (json is bool) return json;
    if (json is String) return json.toLowerCase() == 'true' || json == '1';
    if (json is int) return json != 0;
    return null;
  }

  static DateTime? _dateTimeFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is String) return DateTime.tryParse(json);
    if (json is DateTime) return json;
    return null;
  }

  static String? _dateTimeToJsonNullable(DateTime? dateTime) => dateTime?.toIso8601String();

  static List<String> _imageUrlsFromJson(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json.map((e) => e.toString()).where((url) => url.isNotEmpty).toList();
    }
    if (json is String) {
      try {
        final decoded = jsonDecode(json) as List;
        return decoded.map((e) => e.toString()).where((url) => url.isNotEmpty).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static dynamic _imageUrlsToJson(List<String> imageUrls) {
    return imageUrls;
  }

  Map<String, dynamic> toJson() => _$AircraftMarketModelToJson(this);
}
