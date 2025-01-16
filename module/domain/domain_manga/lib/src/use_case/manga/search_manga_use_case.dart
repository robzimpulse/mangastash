import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'search_manga_on_asura_scan_use_case.dart';
import 'search_manga_on_manga_clash_use_case.dart';
import 'search_manga_on_mangadex_use_case.dart';

class SearchMangaUseCase {
  final SearchMangaOnMangaDexUseCase _searchMangaOnMangaDexUseCase;
  final SearchMangaOnMangaClashUseCaseUseCase
      _searchMangaOnMangaClashUseCaseUseCase;
  final SearchMangaOnAsuraScanUseCase _searchMangaOnAsuraScanUseCase;

  const SearchMangaUseCase({
    required SearchMangaOnMangaDexUseCase searchMangaOnMangaDexUseCase,
    required SearchMangaOnMangaClashUseCaseUseCase
        searchMangaOnMangaClashUseCaseUseCase,
    required SearchMangaOnAsuraScanUseCase searchMangaOnAsuraScanUseCase,
  })  : _searchMangaOnMangaDexUseCase = searchMangaOnMangaDexUseCase,
        _searchMangaOnMangaClashUseCaseUseCase =
            searchMangaOnMangaClashUseCaseUseCase,
        _searchMangaOnAsuraScanUseCase = searchMangaOnAsuraScanUseCase;

  Future<Result<Pagination<Manga>>> execute({
    required MangaSourceEnum? source,
    required SearchMangaParameter parameter,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    return switch (source) {
      MangaSourceEnum.mangadex => _searchMangaOnMangaDexUseCase.execute(
          parameter: parameter,
        ),
      MangaSourceEnum.asurascan => _searchMangaOnAsuraScanUseCase.execute(
          parameter: parameter,
        ),
      MangaSourceEnum.mangaclash =>
        _searchMangaOnMangaClashUseCaseUseCase.execute(
          parameter: parameter,
        ),
    };
  }
}
