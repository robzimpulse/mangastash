import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class MangaGridWidgetState extends Equatable {
  final bool isLoading;
  final Exception? error;
  final List<Manga> mangas;
  final SourceExternal? source;
  final bool hasNextPage;
  final bool isPagingNextPage;
  final SearchMangaParameter parameter;
  final Set<String> prefetchedMangaIds;
  final Set<String> libraryMangaIds;

  /// Manga ids whose library toggle is currently executing (issue #127) —
  /// a repeat tap for an id in here must be a no-op (see
  /// BrowseMangaScreenState.pendingLibraryMangaIds).
  final Set<String> pendingLibraryMangaIds;

  const MangaGridWidgetState({
    this.isLoading = false,
    this.error,
    this.mangas = const [],
    this.source,
    this.hasNextPage = false,
    this.isPagingNextPage = false,
    this.parameter = const SearchMangaParameter(),
    this.libraryMangaIds = const {},
    this.prefetchedMangaIds = const {},
    this.pendingLibraryMangaIds = const {},
  });

  @override
  List<Object?> get props => [
    isLoading,
    error,
    mangas,
    source,
    hasNextPage,
    isPagingNextPage,
    parameter,
    libraryMangaIds,
    prefetchedMangaIds,
    pendingLibraryMangaIds,
  ];

  MangaGridWidgetState copyWith({
    bool? isLoading,
    ValueGetter<Exception?>? error,
    List<Manga>? mangas,
    SourceExternal? source,
    bool? hasNextPage,
    bool? isPagingNextPage,
    SearchMangaParameter? parameter,
    Set<String>? prefetchedMangaIds,
    Set<String>? libraryMangaIds,
    Set<String>? pendingLibraryMangaIds,
  }) {
    return MangaGridWidgetState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      mangas: mangas ?? this.mangas,
      source: source ?? this.source,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPagingNextPage: isPagingNextPage ?? this.isPagingNextPage,
      parameter: parameter ?? this.parameter,
      libraryMangaIds: libraryMangaIds ?? this.libraryMangaIds,
      prefetchedMangaIds: prefetchedMangaIds ?? this.prefetchedMangaIds,
      pendingLibraryMangaIds:
          pendingLibraryMangaIds ?? this.pendingLibraryMangaIds,
    );
  }
}
