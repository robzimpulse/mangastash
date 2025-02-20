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
    this.chapterIds,
    this.rawHtml,
  }) {
    final ids = chapterIds ?? [];
    final index = ids.indexOf(chapterId);
    previousChapterId = index <= 0 ? null : ids.elementAtOrNull(index - 1);
    nextChapterId = index < 0 ? null : ids.elementAtOrNull(index + 1);
  }

  final bool isLoading;

  final Exception? error;

  final MangaChapter? chapter;

  final String? mangaId;

  final String? chapterId;

  final MangaSourceEnum? source;

  final List<String?>? chapterIds;

  final String? rawHtml;

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
      chapterIds,
      rawHtml,
    ];
  }

  MangaReaderScreenState copyWith({
    String? mangaId,
    String? chapterId,
    bool? isLoading,
    MangaChapter? chapter,
    Exception? Function()? error,
    MangaSourceEnum? source,
    List<String?>? chapterIds,
    String? rawHtml,
  }) {
    return MangaReaderScreenState(
      mangaId: mangaId ?? this.mangaId,
      chapterId: chapterId ?? this.chapterId,
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      error: error != null ? error() : this.error,
      source: source ?? this.source,
      chapterIds: chapterIds ?? this.chapterIds,
      rawHtml: rawHtml ?? this.rawHtml,
    );
  }
}
