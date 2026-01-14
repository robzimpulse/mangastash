import 'package:domain_manga/domain_manga.dart';
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
    this.parameter = const SearchChapterParameter(),
    this.isLoadingNeighbourChapters = false,
    this.previousChapterId,
    this.nextChapterId,
  });

  final bool isLoading;

  final Exception? error;

  final Chapter? chapter;

  final String? mangaId;

  final String? chapterId;

  final SourceEnum? source;

  final SearchChapterParameter parameter;

  final bool isLoadingNeighbourChapters;

  final String? previousChapterId;

  final String? nextChapterId;

  @override
  List<Object?> get props {
    return [
      mangaId,
      chapterId,
      isLoading,
      chapter,
      error,
      source,
      parameter,
      previousChapterId,
      nextChapterId,
      isLoadingNeighbourChapters,
    ];
  }

  MangaReaderScreenState copyWith({
    String? mangaId,
    String? chapterId,
    bool? isLoading,
    Chapter? chapter,
    Exception? Function()? error,
    SourceEnum? source,
    SearchChapterParameter? parameter,
    bool? isLoadingNeighbourChapters,
    String? previousChapterId,
    String? nextChapterId,
  }) {
    return MangaReaderScreenState(
      mangaId: mangaId ?? this.mangaId,
      chapterId: chapterId ?? this.chapterId,
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      error: error != null ? error() : this.error,
      source: source ?? this.source,
      parameter: parameter ?? this.parameter,
      isLoadingNeighbourChapters:
          isLoadingNeighbourChapters ?? this.isLoadingNeighbourChapters,
      previousChapterId: previousChapterId ?? this.previousChapterId,
      nextChapterId: nextChapterId ?? this.nextChapterId,
    );
  }
}
