import 'package:aviapoint_server/profiles/api/base_rest_api_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_video_for_student_request.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: true,
)
class GetVideoForStudentsRequest extends BaseRestApiRequest {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'url')
  final String url;

  factory GetVideoForStudentsRequest.fromJson(Map<String, dynamic> data) => _$GetVideoForStudentsRequestFromJson(data);

  GetVideoForStudentsRequest({
    required this.id,
    required this.title,
    required this.url,
  });

  @override
  Map<String, dynamic> toJson() => _$GetVideoForStudentsRequestToJson(this);
}
