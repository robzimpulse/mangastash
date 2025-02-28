import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class BrowseMangaScreenState extends Equatable {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  final List<Manga> libraries;

  final MangaShelfItemLayout layout;

  final MangaSourceEnum? source;

  final bool hasNextPage;

  final bool isPagingNextPage;

  final bool isSearchActive;

  final SearchMangaParameter parameter;

  late final Map<String, Manga> libraryMapById;

  late final bool isFavoriteActive;

  late final bool isUpdatedActive;

  late final bool isFilterActive;

  BrowseMangaScreenState({
    this.isLoading = false,
    this.hasNextPage = false,
    this.isPagingNextPage = false,
    this.isSearchActive = false,
    this.error,
    required this.layout,
    this.source,
    this.mangas = const [],
    this.libraries = const [],
    this.parameter = const SearchMangaParameter(),
  }) {
    final Map<String, Manga> libraryMapById = {};

    for (final manga in libraries) {
      final id = manga.id;
      if (id == null) continue;
      libraryMapById.putIfAbsent(id, () => manga);
    }

    this.libraryMapById = libraryMapById;

    isFavoriteActive =
        parameter.orders?.containsKey(SearchOrders.rating) == true;

    isUpdatedActive =
        parameter.orders?.containsKey(SearchOrders.updatedAt) == true;

    isFilterActive = [
      parameter.status != null,
      // TODO: add more param properties
    ].contains(true);
  }

  @override
  List<Object?> get props {
    return [
      isLoading,
      hasNextPage,
      isPagingNextPage,
      error,
      layout,
      source,
      mangas,
      parameter,
      isSearchActive,
      libraries,
    ];
  }

  BrowseMangaScreenState copyWith({
    bool? isLoading,
    bool? hasNextPage,
    bool? isPagingNextPage,
    bool? isSearchActive,
    ValueGetter<Exception?>? error,
    MangaShelfItemLayout? layout,
    MangaSourceEnum? source,
    List<Manga>? mangas,
    List<Manga>? libraries,
    SearchMangaParameter? parameter,
  }) {
    return BrowseMangaScreenState(
      isLoading: isLoading ?? this.isLoading,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPagingNextPage: isPagingNextPage ?? this.isPagingNextPage,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      mangas: mangas ?? this.mangas,
      libraries: libraries ?? this.libraries,
      error: error != null ? error() : this.error,
      layout: layout ?? this.layout,
      source: source ?? this.source,
      parameter: parameter ?? this.parameter,
    );
  }
}
