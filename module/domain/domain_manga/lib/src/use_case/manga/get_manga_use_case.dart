// GetMangaUseCase: series details for a manga id, served from MangaDao when
// complete, else fetched — MangaDex via MangaService, scripted sources via
// `SourceExternal.manga(url: webUrl)` (issue #115) validated by
// requireDetailFields (a failure evicts the runner's cached result).
//
// Usage: `await useCase.execute(source: s, mangaId: id, useCache: false)`.
//
// `source` only carries the name: `execute` re-resolves it through the
// SourceRegistry, so a screen that captured the adapter before the user saved
// an edited script (Fix source) still runs the saved code.
import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../extension/map_network_error.dart';
import '../../extension/scrapped_validation_extension.dart';
import '../../manager/source_registry.dart';
import '../../mixin/sync_mangas_mixin.dart';

class GetMangaUseCase with SyncMangasMixin {
  final RunSourceScriptUseCase _runner;
  final MangaService _mangaService;
  final MangaDao _mangaDao;
  final LogBox _logBox;
  final ConverterCacheManager _converterCacheManager;
  final SourceRegistry _registry;

  GetMangaUseCase({
    required this._runner,
    required this._registry,
    required this._converterCacheManager,
    required this._mangaService,
    required this._mangaDao,
    required this._logBox,
  });

  Future<Manga> _mangadex({required String mangaId}) async {
    final result = await _mangaService.detail(
      id: mangaId,
      includes: [
        Include.author.rawValue,
        Include.artist.rawValue,
        Include.coverArt.rawValue,
      ],
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

    final data = await source.manga(url: url, useCache: useCache);

    // A detail page always names its series — a missing title means the
    // detail selectors drifted. Fail before the sync writes a null-title
    // manga into the DB (issue #114).
    final valid = await validateOrEvict(
      _runner,
      url: url,
      validate: () => data.requireDetailFields(source: source.name, url: url),
    );

    final manga = await valid.convert(
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
      final resolved = _registry.fromName(source.name) ?? source;
      final raw = await _mangaDao.search(ids: [mangaId]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      if (manga != null && manga.propertiesFilled && useCache) {
        return Success(manga);
      }

      final data =
          resolved.builtIn
              ? await _mangadex(mangaId: mangaId)
              : await _scrapping(
                url: manga?.webUrl,
                source: resolved,
                useCache: useCache,
              );

      final results = await sync(
        dao: _mangaDao,
        values: [data.copyWith(source: resolved.name)],
        logBox: _logBox,
      );

      final result = results.firstOrNull;

      if (result == null) {
        throw DataNotFoundException();
      }

      return Success(result);
    } catch (e) {
      return Error(mapNetworkError(e));
    }
  }
}
