import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaReaderScreenState extends Equatable {
  MangaReaderScreenState({
    this.isLoading = false,
    this.chapter,
    this.error,
    this.mangaId,
    this.chapterId,
    this.source,
    this.progress = 0,
    this.chapterIds,
  }) {
    final ids = chapterIds ?? [];
    final index = ids.indexOf(chapterId);
    previousChapterId = index == -1 ? null : ids.elementAtOrNull(index - 1);
    nextChapterId = index == -1 ? null : ids.elementAtOrNull(index + 1);
  }

  final bool isLoading;

  final Exception? error;

  final MangaChapter? chapter;

  final String? mangaId;

  final String? chapterId;

  final MangaSourceEnum? source;

  final int progress;

  final List<String?>? chapterIds;

  late final String? previousChapterId;

  late final String? nextChapterId;

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
      chapterIds,
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
    List<String?>? chapterIds,
  }) {
    return MangaReaderScreenState(
      mangaId: mangaId ?? this.mangaId,
      chapterId: chapterId ?? this.chapterId,
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      error: error != null ? error() : this.error,
      source: source ?? this.source,
      progress: progress ?? this.progress,
      chapterIds: chapterIds ?? this.chapterIds,
    );
  }
}
