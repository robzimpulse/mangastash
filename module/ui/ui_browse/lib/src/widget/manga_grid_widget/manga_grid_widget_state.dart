import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class MangaGridWidgetState extends Equatable {
  final bool isLoading;
  final Exception? error;
  final List<Manga> mangas;
  final SourceEnum? source;
  final bool hasNextPage;
  final bool isPagingNextPage;
  final SearchMangaParameter parameter;
  final Set<String> prefetchedMangaIds;
  final Set<String> libraryMangaIds;

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
  ];

  MangaGridWidgetState copyWith({
    bool? isLoading,
    ValueGetter<Exception?>? error,
    List<Manga>? mangas,
    SourceEnum? source,
    bool? hasNextPage,
    bool? isPagingNextPage,
    SearchMangaParameter? parameter,
    Set<String>? prefetchedMangaIds,
    Set<String>? libraryMangaIds,
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
    );
  }
}
