import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class MangaDetailState extends Equatable {
  final bool isLoading;
  final Exception? error;
  final String? mangaId;
  final Manga? manga;
  final List<MangaChapter>? chapters;
  final String? sourceId;
  final MangaSource? source;

  const MangaDetailState({
    this.isLoading = false,
    this.error,
    this.mangaId,
    this.manga,
    this.chapters,
    this.source,
    this.sourceId,
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
      ];

  MangaDetailState copyWith({
    bool? isLoading,
    ValueGetter<Exception?>? error,
    String? mangaId,
    Manga? manga,
    List<MangaChapter>? chapters,
    String? sourceId,
    MangaSource? source,
  }) {
    return MangaDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      mangaId: mangaId ?? this.mangaId,
      manga: manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      sourceId: sourceId ?? this.sourceId,
      source: source ?? this.source,
    );
  }
}
