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
  final String? mangaId;
  final String? chapter;

  const DuplicatedChapterKey({this.mangaId, this.chapter});

  factory DuplicatedChapterKey.from(DuplicatedChapterQueryResult e) {
    return DuplicatedChapterKey(mangaId: e.mangaId, chapter: e.chapter);
  }

  @override
  List<Object?> get props => [mangaId, chapter];
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
  final String? mangaTitle;
  final String? mangaSource;
  final List<IncompleteMangaRange> ranges;

  const IncompleteManga({
    this.mangaTitle,
    this.mangaSource,
    this.ranges = const [],
  });

  @override
  List<Object?> get props => [
    mangaTitle,
    mangaSource,
    ranges,
  ];

  factory IncompleteManga.from(ChapterGapQueryResult e) {
    return IncompleteManga(
      mangaTitle: e.title,
      mangaSource: e.source,
      ranges: [],
    );
  }
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

