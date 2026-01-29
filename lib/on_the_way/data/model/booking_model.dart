import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class BookingModel {
  final int id;
  @JsonKey(name: 'flight_id')
  final int flightId;
  @JsonKey(name: 'passenger_id')
  final int passengerId;
  @JsonKey(name: 'seats_count')
  final int seatsCount;
  @JsonKey(name: 'total_price')
  final int totalPrice;
  final String? status;
  @JsonKey(name: 'created_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? updatedAt;
  // Данные пассажира (загружаются через JOIN в SQL)
  @JsonKey(name: 'passenger_first_name')
  final String? passengerFirstName;
  @JsonKey(name: 'passenger_last_name')
  final String? passengerLastName;
  @JsonKey(name: 'passenger_avatar_url')
  final String? passengerAvatarUrl;
  @JsonKey(name: 'passenger_phone')
  final String? passengerPhone;
  @JsonKey(name: 'passenger_email')
  final String? passengerEmail;
  @JsonKey(name: 'passenger_telegram')
  final String? passengerTelegram;
  @JsonKey(name: 'passenger_max')
  final String? passengerMax;
  @JsonKey(name: 'passenger_average_rating', fromJson: _doubleFromJsonNullable)
  final double? passengerAverageRating;
  // Данные полёта (загружаются через JOIN в SQL)
  @JsonKey(name: 'flight_departure_date', toJson: _dateTimeToJsonNullable, fromJson: _dateTimeFromJsonNullable)
  final DateTime? flightDepartureDate;
  @JsonKey(name: 'flight_departure_airport')
  final String? flightDepartureAirport;
  @JsonKey(name: 'flight_arrival_airport')
  final String? flightArrivalAirport;
  @JsonKey(name: 'flight_waypoints')
  final dynamic flightWaypoints; // JSON массив кодов аэропортов
  // Данные пилота (загружаются через JOIN в SQL)
  @JsonKey(name: 'pilot_first_name')
  final String? pilotFirstName;
  @JsonKey(name: 'pilot_last_name')
  final String? pilotLastName;
  @JsonKey(name: 'pilot_phone')
  final String? pilotPhone;
  @JsonKey(name: 'pilot_email')
  final String? pilotEmail;
  @JsonKey(name: 'pilot_telegram')
  final String? pilotTelegram;
  @JsonKey(name: 'pilot_max')
  final String? pilotMax;

  BookingModel({
    required this.id,
    required this.flightId,
    required this.passengerId,
    required this.seatsCount,
    required this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.passengerFirstName,
    this.passengerLastName,
    this.passengerAvatarUrl,
    this.passengerPhone,
    this.passengerEmail,
    this.passengerTelegram,
    this.passengerMax,
    this.passengerAverageRating,
    this.flightDepartureDate,
    this.flightDepartureAirport,
    this.flightArrivalAirport,
    this.flightWaypoints,
    this.pilotFirstName,
    this.pilotLastName,
    this.pilotPhone,
    this.pilotEmail,
    this.pilotTelegram,
    this.pilotMax,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Безопасный парсинг с обработкой null значений для строковых полей
    try {
      return BookingModel(
        id: (json['id'] as num).toInt(),
        flightId: (json['flight_id'] as num).toInt(),
        passengerId: (json['passenger_id'] as num).toInt(),
        seatsCount: (json['seats_count'] as num).toInt(),
        totalPrice: (json['total_price'] as num).toInt(),
        status: _safeStringFromJson(json['status']),
        createdAt: _dateTimeFromJsonNullable(json['created_at']),
        updatedAt: _dateTimeFromJsonNullable(json['updated_at']),
        passengerFirstName: _safeStringFromJson(json['passenger_first_name']),
        passengerLastName: _safeStringFromJson(json['passenger_last_name']),
        passengerAvatarUrl: _safeStringFromJson(json['passenger_avatar_url']),
        passengerPhone: _safeStringFromJson(json['passenger_phone']),
        passengerEmail: _safeStringFromJson(json['passenger_email']),
        passengerTelegram: _safeStringFromJson(json['passenger_telegram']),
        passengerMax: _safeStringFromJson(json['passenger_max']),
        passengerAverageRating: _doubleFromJsonNullable(json['passenger_average_rating']),
        flightDepartureDate: _dateTimeFromJsonNullable(json['flight_departure_date']),
        flightDepartureAirport: _safeStringFromJson(json['flight_departure_airport']),
        flightArrivalAirport: _safeStringFromJson(json['flight_arrival_airport']),
        flightWaypoints: json['flight_waypoints'],
        pilotFirstName: _safeStringFromJson(json['pilot_first_name']),
        pilotLastName: _safeStringFromJson(json['pilot_last_name']),
        pilotPhone: _safeStringFromJson(json['pilot_phone']),
        pilotEmail: _safeStringFromJson(json['pilot_email']),
        pilotTelegram: _safeStringFromJson(json['pilot_telegram']),
        pilotMax: _safeStringFromJson(json['pilot_max']),
      );
    } catch (e, stackTrace) {
      print('❌ [BookingModel] fromJson error: $e');
      print('❌ [BookingModel] fromJson stackTrace: $stackTrace');
      print('❌ [BookingModel] fromJson json: $json');
      rethrow;
    }
  }
  
  /// Безопасное преобразование значения в String? с обработкой null
  static String? _safeStringFromJson(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }
  
  Map<String, dynamic> toJson() => _$BookingModelToJson(this);
}

/// Конвертирует nullable DateTime в ISO8601 строку или null
String? _dateTimeToJsonNullable(DateTime? dateTime) => dateTime?.toIso8601String();

/// Парсит DateTime из строки, объекта DateTime или int (timestamp)
DateTime _dateTimeFromJson(dynamic json) {
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

/// Парсит nullable DateTime
DateTime? _dateTimeFromJsonNullable(dynamic json) {
  if (json == null) {
    return null;
  }
  return _dateTimeFromJson(json);
}

/// Парсит nullable double
double? _doubleFromJsonNullable(dynamic json) {
  if (json == null) return null;
  if (json is double) return json;
  if (json is num) return json.toDouble();
  if (json is String) return double.tryParse(json);
  return null;
}
