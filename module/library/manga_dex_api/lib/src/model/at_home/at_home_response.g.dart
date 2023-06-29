// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'at_home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtHomeResponse _$AtHomeResponseFromJson(Map<String, dynamic> json) =>
    AtHomeResponse(
      json['result'] as String?,
      json['baseUrl'] as String?,
      json['chapter'] == null
          ? null
          : AtHomeChapter.fromJson(json['chapter'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AtHomeResponseToJson(AtHomeResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'baseUrl': instance.baseUrl,
      'chapter': instance.chapter,
    };

AtHomeChapter _$AtHomeChapterFromJson(Map<String, dynamic> json) =>
    AtHomeChapter(
      json['hash'] as String?,
      (json['data'] as List<dynamic>?)?.map((e) => e as String).toList(),
      (json['dataSaver'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AtHomeChapterToJson(AtHomeChapter instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'data': instance.data,
      'dataSaver': instance.dataSaver,
    };
