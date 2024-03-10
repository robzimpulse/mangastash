import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class ReaderMangaState extends Equatable {
  const ReaderMangaState({
    this.isLoading = false,
    this.chapter,
    this.errorMessage,
    this.mangaId,
    this.chapterId,
  });

  final bool isLoading;

  final String? errorMessage;

  final MangaChapterDeprecated? chapter;

  final String? mangaId;

  final String? chapterId;

  @override
  List<Object?> get props {
    return [mangaId, chapterId, isLoading, chapter, errorMessage];
  }

  ReaderMangaState copyWith({
    String? mangaId,
    String? chapterId,
    bool? isLoading,
    MangaChapterDeprecated? chapter,
    String? Function()? errorMessage,
  }) {
    return ReaderMangaState(
      mangaId: mangaId ?? this.mangaId,
      chapterId: chapterId ?? this.chapterId,
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
