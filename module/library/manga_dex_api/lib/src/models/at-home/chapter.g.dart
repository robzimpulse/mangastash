// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultipleChapterData _$MultipleChapterDataFromJson(Map<String, dynamic> json) =>
    MultipleChapterData(
      json['hash'] as String?,
      (json['data'] as List<dynamic>?)?.map((e) => e as String).toList(),
      (json['dataSaver'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MultipleChapterDataToJson(
        MultipleChapterData instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'data': instance.data,
      'dataSaver': instance.dataSaver,
    };
