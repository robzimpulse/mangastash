import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'search_chapter_use_case.dart';

class GetAllChapterUseCase {
  final SearchChapterUseCase _searchChapterUseCase;

  GetAllChapterUseCase({required SearchChapterUseCase searchChapterUseCase})
    : _searchChapterUseCase = searchChapterUseCase;

  Future<List<Chapter>> execute({
    required SourceEnum source,
    required String mangaId,
    SearchChapterParameter? parameter,
    bool useCache = true,
  }) async {
    final param = parameter.or(
      const SearchChapterParameter(offset: 0, page: 1, limit: 20),
    );

    final result = await _searchChapterUseCase.execute(
      parameter: SourceSearchChapterParameter(
        source: source,
        parameter: param,
        mangaId: mangaId,
      ),
      useCache: useCache,
    );

    if (result is Success<Pagination<Chapter>>) {
      return [
        ...?result.data.data,
        if (result.data.hasNextPage == true)
          ...await execute(
            source: source,
            mangaId: mangaId,
            parameter: param.copyWith(
              offset: param.offset + param.limit,
              page: param.page + 1,
              limit: param.limit,
            ),
          ),
      ];
    }

    return [];
  }
}
