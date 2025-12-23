import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'airport_model.g.dart';

@JsonSerializable()
class AirportModel {
  final int id;
  final String ident; // ICAO код
  final String type; // airport, heliport, seaplane_base, etc.
  final String name;
  final double latitudeDeg;
  final double longitudeDeg;
  final int? elevationFt;
  final String? continent;
  final String isoCountry; // RU, US, etc.
  final String? isoRegion; // RU-MOW, US-CA, etc.
  final String? municipality; // Город
  final String? scheduledService; // yes/no
  final String? gpsCode;
  final String? iataCode; // IATA код
  final String? localCode;

  // Расширяемые поля
  final Map<String, dynamic>? services; // JSON объект с услугами
  final int? ownerId; // Владелец аэропорта
  final bool isVerified;
  final bool isActive;

  // Метаданные
  final String source; // ourairports, manual, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  AirportModel({
    required this.id,
    required this.ident,
    required this.type,
    required this.name,
    required this.latitudeDeg,
    required this.longitudeDeg,
    this.elevationFt,
    this.continent,
    required this.isoCountry,
    this.isoRegion,
    this.municipality,
    this.scheduledService,
    this.gpsCode,
    this.iataCode,
    this.localCode,
    this.services,
    this.ownerId,
    this.isVerified = false,
    this.isActive = true,
    this.source = 'ourairports',
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
      ident: json['ident'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      latitudeDeg: _doubleFromJson(json['latitude_deg']),
      longitudeDeg: _doubleFromJson(json['longitude_deg']),
      elevationFt: _intFromJsonNullable(json['elevation_ft']),
      continent: json['continent'] as String?,
      isoCountry: json['iso_country'] as String,
      isoRegion: json['iso_region'] as String?,
      municipality: json['municipality'] as String?,
      scheduledService: json['scheduled_service'] as String?,
      gpsCode: json['gps_code'] as String?,
      iataCode: json['iata_code'] as String?,
      localCode: json['local_code'] as String?,
      services: services,
      ownerId: _intFromJsonNullable(json['owner_id']),
      isVerified: _boolFromJson(json['is_verified']) ?? false,
      isActive: _boolFromJson(json['is_active']) ?? true,
      source: json['source'] as String? ?? 'ourairports',
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
      return json.toLowerCase() == 'true' || json == '1';
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
