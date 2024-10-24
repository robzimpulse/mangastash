// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_data_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
