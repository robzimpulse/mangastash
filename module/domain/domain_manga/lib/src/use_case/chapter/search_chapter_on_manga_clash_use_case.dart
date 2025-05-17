import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sort_chapters_mixin.dart';
import '../../mixin/sync_chapters_mixin.dart';

class SearchChapterOnMangaClashUseCase
    with SyncChaptersMixin, SortChaptersMixin {
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;
  final HeadlessWebviewManager _webview;
  final MangaDao _mangaDao;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  SearchChapterOnMangaClashUseCase({
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required HeadlessWebviewManager webview,
    required ChapterDao chapterDao,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _mangaServiceFirebase = mangaServiceFirebase,
        _mangaChapterServiceFirebase = mangaChapterServiceFirebase,
        _chapterDao = chapterDao,
        _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Result<Pagination<MangaChapter>>> execute({
    required String? mangaId,
    required SearchChapterParameter parameter,
  }) async {
    if (mangaId == null) return Error(Exception('Manga ID Empty'));

    final result = await _mangaDao.getManga(mangaId);
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    final document = await _webview.open(url);

    if (document == null) {
      return Error(FailedParsingHtmlException(url));
    }

    final List<MangaChapter> chapters = [];

    for (final element in document.querySelectorAll('li.wp-manga-chapter')) {
      final url = element.querySelector('a')?.attributes['href'];
      final title = element.querySelector('a')?.text.split('-').lastOrNull;
      final text = element.querySelector('a')?.text.split(' ').map(
        (text) {
          final value = double.tryParse(text);

          if (value != null) {
            final fraction = value - value.truncate();
            if (fraction > 0.0) return value;
          }

          return int.tryParse(text);
        },
      );
      final releaseDate = element
          .querySelector('.chapter-release-date')
          ?.text
          .trim()
          .asDateTime
          ?.toIso8601String();
      final chapter = text?.nonNulls.firstOrNull;

      chapters.add(
        MangaChapter(
          mangaId: mangaId,
          mangaTitle: result.title,
          title: title?.trim(),
          chapter: chapter != null ? '$chapter' : null,
          readableAt: releaseDate,
          webUrl: url,
        ),
      );
    }

    final data = sortChapters(
      chapters: await sync(
        mangaChapterServiceFirebase: _mangaChapterServiceFirebase,
        chapterDao: _chapterDao,
        logBox: _logBox,
        values: chapters,
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
