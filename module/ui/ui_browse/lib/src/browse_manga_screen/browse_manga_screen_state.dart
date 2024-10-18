import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class BrowseMangaScreenState extends Equatable {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  final MangaShelfItemLayout layout;

  final String? sourceId;

  final MangaSource? source;

  final bool hasNextPage;

  final bool isPagingNextPage;

  final bool isSearchActive;

  final SearchMangaParameter parameter;

  const BrowseMangaScreenState({
    this.isLoading = false,
    this.hasNextPage = false,
    this.isPagingNextPage = false,
    this.isSearchActive = false,
    this.error,
    required this.layout,
    this.sourceId,
    this.source,
    this.mangas = const [],
    this.parameter = const SearchMangaParameter(),
  });

  @override
  List<Object?> get props {
    return [
      isLoading,
      hasNextPage,
      isPagingNextPage,
      error,
      layout,
      sourceId,
      source,
      mangas,
      parameter,
      isSearchActive,
    ];
  }

  BrowseMangaScreenState copyWith({
    bool? isLoading,
    bool? hasNextPage,
    bool? isPagingNextPage,
    bool? isSearchActive,
    ValueGetter<Exception?>? error,
    MangaShelfItemLayout? layout,
    String? sourceId,
    MangaSource? source,
    List<Manga>? mangas,
    SearchMangaParameter? parameter,
  }) {
    return BrowseMangaScreenState(
      isLoading: isLoading ?? this.isLoading,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPagingNextPage: isPagingNextPage ?? this.isPagingNextPage,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      mangas: mangas ?? this.mangas,
      error: error != null ? error() : this.error,
      layout: layout ?? this.layout,
      sourceId: sourceId ?? this.sourceId,
      source: source ?? this.source,
      parameter: parameter ?? this.parameter,
    );
  }
}
