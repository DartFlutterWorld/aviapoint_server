import 'package:json_annotation/json_annotation.dart';

part 'market_category_model.g.dart';

@JsonSerializable()
class MarketCategoryModel {
  final int id;
  final String name;
  @JsonKey(name: 'name_en')
  final String? nameEn;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @JsonKey(name: 'product_type')
  final String productType; // 'aircraft' или 'parts'
  @JsonKey(name: 'parent_id')
  final int? parentId;
  @JsonKey(name: 'parts_main_category_id')
  final int? partsMainCategoryId;
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @JsonKey(name: 'is_main')
  final bool isMain;

  MarketCategoryModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.iconUrl,
    required this.productType,
    this.parentId,
    this.partsMainCategoryId,
    this.displayOrder = 0,
    this.isMain = false,
  });

  factory MarketCategoryModel.fromJson(Map<String, dynamic> json) {
    return MarketCategoryModel(
      id: _intFromJson(json['id']),
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      iconUrl: json['icon_url'] as String?,
      productType: json['product_type'] as String,
      parentId: _intFromJsonNullable(json['parent_id']),
      partsMainCategoryId: _intFromJsonNullable(json['parts_main_category_id']),
      displayOrder: _intFromJsonNullable(json['display_order']) ?? 0,
      isMain: _boolFromJson(json['is_main']) ?? false,
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

  Map<String, dynamic> toJson() => _$MarketCategoryModelToJson(this);
}
