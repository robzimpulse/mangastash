import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_chapters_mixin.dart';

class GetChapterOnMangaClashUseCase with SyncChaptersMixin {
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;
  final HeadlessWebviewManager _webview;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  GetChapterOnMangaClashUseCase({
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required HeadlessWebviewManager webview,
    required ChapterDao chapterDao,
    required LogBox logBox,
  })  : _mangaChapterServiceFirebase = mangaChapterServiceFirebase,
        _chapterDao = chapterDao,
        _logBox = logBox,
        _webview = webview;

  Future<Result<MangaChapter>> execute({
    required String chapterId,
    required String mangaId,
  }) async {
    final raw = await _chapterDao.getChapter(chapterId);
    final result = await raw?.let(
      (e) async => MangaChapter.fromDrift(
        e,
        images: await _chapterDao.getImages(chapterId),
      ),
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

    final List<(int, String)> data = [];
    final element = document.querySelector('.reading-content');
    for (final image in element?.querySelectorAll('img') ?? <Element>[]) {
      final id = image.attributes['id']?.split('-').lastOrNull;
      if (id == null) continue;
      final url = image.attributes['data-src'];
      final index = int.tryParse(id);
      if (index == null || url == null) continue;
      data.add((index, url.trim()));
    }

    final tmp = List.of(data)..sort((a, b) => a.$1.compareTo(b.$1));
    final images = List.of(tmp.map((e) => e.$2));

    final chapters = await sync(
      mangaChapterServiceFirebase: _mangaChapterServiceFirebase,
      chapterDao: _chapterDao,
      logBox: _logBox,
      values: [result.copyWith(images: images)],
    );

    final value = chapters.firstOrNull;

    if (value == null) {
      return Error('Empty Sync Chapter');
    }

    return Success(value);
  }
}
