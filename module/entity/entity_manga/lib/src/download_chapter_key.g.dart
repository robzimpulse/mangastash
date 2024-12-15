// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_chapter_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadChapterKey _$DownloadChapterKeyFromJson(Map<String, dynamic> json) =>
    DownloadChapterKey(
      manga: json['manga'] == null
          ? null
          : Manga.fromJson(json['manga'] as Map<String, dynamic>),
      chapter: json['chapter'] == null
          ? null
          : MangaChapter.fromJson(json['chapter'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DownloadChapterKeyToJson(DownloadChapterKey instance) =>
    <String, dynamic>{
      'manga': instance.manga?.toJson(),
      'chapter': instance.chapter?.toJson(),
    };
