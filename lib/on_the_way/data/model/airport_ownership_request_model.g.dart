// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_ownership_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirportOwnershipRequestModel _$AirportOwnershipRequestModelFromJson(
        Map<String, dynamic> json) =>
    AirportOwnershipRequestModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      airportId: (json['airport_id'] as num).toInt(),
      airportCode: json['airport_code'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      phoneFromRequest: json['phone_from_request'] as String?,
      fullName: json['full_name'] as String?,
      documents: json['documents'],
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
      createdAt:
          AirportOwnershipRequestModel._dateTimeFromJson(json['created_at']),
      updatedAt:
          AirportOwnershipRequestModel._dateTimeFromJson(json['updated_at']),
      reviewedAt: AirportOwnershipRequestModel._dateTimeFromJsonNullable(
          json['reviewed_at']),
      reviewedBy: AirportOwnershipRequestModel._intFromJsonNullable(
          json['reviewed_by']),
    );

Map<String, dynamic> _$AirportOwnershipRequestModelToJson(
        AirportOwnershipRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'airport_id': instance.airportId,
      'airport_code': instance.airportCode,
      'email': instance.email,
      'phone': instance.phone,
      'phone_from_request': instance.phoneFromRequest,
      'full_name': instance.fullName,
      'documents': instance.documents,
      'status': instance.status,
      'admin_notes': instance.adminNotes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
      'reviewed_by': instance.reviewedBy,
    };
