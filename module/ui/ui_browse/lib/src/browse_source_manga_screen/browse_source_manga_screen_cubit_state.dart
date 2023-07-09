import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseSourceMangaScreenCubitState extends Equatable {
  final bool isLoading;

  final String? errorMessage;

  final SearchMangaParameter parameter;

  final List<Manga> mangas;

  final bool hasNextPage;

  final bool isPagingNextPage;

  const BrowseSourceMangaScreenCubitState({
    this.isLoading = false,
    this.errorMessage,
    this.mangas = const [],
    this.parameter = const SearchMangaParameter(),
    this.hasNextPage = false,
    this.isPagingNextPage = false,
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
    ];
  }

  BrowseSourceMangaScreenCubitState copyWith({
    bool? isLoading,
    bool? hasNextPage,
    bool? isPagingNextPage,
    String? Function()? errorMessage,
    SearchMangaParameter? parameter,
    List<Manga>? mangas,
  }) {
    return BrowseSourceMangaScreenCubitState(
      isLoading: isLoading ?? this.isLoading,
      isPagingNextPage: isPagingNextPage ?? this.isPagingNextPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      parameter: parameter ?? this.parameter,
      mangas: mangas ?? this.mangas,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
