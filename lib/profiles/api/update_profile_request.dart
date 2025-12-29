import 'package:aviapoint_server/profiles/api/base_rest_api_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

@JsonSerializable(createFactory: true, createToJson: true)
class UpdateProfileRequest extends BaseRestApiRequest {
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'telegram')
  final String? telegram;
  @JsonKey(name: 'max')
  final String? max;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> data) => _$UpdateProfileRequestFromJson(data);

  UpdateProfileRequest({this.email, this.firstName, this.lastName, this.telegram, this.max});

  @override
  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
