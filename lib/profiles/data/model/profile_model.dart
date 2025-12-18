import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake, createToJson: true)
class ProfileModel {
  ProfileModel({required this.id, required this.phone, this.email, this.firstName, this.lastName, this.avatarUrl});

  final int id;
  final String phone;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
