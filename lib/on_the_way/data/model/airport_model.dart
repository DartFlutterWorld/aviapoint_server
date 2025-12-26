import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'airport_model.g.dart';

@JsonSerializable()
class AirportModel {
  final int id;
  
  // Основные данные из АОПА
  final bool isActive;
  final String type; // Вертодром, Аэродром и т.д.
  final String name;
  @JsonKey(name: 'name_eng')
  final String? nameEng;
  final String? city;
  final String ident; // Код аэродрома (например, HEE1)
  @JsonKey(name: 'ident_ru')
  final String? identRu; // Русский код (например, ХЕЕ1)
  @JsonKey(name: 'country_code')
  final String? countryCode; // UU-RUSSIA
  final String? country;
  @JsonKey(name: 'country_eng')
  final String? countryEng;
  final String? region;
  @JsonKey(name: 'region_eng')
  final String? regionEng;
  @JsonKey(name: 'coordinates_text')
  final String? coordinatesText; // КТА
  @JsonKey(name: 'longitude_deg')
  final double longitudeDeg;
  @JsonKey(name: 'latitude_deg')
  final double latitudeDeg;
  @JsonKey(name: 'elevation_ft')
  final int? elevationFt;
  final String? ownership; // Принадлежность
  @JsonKey(name: 'is_international')
  final bool isInternational;
  final String? email;
  final String? website;
  final String? notes;
  
  // Данные о ВПП
  @JsonKey(name: 'runway_name')
  final String? runwayName;
  @JsonKey(name: 'runway_length')
  final int? runwayLength;
  @JsonKey(name: 'runway_width')
  final int? runwayWidth;
  @JsonKey(name: 'runway_surface')
  final String? runwaySurface;
  @JsonKey(name: 'runway_magnetic_course')
  final String? runwayMagneticCourse;
  @JsonKey(name: 'runway_lighting')
  final String? runwayLighting;
  
  // Дополнительные поля
  final Map<String, dynamic>? services; // JSON объект с услугами
  @JsonKey(name: 'owner_id')
  final int? ownerId;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  final dynamic photos; // JSONB массив URL официальных фотографий
  @JsonKey(name: 'visitor_photos')
  final dynamic visitorPhotos; // JSONB массив URL фотографий посетителей
  
  // Метаданные
  final String source;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  AirportModel({
    required this.id,
    required this.isActive,
    required this.type,
    required this.name,
    this.nameEng,
    this.city,
    required this.ident,
    this.identRu,
    this.countryCode,
    this.country,
    this.countryEng,
    this.region,
    this.regionEng,
    this.coordinatesText,
    required this.longitudeDeg,
    required this.latitudeDeg,
    this.elevationFt,
    this.ownership,
    this.isInternational = false,
    this.email,
    this.website,
    this.notes,
    this.runwayName,
    this.runwayLength,
    this.runwayWidth,
    this.runwaySurface,
    this.runwayMagneticCourse,
    this.runwayLighting,
    this.services,
    this.ownerId,
    this.isVerified = false,
    this.photos,
    this.visitorPhotos,
    this.source = 'aopa',
    required this.createdAt,
    required this.updatedAt,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) {
    // Обрабатываем services как JSONB
    Map<String, dynamic>? services;
    if (json['services'] != null) {
      if (json['services'] is Map) {
        services = Map<String, dynamic>.from(json['services'] as Map);
      } else if (json['services'] is String) {
        // Если приходит как строка, парсим JSON
        try {
          services = Map<String, dynamic>.from(jsonDecode(json['services'] as String) as Map);
        } catch (e) {
          services = {};
        }
      }
    }

    return AirportModel(
      id: _intFromJson(json['id']),
      isActive: _boolFromJson(json['is_active']) ?? true,
      type: json['type'] as String,
      name: json['name'] as String,
      nameEng: json['name_eng'] as String?,
      city: json['city'] as String?,
      ident: json['ident'] as String,
      identRu: json['ident_ru'] as String?,
      countryCode: json['country_code'] as String?,
      country: json['country'] as String?,
      countryEng: json['country_eng'] as String?,
      region: json['region'] as String?,
      regionEng: json['region_eng'] as String?,
      coordinatesText: json['coordinates_text'] as String?,
      longitudeDeg: _doubleFromJson(json['longitude_deg']),
      latitudeDeg: _doubleFromJson(json['latitude_deg']),
      elevationFt: _intFromJsonNullable(json['elevation_ft']),
      ownership: json['ownership'] as String?,
      isInternational: _boolFromJson(json['is_international']) ?? false,
      email: json['email'] as String?,
      website: json['website'] as String?,
      notes: json['notes'] as String?,
      runwayName: json['runway_name'] as String?,
      runwayLength: _intFromJsonNullable(json['runway_length']),
      runwayWidth: _intFromJsonNullable(json['runway_width']),
      runwaySurface: json['runway_surface'] as String?,
      runwayMagneticCourse: json['runway_magnetic_course'] as String?,
      runwayLighting: json['runway_lighting'] as String?,
      services: services,
      ownerId: _intFromJsonNullable(json['owner_id']),
      isVerified: _boolFromJson(json['is_verified']) ?? false,
      photos: json['photos'],
      visitorPhotos: json['visitor_photos'], // Парсим фотографии посетителей
      source: json['source'] as String? ?? 'aopa',
      createdAt: _dateTimeFromJson(json['created_at']),
      updatedAt: _dateTimeFromJson(json['updated_at']),
    );
  }

  /// Безопасный парсинг int из num или String
  static int _intFromJson(dynamic json) {
    if (json == null) {
      throw FormatException('Integer cannot be null');
    }
    if (json is int) {
      return json;
    } else if (json is num) {
      return json.toInt();
    } else if (json is String) {
      return int.parse(json);
    } else {
      throw FormatException('Invalid integer format: $json (type: ${json.runtimeType})');
    }
  }

  /// Безопасный парсинг nullable int из num или String
  static int? _intFromJsonNullable(dynamic json) {
    if (json == null) {
      return null;
    }
    if (json is int) {
      return json;
    } else if (json is num) {
      return json.toInt();
    } else if (json is String) {
      return int.tryParse(json);
    } else {
      return null;
    }
  }

  /// Безопасный парсинг double из num или String
  static double _doubleFromJson(dynamic json) {
    if (json == null) {
      throw FormatException('Double cannot be null');
    }
    if (json is double) {
      return json;
    } else if (json is num) {
      return json.toDouble();
    } else if (json is String) {
      return double.parse(json);
    } else {
      throw FormatException('Invalid double format: $json (type: ${json.runtimeType})');
    }
  }

  /// Безопасный парсинг bool из bool или String
  static bool? _boolFromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    if (json is bool) {
      return json;
    } else if (json is String) {
      return json.toLowerCase() == 'true' || json == '1' || json.toLowerCase() == 'да';
    } else if (json is int) {
      return json != 0;
    } else {
      return null;
    }
  }

  /// Безопасный парсинг DateTime
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

  Map<String, dynamic> toJson() => _$AirportModelToJson(this);
}
