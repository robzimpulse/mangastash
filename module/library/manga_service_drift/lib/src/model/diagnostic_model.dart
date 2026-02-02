import 'package:equatable/equatable.dart';

import '../../manga_service_drift.dart';

class DuplicatedMangaKey extends Equatable {
  final String? title;
  final String? source;

  const DuplicatedMangaKey({this.title, this.source});

  factory DuplicatedMangaKey.from(DuplicatedMangaQueryResult e) {
    return DuplicatedMangaKey(title: e.title, source: e.source);
  }

  @override
  List<Object?> get props => [title, source];
}

class DuplicatedChapterKey extends Equatable {
  final MangaDrift? manga;
  final String? chapter;

  const DuplicatedChapterKey({this.manga, this.chapter});

  factory DuplicatedChapterKey.from(DuplicatedChapterQueryResult e) {
    return DuplicatedChapterKey(
      manga: MangaDrift(
        createdAt: e.mangaCreatedAt,
        updatedAt: e.mangaUpdatedAt,
        id: e.mangaId,
        title: e.mangaTitle,
        coverUrl: e.mangaCoverUrl,
        author: e.mangaAuthor,
        status: e.mangaStatus,
        description: e.mangaDescription,
        webUrl: e.mangaWebUrl,
        source: e.mangaSource,
      ),
      chapter: e.chapterNumber,
    );
  }

  @override
  List<Object?> get props => [manga, chapter];
}

class DuplicatedTagKey extends Equatable {
  final String? name;
  final String? source;

  const DuplicatedTagKey({this.name, this.source});

  factory DuplicatedTagKey.from(DuplicatedTagQueryResult e) {
    return DuplicatedTagKey(name: e.name, source: e.source);
  }

  @override
  List<Object?> get props => [name, source];
}

class IncompleteManga extends Equatable {
  final MangaDrift? manga;
  final List<IncompleteMangaRange> ranges;

  const IncompleteManga({this.manga, this.ranges = const []});

  @override
  List<Object?> get props => [manga, ranges];
}

class IncompleteMangaRange extends Equatable {
  final String? chapterStart;
  final String? chapterEnd;
  final double? estimatedMissingCount;

  const IncompleteMangaRange({
    this.chapterStart,
    this.chapterEnd,
    this.estimatedMissingCount,
  });

  @override
  List<Object?> get props => [chapterStart, chapterEnd, estimatedMissingCount];
}
