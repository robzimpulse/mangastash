import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sort_chapters_mixin.dart';
import '../../mixin/sync_chapters_mixin.dart';
import '../../parser/asura_scan_chapter_list_html_parser.dart';

class SearchChapterOnAsuraScanUseCase
    with SyncChaptersMixin, SortChaptersMixin {
  final HeadlessWebviewManager _webview;
  final MangaDao _mangaDao;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  SearchChapterOnAsuraScanUseCase({
    required HeadlessWebviewManager webview,
    required ChapterDao chapterDao,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _chapterDao = chapterDao,
        _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Result<Pagination<MangaChapter>>> execute({
    required String? mangaId,
    required SearchChapterParameter parameter,
  }) async {
    if (mangaId == null) return Error(Exception('Manga ID Empty'));

    final raw = await _mangaDao.getManga(mangaId);
    final result = raw?.let((raw) => Manga.fromDrift(raw.$1, tags: raw.$2));
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    final document = await _webview.open(url);

    if (document == null) {
      return Error(FailedParsingHtmlException(url));
    }

    final data = sortChapters(
      chapters: await sync(
        chapterDao: _chapterDao,
        logBox: _logBox,
        values: AsuraScanChapterListHtmlParser(root: document)
            .chapters
            .map((e) => e.copyWith(mangaId: mangaId, mangaTitle: result.title))
            .toList(),
      ),
      parameter: parameter,
    );

    return Success(
      Pagination(
        data: data,
        page: 1,
        limit: data.length,
        total: data.length,
        hasNextPage: false,
        sourceUrl: url,
      ),
    );
  }
}
