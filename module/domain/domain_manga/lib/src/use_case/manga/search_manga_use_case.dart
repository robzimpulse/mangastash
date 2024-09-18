import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'search_manga_on_mangadex_use_case.dart';

class SearchMangaUseCase {
  final SearchMangaOnMangaDexUseCase _searchMangaOnMangaDexUseCase;

  const SearchMangaUseCase({
    required SearchMangaOnMangaDexUseCase searchMangaOnMangaDexUseCase,
  }) : _searchMangaOnMangaDexUseCase = searchMangaOnMangaDexUseCase;

  Future<Result<Pagination<Manga>>> execute({
    required MangaSourceEnum? source,
    required SearchMangaParameter parameter,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    final Result<Pagination<Manga>> result;

    switch (source) {
      case MangaSourceEnum.mangadex:
        result = await _searchMangaOnMangaDexUseCase.execute(
          parameter: parameter,
        );
        break;
      case MangaSourceEnum.asurascan:
        result = Error(Exception('Unimplemented for ${source.name}'));
        break;
    }

    return result;
  }
}
