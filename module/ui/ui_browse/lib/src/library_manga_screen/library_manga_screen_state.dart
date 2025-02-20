import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class LibraryMangaScreenState extends Equatable {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  final bool isSearchActive;

  final String? mangaTitle;

  final Map<MangaSourceEnum?, MangaSource> sources;

  final MangaShelfItemLayout layout;

  late final List<Manga> filteredMangas;

  LibraryMangaScreenState({
    this.isLoading = false,
    this.error,
    this.mangas = const [],
    this.sources = const {},
    this.isSearchActive = false,
    this.mangaTitle,
    this.layout = MangaShelfItemLayout.comfortableGrid,
  }) {
    final title = mangaTitle;
    filteredMangas = isSearchActive && title != null
        ? List.of(
            mangas.where(
              (manga) => manga.title?.toLowerCase().contains(title) == true,
            ),
          )
        : mangas;
  }

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
    ];
  }

  LibraryMangaScreenState copyWith({
    bool? isLoading,
    ValueGetter<Exception?>? error,
    List<Manga>? mangas,
    Map<MangaSourceEnum?, MangaSource>? sources,
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
    );
  }
}
