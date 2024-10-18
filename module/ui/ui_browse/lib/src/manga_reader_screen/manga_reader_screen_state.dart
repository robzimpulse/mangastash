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
    this.sourceId,
  });

  final bool isLoading;

  final Exception? error;

  final MangaChapter? chapter;

  final String? mangaId;

  final String? chapterId;

  final String? sourceId;

  final MangaSource? source;

  @override
  List<Object?> get props {
    return [mangaId, chapterId, isLoading, chapter, error, sourceId, source];
  }

  MangaReaderScreenState copyWith({
    String? mangaId,
    String? chapterId,
    bool? isLoading,
    MangaChapter? chapter,
    Exception? Function()? error,
    String? sourceId,
    MangaSource? source,
  }) {
    return MangaReaderScreenState(
      mangaId: mangaId ?? this.mangaId,
      chapterId: chapterId ?? this.chapterId,
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      error: error != null ? error() : this.error,
      sourceId: sourceId ?? this.sourceId,
      source: source ?? this.source,
    );
  }
}
