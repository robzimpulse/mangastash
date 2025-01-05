import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'search_manga_on_asura_scan_use_case.dart';
import 'search_manga_on_manga_clash_use_case.dart';
import 'search_manga_on_mangadex_use_case.dart';

class SearchMangaUseCase {
  final SearchMangaOnMangaDexUseCase _searchMangaOnMangaDexUseCase;
  final SearchMangaOnAsuraScanUseCase _searchMangaOnAsuraScanUseCase;
  final SearchMangaOnMangaClashUseCaseUseCase
      _searchMangaOnMangaClashUseCaseUseCase;

  const SearchMangaUseCase({
    required SearchMangaOnMangaDexUseCase searchMangaOnMangaDexUseCase,
    required SearchMangaOnAsuraScanUseCase searchMangaOnAsuraScanUseCase,
    required SearchMangaOnMangaClashUseCaseUseCase
        searchMangaOnMangaClashUseCaseUseCase,
  })  : _searchMangaOnMangaDexUseCase = searchMangaOnMangaDexUseCase,
        _searchMangaOnAsuraScanUseCase = searchMangaOnAsuraScanUseCase,
        _searchMangaOnMangaClashUseCaseUseCase =
            searchMangaOnMangaClashUseCaseUseCase;

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
