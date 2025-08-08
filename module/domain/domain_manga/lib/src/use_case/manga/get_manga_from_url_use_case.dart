import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_detail_html_parser.dart';

class GetMangaFromUrlUseCase with SyncMangasMixin {
  final HeadlessWebviewManager _webview;
  final StorageManager _storageManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaFromUrlUseCase({
    required HeadlessWebviewManager webview,
    required StorageManager storageManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _storageManager = storageManager,
       _mangaDao = mangaDao,
       _logBox = logBox,
       _webview = webview;

  Future<Manga> _scrapping({
    required SourceEnum source,
    required String url,
  }) async {
    final document = await _webview.open(url);

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = MangaDetailHtmlParser.forSource(
      root: document,
      source: source,
      storageManager: _storageManager,
    );

    final manga = await parser.manga;

    return manga.copyWith(source: source.name, webUrl: url);
  }

  Future<Result<Manga>> execute({
    required SourceEnum source,
    required String url,
  }) async {
    final cached = await _storageManager.manga.get('${source.name}-$url');
    if (cached != null) {
      return Success(Manga.fromJson(cached));
    }

    try {
      final raw = await _mangaDao.search(webUrls: [url]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      final results = await sync(
        dao: _mangaDao,
        values: [
          await _scrapping(source: source, url: (manga?.webUrl).or(url)),
        ],
        logBox: _logBox,
      );

      final result = results.firstOrNull;

      if (result == null) {
        throw DataNotFoundException();
      }

      await _storageManager.manga.put('${source.name}-$url', result.toJson());

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
