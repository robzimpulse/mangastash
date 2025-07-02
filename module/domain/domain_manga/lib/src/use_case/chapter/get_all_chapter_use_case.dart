import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'search_chapter_use_case.dart';

class GetAllChapterUseCase {
  final SearchChapterUseCase _searchChapterUseCase;

  GetAllChapterUseCase({
    required SearchChapterUseCase searchChapterUseCase,
  }) : _searchChapterUseCase = searchChapterUseCase;

  Future<List<Chapter>> execute({
    required String source,
    required String mangaId,
    List<Chapter> chapters = const [],
    SearchChapterParameter? parameter,
    bool useCache = true,
  }) async {
    final param = parameter.or(
      const SearchChapterParameter(
        offset: 0,
        page: 1,
        limit: 20,
      ),
    );

    final result = await _searchChapterUseCase.execute(
      source: source,
      mangaId: mangaId,
      parameter: param,
      useCache: useCache,
    );

    if (result is Success<Pagination<Chapter>>) {
      if (result.data.hasNextPage == true) {
        return await execute(
          source: source,
          mangaId: mangaId,
          chapters: [...chapters, ...?result.data.data],
          parameter: param.copyWith(
            offset: param.offset + param.limit,
            page: param.page + 1,
            limit: param.limit,
          ),
          useCache: useCache,
        );
      }

      return [...chapters, ...?result.data.data];
    }

    return chapters;
  }
}
