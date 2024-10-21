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

ChapterData _$ChapterDataFromJson(Map<String, dynamic> json) => ChapterData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : ChapterDataAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      Relationship.from(json['relationships'] as List),
    );

Map<String, dynamic> _$ChapterDataToJson(ChapterData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships
          ?.map((e) => e.toJson(
                (value) => value,
              ))
          .toList(),
    };

ChapterDataAttributes _$ChapterDataAttributesFromJson(
        Map<String, dynamic> json) =>
    ChapterDataAttributes(
      json['volume'] as String?,
      json['chapter'] as String?,
      json['title'] as String?,
      json['translatedLanguage'] as String?,
      json['externalUrl'] as String?,
      json['publishAt'] as String?,
      json['readableAt'] as String?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as num?,
    );

Map<String, dynamic> _$ChapterDataAttributesToJson(
        ChapterDataAttributes instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
      'volume': instance.volume,
      'chapter': instance.chapter,
      'title': instance.title,
      'translatedLanguage': instance.translatedLanguage,
      'externalUrl': instance.externalUrl,
      'publishAt': instance.publishAt,
      'readableAt': instance.readableAt,
    };
