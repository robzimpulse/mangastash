import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaReaderScreenState extends Equatable {
  const MangaReaderScreenState({
    this.isLoading = false,
    this.chapter,
    this.error,
    this.mangaId,
    this.chapterId,
    this.source,
    this.progress = 0,
    this.hasPreviousChapter = false,
    this.hasNextChapter = false,
  });

  final bool isLoading;

  final Exception? error;

  final MangaChapter? chapter;

  final String? mangaId;

  final String? chapterId;

  final MangaSourceEnum? source;

  final int progress;

  final bool hasPreviousChapter;

  final bool hasNextChapter;

  @override
  List<Object?> get props {
    return [
      mangaId,
      chapterId,
      isLoading,
      chapter,
      error,
      source,
      progress,
      hasPreviousChapter,
      hasNextChapter,
    ];
  }

  MangaReaderScreenState copyWith({
    String? mangaId,
    String? chapterId,
    bool? isLoading,
    MangaChapter? chapter,
    Exception? Function()? error,
    MangaSourceEnum? source,
    int? progress,
    bool? hasPreviousChapter,
    bool? hasNextChapter,
  }) {
    return MangaReaderScreenState(
      mangaId: mangaId ?? this.mangaId,
      chapterId: chapterId ?? this.chapterId,
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      error: error != null ? error() : this.error,
      source: source ?? this.source,
      progress: progress ?? this.progress,
      hasPreviousChapter: hasPreviousChapter ?? this.hasPreviousChapter,
      hasNextChapter: hasNextChapter ?? this.hasNextChapter,
    );
  }
}
