// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: PaymentModel._amountFromJson(json['amount']),
      currency: json['currency'] as String,
      description: json['description'] as String,
      paymentUrl: json['payment_url'] as String,
      createdAt: PaymentModel._dateTimeFromJson(json['created_at']),
      paid: json['paid'] as bool,
      userId: PaymentModel._intFromJson(json['user_id']),
      subscriptionType: json['subscription_type'] as String,
      periodDays: PaymentModel._intFromJson(json['period_days']),
    );

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'description': instance.description,
      'payment_url': instance.paymentUrl,
      'created_at': PaymentModel._dateTimeToJson(instance.createdAt),
      'paid': instance.paid,
      'user_id': instance.userId,
      'subscription_type': instance.subscriptionType,
      'period_days': instance.periodDays,
    };
