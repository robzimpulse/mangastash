// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaChapter _$MangaChapterFromJson(Map<String, dynamic> json) => MangaChapter(
      id: json['id'] as String?,
      title: json['title'] as String?,
      volume: json['volume'] as String?,
      chapter: json['chapter'] as String?,
    );

Map<String, dynamic> _$MangaChapterToJson(MangaChapter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'volume': instance.volume,
      'chapter': instance.chapter,
    };
