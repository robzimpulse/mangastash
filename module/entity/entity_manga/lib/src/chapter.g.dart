// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chapter _$ChapterFromJson(Map<String, dynamic> json) => Chapter(
      id: json['id'] as String?,
      mangaId: json['manga_id'] as String?,
      title: json['title'] as String?,
      volume: json['volume'] as String?,
      chapter: json['chapter'] as String?,
      readableAt: json['readable_at'] == null
          ? null
          : DateTime.parse(json['readable_at'] as String),
      publishAt: json['publish_at'] == null
          ? null
          : DateTime.parse(json['publish_at'] as String),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      translatedLanguage: json['translated_language'] as String?,
      scanlationGroup: json['scanlation_group'] as String?,
      webUrl: json['web_url'] as String?,
      lastReadAt: json['last_read_at'] == null
          ? null
          : DateTime.parse(json['last_read_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ChapterToJson(Chapter instance) => <String, dynamic>{
      'id': instance.id,
      'manga_id': instance.mangaId,
      'title': instance.title,
      'volume': instance.volume,
      'chapter': instance.chapter,
      'readable_at': instance.readableAt?.toIso8601String(),
      'publish_at': instance.publishAt?.toIso8601String(),
      'last_read_at': instance.lastReadAt?.toIso8601String(),
      'images': instance.images,
      'translated_language': instance.translatedLanguage,
      'scanlation_group': instance.scanlationGroup,
      'web_url': instance.webUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
