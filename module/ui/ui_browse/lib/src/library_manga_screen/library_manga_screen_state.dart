import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class LibraryMangaScreenState extends Equatable {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  final bool isSearchActive;

  final String? mangaTitle;

  final List<Source> sources;

  final MangaShelfItemLayout layout;

  final Set<String> prefetchedMangaIds;

  List<Manga> get filteredMangas {
    final title = mangaTitle;
    if (isSearchActive && title != null) {
      return mangas
          .where((manga) => manga.title?.toLowerCase().contains(title) == true)
          .toList();
    }
    return mangas;
  }

  const LibraryMangaScreenState({
    this.isLoading = false,
    this.error,
    this.mangas = const [],
    this.sources = const [],
    this.prefetchedMangaIds = const {},
    this.isSearchActive = false,
    this.mangaTitle,
    this.layout = MangaShelfItemLayout.compactGrid,
  });

  @override
  List<Object?> get props {
    return [
      isLoading,
      error,
      mangas,
      isSearchActive,
      mangaTitle,
      sources,
      layout,
      prefetchedMangaIds,
    ];
  }

  LibraryMangaScreenState copyWith({
    bool? isLoading,
    ValueGetter<Exception?>? error,
    List<Manga>? mangas,
    Set<String>? prefetchedMangaIds,
    List<Source>? sources,
    bool? isSearchActive,
    String? mangaTitle,
    MangaShelfItemLayout? layout,
  }) {
    return LibraryMangaScreenState(
      isLoading: isLoading ?? this.isLoading,
      mangas: mangas ?? this.mangas,
      sources: sources ?? this.sources,
      error: error != null ? error() : this.error,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      layout: layout ?? this.layout,
      prefetchedMangaIds: prefetchedMangaIds ?? this.prefetchedMangaIds,
    );
  }
}
