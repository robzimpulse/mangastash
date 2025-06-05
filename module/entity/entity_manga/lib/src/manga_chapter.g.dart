// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaChapter _$MangaChapterFromJson(Map<String, dynamic> json) => MangaChapter(
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
    );

Map<String, dynamic> _$MangaChapterToJson(MangaChapter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'manga_id': instance.mangaId,
      'title': instance.title,
      'volume': instance.volume,
      'chapter': instance.chapter,
      'readable_at': instance.readableAt?.toIso8601String(),
      'publish_at': instance.publishAt?.toIso8601String(),
      'images': instance.images,
      'translated_language': instance.translatedLanguage,
      'scanlation_group': instance.scanlationGroup,
      'web_url': instance.webUrl,
    };
