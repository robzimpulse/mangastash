import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class LibraryMangaScreenState extends Equatable {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  final bool isSearchActive;

  final String? mangaTitle;

  late final List<Manga> filteredMangas;

  LibraryMangaScreenState({
    this.isLoading = false,
    this.error,
    this.mangas = const [],
    this.isSearchActive = false,
    this.mangaTitle,
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
    ];
  }

  LibraryMangaScreenState copyWith({
    bool? isLoading,
    ValueGetter<Exception?>? error,
    List<Manga>? mangas,
    bool? isSearchActive,
    String? mangaTitle,
  }) {
    return LibraryMangaScreenState(
      isLoading: isLoading ?? this.isLoading,
      mangas: mangas ?? this.mangas,
      error: error != null ? error() : this.error,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      mangaTitle: mangaTitle ?? this.mangaTitle,
    );
  }
}
