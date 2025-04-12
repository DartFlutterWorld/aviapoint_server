// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'normal_check_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NormalCheckLisModel _$NormalCheckLisModelFromJson(Map<String, dynamic> json) =>
    NormalCheckLisModel(
      id: (json['id'] as num).toInt(),
      normalCategoryId: (json['normal_category_id'] as num).toInt(),
      title: json['title'] as String,
      doing: json['doing'] as String,
      picture: json['picture'] as String?,
      titleEng: json['title_eng'] as String,
      doingEng: json['doing_eng'] as String,
      checkList: json['check_list'] as bool,
      subCategory: json['sub_category'] as String?,
      subCategoryEng: json['sub_category_eng'] as String?,
    );

Map<String, dynamic> _$NormalCheckLisModelToJson(NormalCheckLisModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'normal_category_id': instance.normalCategoryId,
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
  val['check_list'] = instance.checkList;
  writeNotNull('sub_category', instance.subCategory);
  writeNotNull('sub_category_eng', instance.subCategoryEng);
  return val;
}
