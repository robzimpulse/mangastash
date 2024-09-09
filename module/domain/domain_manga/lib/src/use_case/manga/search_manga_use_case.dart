import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'add_or_update_manga_use_case.dart';
import 'search_manga_on_mangadex_use_case.dart';

class SearchMangaUseCase {
  final SearchMangaOnMangaDexUseCase _searchMangaOnMangaDexUseCase;
  final AddOrUpdateMangaUseCase _addOrUpdateMangaUseCase;

  const SearchMangaUseCase({
    required SearchMangaOnMangaDexUseCase searchMangaOnMangaDexUseCase,
    required AddOrUpdateMangaUseCase addOrUpdateMangaUseCase,
  })  : _searchMangaOnMangaDexUseCase = searchMangaOnMangaDexUseCase,
        _addOrUpdateMangaUseCase = addOrUpdateMangaUseCase;

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

    if (result is Success<Pagination<Manga>>) {
      final mangas = result.data.data ?? [];
      await _addOrUpdateMangaUseCase.execute(
        data: mangas.map((e) => e.copyWith(source: source)).toList(),
      );
    }

    return result;
  }
}
