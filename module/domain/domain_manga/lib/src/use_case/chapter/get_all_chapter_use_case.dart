import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_chapters_mixin.dart';
import 'search_chapter_use_case.dart';

class GetAllChapterUseCase with SyncChaptersMixin {
  final ValueGetter<SearchChapterUseCase> _searchChapterUseCase;

  final ChapterDao _chapterDao;
  final LogBox _logBox;

  GetAllChapterUseCase({
    required ValueGetter<SearchChapterUseCase> searchChapterUseCase,
    required ChapterDao chapterDao,
    required LogBox logBox,
  })  : _searchChapterUseCase = searchChapterUseCase,
        _chapterDao = chapterDao,
        _logBox = logBox;

  Future<List<Chapter>> execute({
    required String source,
    required String mangaId,
    List<Chapter> chapters = const [],
    SearchChapterParameter? parameter,
  }) async {
    final param = parameter.or(
      const SearchChapterParameter(
        offset: 0,
        page: 1,
        limit: 20,
      ),
    );

    final result = await _searchChapterUseCase().execute(
      source: source,
      mangaId: mangaId,
      parameter: param,
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
        );
      }
    }

    return await sync(dao: _chapterDao, values: chapters, logBox: _logBox);
  }
}
