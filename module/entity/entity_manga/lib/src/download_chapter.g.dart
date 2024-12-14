// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadChapter _$DownloadChapterFromJson(Map<String, dynamic> json) =>
    DownloadChapter(
      manga: json['manga'] == null
          ? null
          : Manga.fromJson(json['manga'] as Map<String, dynamic>),
      chapter: json['chapter'] == null
          ? null
          : MangaChapter.fromJson(json['chapter'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DownloadChapterToJson(DownloadChapter instance) =>
    <String, dynamic>{
      'manga': instance.manga?.toJson(),
      'chapter': instance.chapter?.toJson(),
    };
