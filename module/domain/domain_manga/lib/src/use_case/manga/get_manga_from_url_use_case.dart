// GetMangaFromUrlUseCase: series details for a pasted series URL of a
// scripted source, served from MangaDao when complete, else fetched via
// `SourceExternal.manga(url:)` (issue #115) and validated by
// requireDetailFields (a failure evicts the runner's cached result).
//
// Usage: `await useCase.execute(source: s, url: link)`.
import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../extension/map_network_error.dart';
import '../../extension/scrapped_validation_extension.dart';
import '../../mixin/sync_mangas_mixin.dart';

class GetMangaFromUrlUseCase with SyncMangasMixin {
  final RunSourceScriptUseCase _runner;
  final MangaDao _mangaDao;
  final LogBox _logBox;
  final ConverterCacheManager _converterCacheManager;

  GetMangaFromUrlUseCase({
    required RunSourceScriptUseCase runner,
    required MangaDao mangaDao,
    required LogBox logBox,
    required ConverterCacheManager converterCacheManager,
  }) : _mangaDao = mangaDao,
       _logBox = logBox,
       _runner = runner,
       _converterCacheManager = converterCacheManager;

  Future<Manga> _scrapping({
    required SourceExternal source,
    required String url,
    bool useCache = true,
  }) async {
    final scrapped = await source.manga(url: url, useCache: useCache);

    // A detail page always names its series — a missing title means the
    // detail selectors drifted. Fail before the sync writes a null-title
    // manga into the DB (issue #114).
    final valid = await validateOrEvict(
      _runner,
      url: url,
      validate: () {
        return scrapped.requireDetailFields(source: source.name, url: url);
      },
    );

    final manga = await valid.convert(
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
      return Error(mapNetworkError(e));
    }
  }
}
