import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class BrowseMangaDexState extends Equatable {
  final bool isLoading;

  final String? errorMessage;

  final SearchMangaParameter parameter;

  final List<Manga> mangas;

  final bool hasNextPage;

  final bool isPagingNextPage;

  final bool isSearchActive;

  final MangaShelfItemLayout layout;

  const BrowseMangaDexState({
    this.isLoading = false,
    this.errorMessage,
    this.mangas = const [],
    this.parameter = const SearchMangaParameter(),
    this.hasNextPage = false,
    this.isPagingNextPage = false,
    this.isSearchActive = false,
    this.layout = MangaShelfItemLayout.comfortableGrid,
  });

  @override
  List<Object?> get props {
    return [
      errorMessage,
      isLoading,
      mangas,
      parameter,
      hasNextPage,
      isPagingNextPage,
      isSearchActive,
      layout,
    ];
  }

  BrowseMangaDexState copyWith({
    bool? isLoading,
    bool? hasNextPage,
    bool? isPagingNextPage,
    bool? isSearchActive,
    String? Function()? errorMessage,
    SearchMangaParameter? parameter,
    List<Manga>? mangas,
    MangaShelfItemLayout? layout,
  }) {
    return BrowseMangaDexState(
      isLoading: isLoading ?? this.isLoading,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      isPagingNextPage: isPagingNextPage ?? this.isPagingNextPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      parameter: parameter ?? this.parameter,
      mangas: mangas ?? this.mangas,
      layout: layout ?? this.layout,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}