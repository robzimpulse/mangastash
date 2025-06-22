import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/filter_chapters_mixin.dart';
import '../../mixin/sort_chapters_mixin.dart';
import '../../mixin/sync_chapters_mixin.dart';
import '../../parser/base/chapter_list_html_parser.dart';
import 'search_chapter_on_manga_dex_use_case.dart';

class SearchChapterUseCase
    with SyncChaptersMixin, SortChaptersMixin, FilterChaptersMixin {
  final SearchChapterOnMangaDexUseCase _searchChapterOnMangaDexUseCase;
  final HeadlessWebviewManager _webview;
  final ChapterDao _chapterDao;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchChapterUseCase({
    required SearchChapterOnMangaDexUseCase searchChapterOnMangaDexUseCase,
    required HeadlessWebviewManager webview,
    required ChapterDao chapterDao,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _searchChapterOnMangaDexUseCase = searchChapterOnMangaDexUseCase,
        _chapterDao = chapterDao,
        _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Result<Pagination<Chapter>>> execute({
    required String source,
    required String mangaId,
    required SearchChapterParameter parameter,
  }) async {
    if (source == Source.mangadex().name) {
      return _searchChapterOnMangaDexUseCase.execute(
        parameter: parameter,
        mangaId: mangaId,
      );
    }

    final raw = await _mangaDao.search(ids: [mangaId]);
    final result = Manga.fromDatabase(raw.firstOrNull);

    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    final document = await _webview.open(url);

    if (document == null) {
      return Error(FailedParsingHtmlException(url));
    }

    final parser = ChapterListHtmlParser.forSource(
      root: document,
      source: source,
    );

    final data = sortChapters(
      chapters: await sync(
        dao: _chapterDao,
        logBox: _logBox,
        values: filterChapters(
          chapters: [
            ...parser.chapters.map((e) => e.copyWith(mangaId: mangaId)),
          ],
          parameter: parameter,
        ),
      ),
      parameter: parameter,
    );

    return Success(
      Pagination(
        data: data,
        page: parameter.page,
        limit: parameter.limit,
        total: parser.chapters.length,
        hasNextPage: parser.chapters.length > parameter.page * parameter.limit,
        sourceUrl: url,
      ),
    );
  }
}
