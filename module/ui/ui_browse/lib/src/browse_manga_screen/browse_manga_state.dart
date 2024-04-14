import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class BrowseMangaState extends Equatable {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  final MangaShelfItemLayout layout;

  final String? sourceId;

  final MangaSource? source;

  final bool hasNextPage;

  final bool isPagingNextPage;

  final SearchMangaParameter parameter;

  const BrowseMangaState({
    this.isLoading = false,
    this.hasNextPage = false,
    this.isPagingNextPage = false,
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
    ];
  }

  BrowseMangaState copyWith({
    bool? isLoading,
    bool? hasNextPage,
    bool? isPagingNextPage,
    ValueGetter<Exception?>? error,
    MangaShelfItemLayout? layout,
    String? sourceId,
    MangaSource? source,
    List<Manga>? mangas,
    SearchMangaParameter? parameter,
  }) {
    return BrowseMangaState(
      isLoading: isLoading ?? this.isLoading,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPagingNextPage : isPagingNextPage ?? this.isPagingNextPage,
      mangas: mangas ?? this.mangas,
      error: error != null ? error() : this.error,
      layout: layout ?? this.layout,
      sourceId: sourceId ?? this.sourceId,
      source: source ?? this.source,
      parameter: parameter ?? this.parameter,
    );
  }
}
