import 'package:json_annotation/json_annotation.dart';

part 'verify_iap_request.g.dart';

@JsonSerializable(
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
)
class VerifyIAPRequest {
  VerifyIAPRequest({
    required this.receiptData,
    required this.transactionId,
    required this.userId,
    this.originalTransactionId,
    this.isSandbox = false,
  });

  @JsonKey(name: 'receipt_data')
  final String receiptData;
  
  @JsonKey(name: 'transaction_id')
  final String transactionId;
  
  @JsonKey(name: 'user_id')
  final int userId;
  
  @JsonKey(name: 'original_transaction_id')
  final String? originalTransactionId;
  
  @JsonKey(name: 'is_sandbox', defaultValue: false)
  final bool isSandbox;

  factory VerifyIAPRequest.fromJson(Map<String, dynamic> json) => _$VerifyIAPRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyIAPRequestToJson(this);
}
