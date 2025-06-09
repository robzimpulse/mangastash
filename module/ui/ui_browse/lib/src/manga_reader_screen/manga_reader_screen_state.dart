import 'package:core_environment/core_environment.dart';
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
    this.chapterIds = const [],
  });

  final bool isLoading;

  final Exception? error;

  final Chapter? chapter;

  final String? mangaId;

  final String? chapterId;

  final Source? source;

  final List<String> chapterIds;

  int? get index => chapterId?.let((id) => chapterIds.indexOf(id));

  String? get previousChapterId {
    return index?.let(
      (index) => index <= 0 ? null : chapterIds.elementAtOrNull(index - 1),
    );
  }

  String? get nextChapterId {
    return index?.let(
      (index) => index < 0 ? null : chapterIds.elementAtOrNull(index + 1),
    );
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
    List<String>? chapterIds,
  }) {
    return MangaReaderScreenState(
      mangaId: mangaId ?? this.mangaId,
      chapterId: chapterId ?? this.chapterId,
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      error: error != null ? error() : this.error,
      source: source ?? this.source,
      chapterIds: chapterIds ?? this.chapterIds,
    );
  }
}
