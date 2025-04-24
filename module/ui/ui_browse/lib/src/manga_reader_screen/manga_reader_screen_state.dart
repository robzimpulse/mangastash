import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class MangaReaderScreenState extends Equatable {
  MangaReaderScreenState({
    this.isLoading = false,
    this.chapter,
    this.error,
    this.mangaId,
    this.chapterId,
    this.sourceEnum,
    this.chapterIds,
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

  final MangaSourceEnum? sourceEnum;

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
      sourceEnum,
      chapterIds,
    ];
  }

  MangaReaderScreenState copyWith({
    String? mangaId,
    String? chapterId,
    bool? isLoading,
    MangaChapter? chapter,
    Exception? Function()? error,
    MangaSourceEnum? sourceEnum,
    MangaSource? source,
    List<String?>? chapterIds,
  }) {
    return MangaReaderScreenState(
      mangaId: mangaId ?? this.mangaId,
      chapterId: chapterId ?? this.chapterId,
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      error: error != null ? error() : this.error,
      sourceEnum: sourceEnum ?? this.sourceEnum,
      chapterIds: chapterIds ?? this.chapterIds,
    );
  }
}
