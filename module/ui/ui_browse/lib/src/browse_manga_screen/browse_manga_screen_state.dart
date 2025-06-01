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

  late final bool isFavoriteActive;

  late final bool isUpdatedActive;

  late final bool isFilterActive;

  final Set<String> prefetchedMangaIds;

  BrowseMangaScreenState({
    this.isLoading = false,
    this.hasNextPage = false,
    this.isPagingNextPage = false,
    this.isSearchActive = false,
    this.error,
    this.layout = MangaShelfItemLayout.compactGrid,
    this.source,
    this.mangas = const [],
    this.libraries = const [],
    this.parameter = const SearchMangaParameter(),
    this.prefetchedMangaIds = const {},
  }) {
    isFavoriteActive =
        parameter.orders?.containsKey(SearchOrders.rating) == true;

    isUpdatedActive =
        parameter.orders?.containsKey(SearchOrders.updatedAt) == true;

    isFilterActive = [
      parameter.updatedAtSince?.isNotEmpty == true,
      parameter.includes?.isNotEmpty == true,
      parameter.contentRating?.isNotEmpty == true,
      parameter.originalLanguage?.isNotEmpty == true,
      parameter.excludedOriginalLanguages?.isNotEmpty == true,
      parameter.createdAtSince?.isNotEmpty == true,
      parameter.authors?.isNotEmpty == true,
      parameter.artists?.isNotEmpty == true,
      parameter.year != null,
      [
        parameter.includedTags?.isNotEmpty == true,
        parameter.includedTagsMode != null,
      ].every((e) => e),
      [
        parameter.excludedTags?.isNotEmpty == true,
        parameter.excludedTagsMode != null,
      ].every((e) => e),
      parameter.status?.isNotEmpty == true,
      parameter.availableTranslatedLanguage?.isNotEmpty == true,
      parameter.publicationDemographic?.isNotEmpty == true,
      parameter.group?.isNotEmpty == true,
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
      prefetchedMangaIds,
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
    Set<String>? prefetchedMangaIds,
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
      prefetchedMangaIds: prefetchedMangaIds ?? this.prefetchedMangaIds,
    );
  }
}
