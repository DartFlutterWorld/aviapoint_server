import 'package:airpoint_server/profiles/api/base_rest_api_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_user_request.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: true,
)
class CreateUserRequest extends BaseRestApiRequest {
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'email')
  final String email;

  factory CreateUserRequest.fromJson(Map<String, dynamic> data) => _$CreateUserRequestFromJson(data);

  CreateUserRequest({
    required this.name,
    required this.email,
  });

  @override
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}
