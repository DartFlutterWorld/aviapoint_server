// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preflight_inspetion_check_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreflightInspectionCheckLisModel _$PreflightInspectionCheckLisModelFromJson(
        Map<String, dynamic> json) =>
    PreflightInspectionCheckLisModel(
      id: (json['id'] as num).toInt(),
      preflightInspectionCategoryId:
          (json['preflight_inspection_category_id'] as num).toInt(),
      title: json['title'] as String,
      doing: json['doing'] as String,
      picture: json['picture'] as String?,
      titleEng: json['title_eng'] as String,
      doingEng: json['doing_eng'] as String,
    );

Map<String, dynamic> _$PreflightInspectionCheckLisModelToJson(
    PreflightInspectionCheckLisModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'preflight_inspection_category_id': instance.preflightInspectionCategoryId,
    'title': instance.title,
    'doing': instance.doing,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('picture', instance.picture);
  val['title_eng'] = instance.titleEng;
  val['doing_eng'] = instance.doingEng;
  return val;
}
