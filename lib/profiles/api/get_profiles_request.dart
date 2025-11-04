import 'package:aviapoint_server/profiles/api/base_rest_api_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_profiles_request.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: true,
)
class GetProfilesRequest extends BaseRestApiRequest {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'phone')
  final String email;

  factory GetProfilesRequest.fromJson(Map<String, dynamic> data) => _$GetProfilesRequestFromJson(data);

  GetProfilesRequest({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  Map<String, dynamic> toJson() => _$GetProfilesRequestToJson(this);
}
