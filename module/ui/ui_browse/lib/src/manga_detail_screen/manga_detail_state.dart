import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaDetailState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? sourceId;
  final MangaSource? source;
  final String? mangaId;
  final Manga? manga;
  final List<MangaChapter>? chapters;

  const MangaDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.source,
    this.sourceId,
    this.mangaId,
    this.manga,
    this.chapters,
  });

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        source,
        sourceId,
        mangaId,
        manga,
        chapters,
      ];
}
