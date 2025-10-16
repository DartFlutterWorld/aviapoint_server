// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ros_avia_test_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RosAviaTestCategoryModel _$RosAviaTestCategoryModelFromJson(
        Map<String, dynamic> json) =>
    RosAviaTestCategoryModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$RosAviaTestCategoryModelToJson(
        RosAviaTestCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image': instance.image,
    };
