import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'search_chapter_use_case.dart';

class GetAllChapterUseCase {
  static const int maxPages = 10;

  final SearchChapterUseCase _searchChapterUseCase;
  final LogBox _logBox;

  GetAllChapterUseCase({
    required SearchChapterUseCase searchChapterUseCase,
    required LogBox logBox,
  }) : _searchChapterUseCase = searchChapterUseCase,
       _logBox = logBox;

  Future<List<Chapter>> execute({
    required SourceExternal source,
    required String mangaId,
    SearchChapterParameter? parameter,
    bool useCache = true,
  }) async {
    var param = parameter.or(
      const SearchChapterParameter(offset: 0, page: 1, limit: 500),
    );

    /// force other source to use cache on every page since only
    /// mangadex use true pagination, while other source provide all
    /// chapter on the first fetch
    final fetchCache = source.builtIn ? useCache : true;

    final chapters = <Chapter>[];
    var fetchedPages = 0;

    while (true) {
      final result = await _searchChapterUseCase.execute(
        parameter: SourceSearchChapterParameter(
          source: source.name,
          parameter: param,
          mangaId: mangaId,
        ),
        useCache: fetchCache,
      );

      if (result is! Success<Pagination<Chapter>>) {
        // The page error is already mapped by SearchChapterUseCase; dropping
        // it here must at least be visible — otherwise a truncated list
        // looks complete and nothing ever retries (review on #182).
        _logBox.log(
          'Get all chapters stopped early on a failed page; returning pages '
          'collected so far',
          extra: {
            'source': source.name,
            'mangaId': mangaId,
            'fetchedPages': fetchedPages,
            'error': result is Error<Pagination<Chapter>> ? result.error : result,
          },
          name: runtimeType.toString(),
        );
        break;
      }

      chapters.addAll([...?result.data.data]);
      fetchedPages++;

      if (result.data.hasNextPage != true) break;

      if (fetchedPages >= maxPages) {
        _logBox.log(
          'Get all chapters stopped after $maxPages pages',
          extra: {
            'source': source.name,
            'mangaId': mangaId,
            'fetchedPages': fetchedPages,
          },
          name: runtimeType.toString(),
        );
        break;
      }

      param = param.copyWith(
        offset: param.offset + param.limit,
        page: param.page + 1,
        limit: param.limit,
      );
    }

    return chapters;
  }
}
