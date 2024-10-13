import 'package:core_auth/core_auth.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

enum DownloadOption {
  next('Next Chapter'),
  next5('Next 5 Chapter'),
  next10('Next 10 Chapter'),
  custom('Custom'),
  unread('Unread'),
  all('All');

  final String value;

  const DownloadOption(this.value);
}

class MangaDetailState extends Equatable {
  final bool isLoading;
  final Exception? error;
  final String? mangaId;
  final Manga? manga;
  final List<MangaChapter>? chapters;
  final String? sourceId;
  final MangaSource? source;
  final MangaChapterConfig? config;
  final List<MangaChapter>? processedChapters;
  final AuthState? authState;

  const MangaDetailState({
    this.isLoading = false,
    this.error,
    this.mangaId,
    this.manga,
    this.chapters,
    this.source,
    this.sourceId,
    this.config,
    this.processedChapters,
    this.authState,
  });

  @override
  List<Object?> get props => [
        isLoading,
        error,
        mangaId,
        manga,
        chapters,
        sourceId,
        source,
        config,
        processedChapters,
        authState,
      ];

  MangaDetailState copyWith({
    bool? isLoading,
    ValueGetter<Exception?>? error,
    String? mangaId,
    Manga? manga,
    List<MangaChapter>? chapters,
    List<MangaChapter>? processedChapters,
    String? sourceId,
    MangaSource? source,
    MangaChapterConfig? config,
    AuthState? authState,
  }) {
    return MangaDetailState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      mangaId: mangaId ?? this.mangaId,
      manga: manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      processedChapters: processedChapters ?? this.processedChapters,
      sourceId: sourceId ?? this.sourceId,
      source: source ?? this.source,
      authState: authState ?? this.authState,
    );
  }
}
