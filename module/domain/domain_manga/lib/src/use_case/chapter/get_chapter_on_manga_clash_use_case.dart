import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_chapters_mixin.dart';
import '../../parser/manga_clash_chapter_image_html_parser.dart';

class GetChapterOnMangaClashUseCase with SyncChaptersMixin {
  final HeadlessWebviewManager _webview;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  GetChapterOnMangaClashUseCase({
    required HeadlessWebviewManager webview,
    required ChapterDao chapterDao,
    required LogBox logBox,
  })  : _chapterDao = chapterDao,
        _logBox = logBox,
        _webview = webview;

  Future<Result<MangaChapter>> execute({
    required String chapterId,
    required String mangaId,
  }) async {
    final raw = await _chapterDao.getChapter(chapterId: chapterId);
    final result = await raw?.let(
      (e) async => MangaChapter.fromDrift(e.$1, images: e.$2),
    );
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    if (result.images?.isNotEmpty == true) return Success(result);

    final document = await _webview.open(url);

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }

    final chapters = await sync(
      chapterDao: _chapterDao,
      logBox: _logBox,
      values: [
        result.copyWith(
          images: MangaClashChapterImageHtmlParser(root: document).images,
        ),
      ],
    );

    final value = chapters.firstOrNull;

    if (value == null) {
      return Error('Empty Sync Chapter');
    }

    return Success(value);
  }
}
