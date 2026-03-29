import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../mixin/sync_mangas_mixin.dart';

class GetMangaUseCase with SyncMangasMixin {
  final HeadlessWebviewUseCase _webview;
  final MangaService _mangaService;
  final MangaDao _mangaDao;
  final LogBox _logBox;
  final ConverterCacheManager _converterCacheManager;

  GetMangaUseCase({
    required HeadlessWebviewUseCase webview,
    required ConverterCacheManager converterCacheManager,
    required MangaService mangaService,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _mangaService = mangaService,
       _mangaDao = mangaDao,
       _logBox = logBox,
       _webview = webview,
       _converterCacheManager = converterCacheManager;

  Future<Manga> _mangadex({required String mangaId}) async {
    final result = await _mangaService.detail(
      id: mangaId,
      includes: [Include.author.rawValue, Include.coverArt.rawValue],
    );

    final manga = result.data;

    if (manga == null) {
      throw DataNotFoundException();
    }

    return Manga.from(data: manga);
  }

  Future<Manga> _scrapping({
    required SourceExternal source,
    required String? url,
    bool useCache = true,
  }) async {
    if (url == null) {
      throw DataNotFoundException();
    }

    final document = await _webview.open(
      url,
      scripts: source.getMangaUseCase.scripts,
      useCache: useCache,
    );

    final data = await source.getMangaUseCase.parse(root: document);

    final manga = await data.convert(
      logbox: _logBox,
      manager: _converterCacheManager,
    );

    return manga.copyWith(source: source.name, webUrl: url);
  }

  Future<Result<Manga>> execute({
    required SourceExternal source,
    required String mangaId,
    bool useCache = true,
  }) async {
    try {
      final raw = await _mangaDao.search(ids: [mangaId]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      if (manga != null && manga.propertiesFilled && useCache) {
        return Success(manga);
      }

      final data =
          source.builtIn
              ? await _mangadex(mangaId: mangaId)
              : await _scrapping(
                url: manga?.webUrl,
                source: source,
                useCache: useCache,
              );

      final results = await sync(
        dao: _mangaDao,
        values: [data.copyWith(source: source.name)],
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
