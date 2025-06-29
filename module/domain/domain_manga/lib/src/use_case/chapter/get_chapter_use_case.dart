import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_chapters_mixin.dart';
import '../../parser/base/chapter_image_html_parser.dart';
import 'get_chapter_on_manga_dex_use_case.dart';

class GetChapterUseCase with SyncChaptersMixin {
  final GetChapterOnMangaDexUseCase _getChapterOnMangaDexUseCase;
  final HeadlessWebviewManager _webview;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  GetChapterUseCase({
    required GetChapterOnMangaDexUseCase getChapterOnMangaDexUseCase,
    required HeadlessWebviewManager webview,
    required ChapterDao chapterDao,
    required LogBox logBox,
  })  : _getChapterOnMangaDexUseCase = getChapterOnMangaDexUseCase,
        _chapterDao = chapterDao,
        _logBox = logBox,
        _webview = webview;

  Future<Result<Chapter>> execute({
    required String source,
    required String mangaId,
    required String chapterId,
  }) async {
    if (source == Source.mangadex().name) {
      return _getChapterOnMangaDexUseCase.execute(
        chapterId: chapterId,
        mangaId: mangaId,
      );
    }

    final raw = await _chapterDao.search(ids: [chapterId]);
    final result = raw.firstOrNull.let(
      (e) => e.chapter?.let((d) => Chapter.fromDrift(d, images: e.images)),
    );
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    if (result.images?.isNotEmpty == true) {
      return Success(result);
    }

    final document = await _webview.open(url);

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }

    final parser = ChapterImageHtmlParser.forSource(
      root: document,
      source: source,
    );

    final chapters = await sync(
      dao: _chapterDao,
      logBox: _logBox,
      values: [result.copyWith(images: parser.images)],
    );

    final value = chapters.firstOrNull;

    if (value == null) {
      return Error('Empty Sync Chapter');
    }

    return Success(value);
  }
}
