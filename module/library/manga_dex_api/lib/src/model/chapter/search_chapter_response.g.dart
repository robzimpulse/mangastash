// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_chapter_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchChapterResponse _$SearchChapterResponseFromJson(
        Map<String, dynamic> json) =>
    SearchChapterResponse(
      json['result'] as String?,
      json['response'] as String?,
      (json['data'] as List<dynamic>?)
          ?.map((e) => ChapterData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchChapterResponseToJson(
        SearchChapterResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };
