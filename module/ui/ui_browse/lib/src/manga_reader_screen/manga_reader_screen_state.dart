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
    this.previousChapterId,
    this.nextChapterId,
  });

  final bool isLoading;

  final Exception? error;

  final Chapter? chapter;

  final String? mangaId;

  final String? chapterId;

  final Source? source;

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
      previousChapterId,
      nextChapterId,
    ];
  }

  MangaReaderScreenState copyWith({
    String? mangaId,
    String? chapterId,
    bool? isLoading,
    Chapter? chapter,
    Exception? Function()? error,
    Source? source,
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
      nextChapterId: nextChapterId ?? this.nextChapterId,
      previousChapterId: previousChapterId ?? this.previousChapterId,
    );
  }
}
