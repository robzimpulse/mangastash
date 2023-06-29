// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterResponse _$ChapterResponseFromJson(Map<String, dynamic> json) =>
    ChapterResponse(
      json['result'] as String?,
      json['response'] as String?,
      (json['data'] as List<dynamic>?)
          ?.map((e) => ChapterData.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['limit'] as int?,
      json['offset'] as int?,
      json['total'] as int?,
    );

Map<String, dynamic> _$ChapterResponseToJson(ChapterResponse instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };

ChapterData _$ChapterDataFromJson(Map<String, dynamic> json) => ChapterData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : ChapterAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map((e) => ChapterRelationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChapterDataToJson(ChapterData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };

ChapterRelationship _$ChapterRelationshipFromJson(Map<String, dynamic> json) =>
    ChapterRelationship(
      json['id'] as String?,
      json['type'] as String?,
    );

Map<String, dynamic> _$ChapterRelationshipToJson(
        ChapterRelationship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
    };

ChapterAttributes _$ChapterAttributesFromJson(Map<String, dynamic> json) =>
    ChapterAttributes(
      json['id'] as String?,
      json['type'] as String?,
      json['volume'] as String?,
      json['chapter'] as String?,
      json['title'] as String?,
      json['transdLanguage'] as String?,
      json['hash'] as String?,
      (json['chapterData'] as List<dynamic>?)?.map((e) => e as String).toList(),
      (json['chapterDataSaver'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      json['publishAt'] as String?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as int?,
    );

Map<String, dynamic> _$ChapterAttributesToJson(ChapterAttributes instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'volume': instance.volume,
      'chapter': instance.chapter,
      'title': instance.title,
      'transdLanguage': instance.transdLanguage,
      'hash': instance.hash,
      'chapterData': instance.chapterData,
      'chapterDataSaver': instance.chapterDataSaver,
      'publishAt': instance.publishAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
    };
