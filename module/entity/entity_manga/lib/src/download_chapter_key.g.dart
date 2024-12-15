// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_chapter_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadChapterKey _$DownloadChapterKeyFromJson(Map<String, dynamic> json) =>
    DownloadChapterKey(
      mangaId: json['manga_id'] as String?,
      chapterId: json['chapter_id'] as String?,
      mangaSource:
          $enumDecodeNullable(_$MangaSourceEnumEnumMap, json['manga_source']),
      mangaTitle: json['manga_title'] as String?,
      chapterNumber: json['chapter_number'] as num?,
      mangaCoverUrl: json['manga_cover_url'] as String?,
    );

Map<String, dynamic> _$DownloadChapterKeyToJson(DownloadChapterKey instance) =>
    <String, dynamic>{
      'manga_id': instance.mangaId,
      'manga_title': instance.mangaTitle,
      'manga_cover_url': instance.mangaCoverUrl,
      'chapter_id': instance.chapterId,
      'chapter_number': instance.chapterNumber,
      'manga_source': _$MangaSourceEnumEnumMap[instance.mangaSource],
    };

const _$MangaSourceEnumEnumMap = {
  MangaSourceEnum.mangadex: 'Manga Dex',
  MangaSourceEnum.asurascan: 'Asura Scans',
};
