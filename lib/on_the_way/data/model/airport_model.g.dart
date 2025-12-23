// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirportModel _$AirportModelFromJson(Map<String, dynamic> json) => AirportModel(
      id: (json['id'] as num).toInt(),
      ident: json['ident'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      latitudeDeg: (json['latitudeDeg'] as num).toDouble(),
      longitudeDeg: (json['longitudeDeg'] as num).toDouble(),
      elevationFt: (json['elevationFt'] as num?)?.toInt(),
      continent: json['continent'] as String?,
      isoCountry: json['isoCountry'] as String,
      isoRegion: json['isoRegion'] as String?,
      municipality: json['municipality'] as String?,
      scheduledService: json['scheduledService'] as String?,
      gpsCode: json['gpsCode'] as String?,
      iataCode: json['iataCode'] as String?,
      localCode: json['localCode'] as String?,
      services: json['services'] as Map<String, dynamic>?,
      ownerId: (json['ownerId'] as num?)?.toInt(),
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      source: json['source'] as String? ?? 'ourairports',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AirportModelToJson(AirportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ident': instance.ident,
      'type': instance.type,
      'name': instance.name,
      'latitudeDeg': instance.latitudeDeg,
      'longitudeDeg': instance.longitudeDeg,
      'elevationFt': instance.elevationFt,
      'continent': instance.continent,
      'isoCountry': instance.isoCountry,
      'isoRegion': instance.isoRegion,
      'municipality': instance.municipality,
      'scheduledService': instance.scheduledService,
      'gpsCode': instance.gpsCode,
      'iataCode': instance.iataCode,
      'localCode': instance.localCode,
      'services': instance.services,
      'ownerId': instance.ownerId,
      'isVerified': instance.isVerified,
      'isActive': instance.isActive,
      'source': instance.source,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
