import 'package:core_environment/core_environment.dart';
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
    this.chapterIds = const [],
  });

  final bool isLoading;

  final Exception? error;

  final Chapter? chapter;

  final String? mangaId;

  final String? chapterId;

  final Source? source;

  final SearchChapterParameter parameter;

  final List<String> chapterIds;

  String? get previousChapterId {
    return chapterId?.let((id) {
     final index = chapterIds.indexOf(id);
     return index > 0 ? chapterIds.elementAtOrNull(index - 1) : null;
    });
  }

  String? get nextChapterId {
    return chapterId?.let((id) {
      final index = chapterIds.indexOf(id);
      return index > 0 ? chapterIds.elementAtOrNull(index + 1) : null;
    });
  }

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
      chapterIds,
    ];
  }

  MangaReaderScreenState copyWith({
    String? mangaId,
    String? chapterId,
    bool? isLoading,
    Chapter? chapter,
    Exception? Function()? error,
    Source? source,
    SearchChapterParameter? parameter,
    List<String>? chapterIds,
  }) {
    return MangaReaderScreenState(
      mangaId: mangaId ?? this.mangaId,
      chapterId: chapterId ?? this.chapterId,
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      error: error != null ? error() : this.error,
      source: source ?? this.source,
      parameter: parameter ?? this.parameter,
      chapterIds: chapterIds ?? this.chapterIds,
    );
  }
}
