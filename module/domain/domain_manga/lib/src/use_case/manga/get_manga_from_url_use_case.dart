import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../mixin/sync_mangas_mixin.dart';

class GetMangaFromUrlUseCase with SyncMangasMixin {
  final HeadlessWebviewUseCase _webview;
  final MangaDao _mangaDao;
  final LogBox _logBox;
  final ConverterCacheManager _converterCacheManager;

  GetMangaFromUrlUseCase({
    required HeadlessWebviewUseCase webview,
    required MangaDao mangaDao,
    required LogBox logBox,
    required ConverterCacheManager converterCacheManager,
  }) : _mangaDao = mangaDao,
       _logBox = logBox,
       _webview = webview,
       _converterCacheManager = converterCacheManager;

  Future<Manga> _scrapping({
    required SourceExternal source,
    required String url,
    bool useCache = true,
  }) async {
    final document = await _webview.open(
      url,
      scripts: source.getMangaUseCase.scripts,
      useCache: useCache,
    );

    final scrapped = await source.getMangaUseCase.parse(
      root: HtmlDocument()..nodes.addAll(document.nodes),
    );

    final manga = await scrapped.convert(
      logbox: _logBox,
      manager: _converterCacheManager,
    );

    return manga.copyWith(source: source.name, webUrl: url);
  }

  Future<Result<Manga>> execute({
    required SourceExternal source,
    required String url,
    bool useCache = true,
  }) async {
    try {
      final raw = await _mangaDao.search(webUrls: [url]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      if (manga != null && manga.propertiesFilled && useCache) {
        return Success(manga);
      }

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

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
