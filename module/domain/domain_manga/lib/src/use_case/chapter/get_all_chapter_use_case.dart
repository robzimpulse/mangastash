import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'search_chapter_use_case.dart';

class GetAllChapterUseCase {
  final ValueGetter<SearchChapterUseCase> _searchChapterUseCase;

  GetAllChapterUseCase({
    required ValueGetter<SearchChapterUseCase> searchChapterUseCase,
  }) : _searchChapterUseCase = searchChapterUseCase;

  Future<List<Chapter>> execute({
    required String source,
    required String mangaId,
    List<Chapter> chapters = const [],
    SearchChapterParameter parameter = const SearchChapterParameter(
      offset: 0,
      page: 1,
      limit: 20,
    ),
  }) async {
    final result = await _searchChapterUseCase().execute(
      source: source,
      mangaId: mangaId,
      parameter: parameter,
    );

    if (result is Success<Pagination<Chapter>>) {
      if (result.data.hasNextPage == true) {
        return await execute(
          source: source,
          mangaId: mangaId,
          chapters: [...chapters, ...?result.data.data],
          parameter: SearchChapterParameter(
            offset: parameter.offset + parameter.limit,
            page: parameter.page + 1,
            limit: parameter.limit,
          ),
        );
      }
    }

    return chapters;
  }
}
