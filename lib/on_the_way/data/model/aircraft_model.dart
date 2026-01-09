import 'package:json_annotation/json_annotation.dart';
import 'aircraft_manufacturer_model.dart';

part 'aircraft_model.g.dart';

@JsonSerializable()
class AircraftModel {
  final int id;
  @JsonKey(name: 'manufacturer_id')
  final int manufacturerId;
  @JsonKey(name: 'model_code')
  final String modelCode;
  
  // Joined data from aircraft_manufacturers table
  final AircraftManufacturerModel? manufacturer;

  AircraftModel({
    required this.id,
    required this.manufacturerId,
    required this.modelCode,
    this.manufacturer,
  });

  factory AircraftModel.fromJson(Map<String, dynamic> json) {
    AircraftManufacturerModel? manufacturer;
    
    // Если manufacturer приходит как вложенный объект (из JOIN запроса)
    if (json['manufacturer'] != null && json['manufacturer'] is Map) {
      manufacturer = AircraftManufacturerModel.fromJson(json['manufacturer'] as Map<String, dynamic>);
    } else if (json['m_id'] != null) {
      // Если manufacturer приходит как отдельные поля с префиксом m_ (из JOIN запроса)
      manufacturer = AircraftManufacturerModel(
        id: _intFromJson(json['m_id']),
        name: _stringFromJson(json['m_name']),
      );
    }

    return AircraftModel(
      id: _intFromJson(json['id']),
      manufacturerId: _intFromJson(json['manufacturer_id']),
      modelCode: _stringFromJson(json['model_code']),
      manufacturer: manufacturer,
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

  Map<String, dynamic> toJson() => _$AircraftModelToJson(this);
}
