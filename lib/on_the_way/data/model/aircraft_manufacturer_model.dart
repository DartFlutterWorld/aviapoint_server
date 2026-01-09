import 'package:json_annotation/json_annotation.dart';

part 'aircraft_manufacturer_model.g.dart';

@JsonSerializable()
class AircraftManufacturerModel {
  final int id;
  final String name;

  AircraftManufacturerModel({
    required this.id,
    required this.name,
  });

  factory AircraftManufacturerModel.fromJson(Map<String, dynamic> json) {
    return AircraftManufacturerModel(
      id: _intFromJson(json['id']),
      name: _stringFromJson(json['name']),
    );
  }

  /// Безопасный парсинг String
  static String _stringFromJson(dynamic json) {
    if (json == null) {
      return '';
    }
    return json.toString();
  }

  /// Безопасный парсинг nullable String
  static String? _stringFromJsonNullable(dynamic json) {
    if (json == null) {
      return null;
    }
    return json.toString();
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

  /// Безопасный парсинг nullable DateTime
  static DateTime? _dateTimeFromJsonNullable(dynamic json) {
    if (json == null) {
      return null;
    }
    if (json is String) {
      try {
        return DateTime.parse(json);
      } catch (e) {
        return null;
      }
    } else if (json is DateTime) {
      return json;
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    } else {
      return null;
    }
  }

  /// Сериализация nullable DateTime в строку
  static String? _dateTimeToJsonNullable(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  Map<String, dynamic> toJson() => _$AircraftManufacturerModelToJson(this);
}
