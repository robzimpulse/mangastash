// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_chapter_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaChapterFirebase _$MangaChapterFirebaseFromJson(
  Map<String, dynamic> json,
) => MangaChapterFirebase(
  id: json['id'] as String?,
  mangaId: json['manga_id'] as String?,
  mangaTitle: json['manga_title'] as String?,
  title: json['title'] as String?,
  volume: json['volume'] as String?,
  chapter: json['chapter'] as String?,
  readableAt: json['readable_at'] as String?,
  publishAt: json['publish_at'] as String?,
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  translatedLanguage: json['translated_language'] as String?,
  scanlationGroup: json['scanlation_group'] as String?,
  webUrl: json['web_url'] as String?,
);

Map<String, dynamic> _$MangaChapterFirebaseToJson(
  MangaChapterFirebase instance,
) => <String, dynamic>{
  'id': instance.id,
  'manga_id': instance.mangaId,
  'manga_title': instance.mangaTitle,
  'title': instance.title,
  'volume': instance.volume,
  'chapter': instance.chapter,
  'readable_at': instance.readableAt,
  'publish_at': instance.publishAt,
  'images': instance.images,
  'translated_language': instance.translatedLanguage,
  'scanlation_group': instance.scanlationGroup,
  'web_url': instance.webUrl,
};
