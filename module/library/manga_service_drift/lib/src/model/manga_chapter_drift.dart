import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../../manga_service_drift.dart';
import '../extension/value_or_null_extension.dart';
import 'manga_chapter_image_drift.dart';

class MangaChapterDrift extends Equatable {
  final String? id;

  final String? mangaId;

  final String? mangaTitle;

  final String? title;

  final String? volume;

  final String? chapter;

  final String? readableAt;

  final String? publishAt;

  final List<MangaChapterImageDrift> images;

  final String? translatedLanguage;

  final String? scanlationGroup;

  final String? webUrl;

  final String? createdAt;

  final String? updatedAt;

  const MangaChapterDrift({
    this.id,
    this.mangaId,
    this.mangaTitle,
    this.title,
    this.volume,
    this.chapter,
    this.readableAt,
    this.publishAt,
    this.images = const [],
    this.translatedLanguage,
    this.scanlationGroup,
    this.webUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MangaChapterDrift.fromCompanion(
    MangaChapterTablesCompanion chapter, {
    List<MangaChapterImageTablesCompanion> images = const [],
  }) {
    return MangaChapterDrift(
      id: chapter.id.valueOrNull,
      mangaId: chapter.mangaId.valueOrNull,
      mangaTitle: chapter.mangaTitle.valueOrNull,
      title: chapter.title.valueOrNull,
      volume: chapter.volume.valueOrNull,
      chapter: chapter.chapter.valueOrNull,
      readableAt: chapter.readableAt.valueOrNull,
      publishAt: chapter.publishAt.valueOrNull,
      images: [...images.map((e) => MangaChapterImageDrift.fromCompanion(e))],
      translatedLanguage: chapter.translatedLanguage.valueOrNull,
      scanlationGroup: chapter.scanlationGroup.valueOrNull,
      webUrl: chapter.webUrl.valueOrNull,
      createdAt: chapter.createdAt.valueOrNull,
      updatedAt: chapter.updatedAt.valueOrNull,
    );
  }

  MangaChapterTablesCompanion toCompanion() {
    return MangaChapterTablesCompanion(
      createdAt: Value.absentIfNull(createdAt),
      updatedAt: Value.absentIfNull(updatedAt),
      id: Value.absentIfNull(id),
      mangaId: Value.absentIfNull(mangaId),
      mangaTitle: Value.absentIfNull(mangaTitle),
      title: Value.absentIfNull(title),
      volume: Value.absentIfNull(volume),
      chapter: Value.absentIfNull(chapter),
      readableAt: Value.absentIfNull(readableAt),
      publishAt: Value.absentIfNull(publishAt),
      translatedLanguage: Value.absentIfNull(translatedLanguage),
      scanlationGroup: Value.absentIfNull(scanlationGroup),
      webUrl: Value.absentIfNull(webUrl),
    );
  }

  @override
  List<Object?> get props => [
        id,
        mangaId,
        mangaTitle,
        title,
        volume,
        chapter,
        readableAt,
        publishAt,
        images,
        translatedLanguage,
        scanlationGroup,
        webUrl,
        createdAt,
        updatedAt,
      ];
}
