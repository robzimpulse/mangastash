import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class BrowseMangaScreenState extends Equatable {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  final SourceEnum? source;

  final bool hasNextPage;

  final bool isPagingNextPage;

  final bool isSearchActive;

  final SearchMangaParameter parameter;

  final List<Tag> tags;

  final Set<String> prefetchedMangaIds;

  final Set<String> libraryMangaIds;

  bool get isFavoriteActive {
    return parameter.orders?.containsKey(SearchOrders.rating) == true;
  }

  bool get isUpdatedActive {
    return parameter.orders?.containsKey(SearchOrders.updatedAt) == true;
  }

  bool get isFilterActive {
    return [
      parameter.updatedAtSince?.isNotEmpty == true,
      parameter.includes?.isNotEmpty == true,
      parameter.contentRating?.isNotEmpty == true,
      parameter.originalLanguage?.isNotEmpty == true,
      parameter.excludedOriginalLanguages?.isNotEmpty == true,
      parameter.createdAtSince?.isNotEmpty == true,
      parameter.authors?.isNotEmpty == true,
      parameter.artists?.isNotEmpty == true,
      parameter.year != null,
      parameter.includedTags?.isNotEmpty == true,
      parameter.excludedTags?.isNotEmpty == true,
      parameter.status?.isNotEmpty == true,
      parameter.availableTranslatedLanguage?.isNotEmpty == true,
      parameter.publicationDemographic?.isNotEmpty == true,
      parameter.group?.isNotEmpty == true,
    ].contains(true);
  }

  const BrowseMangaScreenState({
    this.isLoading = false,
    this.hasNextPage = false,
    this.isPagingNextPage = false,
    this.isSearchActive = false,
    this.error,
    this.source,
    this.mangas = const [],
    this.libraryMangaIds = const {},
    this.parameter = const SearchMangaParameter(),
    this.prefetchedMangaIds = const {},
    this.tags = const [],
  });

  @override
  List<Object?> get props {
    return [
      isLoading,
      hasNextPage,
      isPagingNextPage,
      error,
      source,
      mangas,
      parameter,
      isSearchActive,
      libraryMangaIds,
      prefetchedMangaIds,
      tags,
    ];
  }

  BrowseMangaScreenState copyWith({
    bool? isLoading,
    bool? hasNextPage,
    bool? isPagingNextPage,
    bool? isSearchActive,
    ValueGetter<Exception?>? error,
    SourceEnum? source,
    List<Manga>? mangas,
    Set<String>? libraryMangaIds,
    SearchMangaParameter? parameter,
    Set<String>? prefetchedMangaIds,
    List<Tag>? tags,
  }) {
    return BrowseMangaScreenState(
      isLoading: isLoading ?? this.isLoading,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPagingNextPage: isPagingNextPage ?? this.isPagingNextPage,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      mangas: mangas ?? this.mangas,
      libraryMangaIds: libraryMangaIds ?? this.libraryMangaIds,
      error: error != null ? error() : this.error,
      source: source ?? this.source,
      parameter: parameter ?? this.parameter,
      prefetchedMangaIds: prefetchedMangaIds ?? this.prefetchedMangaIds,
      tags: tags ?? this.tags,
    );
  }
}
