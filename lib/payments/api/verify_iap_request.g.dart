// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_iap_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyIAPRequest _$VerifyIAPRequestFromJson(Map<String, dynamic> json) =>
    VerifyIAPRequest(
      receiptData: json['receipt_data'] as String,
      transactionId: json['transaction_id'] as String,
      userId: (json['user_id'] as num).toInt(),
      originalTransactionId: json['original_transaction_id'] as String?,
      isSandbox: json['is_sandbox'] as bool? ?? false,
    );

Map<String, dynamic> _$VerifyIAPRequestToJson(VerifyIAPRequest instance) {
  final val = <String, dynamic>{
    'receipt_data': instance.receiptData,
    'transaction_id': instance.transactionId,
    'user_id': instance.userId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('original_transaction_id', instance.originalTransactionId);
  val['is_sandbox'] = instance.isSandbox;
  return val;
}
