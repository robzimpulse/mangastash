// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chapter _$ChapterFromJson(Map<String, dynamic> json) => Chapter(
      json['result'] as String?,
      json['response'] as String?,
      (json['data'] as List<dynamic>?)
          ?.map((e) => ChapterData.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['limit'] as int?,
      json['offset'] as int?,
      json['total'] as int?,
    );

Map<String, dynamic> _$ChapterToJson(Chapter instance) => <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
    };

ChapterData _$ChapterDataFromJson(Map<String, dynamic> json) => ChapterData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : ChapterAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map((e) => Relationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChapterDataToJson(ChapterData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };

ChapterAttributes _$ChapterAttributesFromJson(Map<String, dynamic> json) =>
    ChapterAttributes(
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
