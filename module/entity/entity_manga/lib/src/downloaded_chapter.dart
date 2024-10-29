import 'package:equatable/equatable.dart';

import 'manga.dart';
import 'manga_chapter.dart';

class DownloadedChapter extends Equatable {
  final String? id;

  final MangaChapter? chapter;

  final Manga? manga;

  final String? createdAt;

  const DownloadedChapter({
    this.id,
    this.chapter,
    this.manga,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, chapter, manga, createdAt];

  DownloadedChapter copyWith({
    String? id,
    MangaChapter? chapter,
    Manga? manga,
    String? createdAt,
  }) {
    return DownloadedChapter(
      id: id ?? this.id,
      chapter: chapter ?? this.chapter,
      manga: manga ?? this.manga,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}