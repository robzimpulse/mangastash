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
