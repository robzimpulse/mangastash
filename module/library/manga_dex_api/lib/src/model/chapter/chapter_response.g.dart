// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterResponse _$ChapterResponseFromJson(Map<String, dynamic> json) =>
    ChapterResponse(
      json['result'] as String?,
      json['response'] as String?,
      json['data'] == null
          ? null
          : ChapterData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChapterResponseToJson(ChapterResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };
