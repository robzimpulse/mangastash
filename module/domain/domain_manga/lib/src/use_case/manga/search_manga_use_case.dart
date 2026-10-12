// SearchMangaUseCase: one page of search/browse results for a source, cached
// for 30 minutes per SourceSearchMangaParameter and the script version
// (`SourceCacheVersion.cacheVersion`, so a saved script edit never serves the
// old script's cards) and synced into MangaDao.
// MangaDex goes through MangaRepository; scripted sources resolve their search
// URL and cards through SourceExternal (issue #115), validated by
// requireCardFields — a failed validation evicts the runner's cached script
// result for that URL.
//
// Usage: `await useCase.execute(parameter: p)` → Result<Pagination<Manga>>;
// `await useCase.clear(parameter: p)` drops the cached pages (and the script
// results behind them) before a refresh.
import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../extension/map_network_error.dart';
import '../../extension/scrapped_validation_extension.dart';
import '../../extension/source_cache_version_extension.dart';
import '../../manager/source_registry.dart';
import '../../mixin/sync_mangas_mixin.dart';

class SearchMangaUseCase with SyncMangasMixin {
  final MangaRepository _mangaRepository;
  final RunSourceScriptUseCase _runner;
  final SourceRegistry _registry;
  final ConverterCacheManager _converterCacheManager;
  final SearchMangaCacheManager _searchMangaCacheManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchMangaUseCase({
    required MangaRepository mangaRepository,
    required RunSourceScriptUseCase runner,
    required SourceRegistry registry,
    required ConverterCacheManager converterCacheManager,
    required SearchMangaCacheManager searchMangaCacheManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _mangaRepository = mangaRepository,
       _converterCacheManager = converterCacheManager,
       _searchMangaCacheManager = searchMangaCacheManager,
       _mangaDao = mangaDao,
       _runner = runner,
       _registry = registry,
       _logBox = logBox;

  Future<Pagination<Manga>> _mangadex({
    required SearchMangaParameter parameter,
  }) async {
    final result = await _mangaRepository.search(
      parameter: parameter.copyWith(
        includes: [
          ...?parameter.includes,
          Include.author,
          Include.artist,
          Include.coverArt,
        ],
      ),
    );

    return Pagination(
      data: [...?result.data?.map((e) => Manga.from(data: e))],
      offset: result.offset?.toInt(),
      limit: result.limit?.toInt() ?? 0,
      total: result.total?.toInt() ?? 0,
    );
  }

  Future<Pagination<Manga>> _scrapping({
    required SourceExternal source,
    required SearchMangaParameter parameter,
    bool useCache = true,
  }) async {
    final url = await source.searchUrl(parameter: parameter);

    final data = await source.search(
      url: url,
      searchTerm: parameter.title,
      useCache: useCache,
    );
    // Drop cards the extraction came back half-empty for, and fail fast
    // when a page full of cards yields nothing usable — rendering "no
    // results" for a broken parse would hide the breakage (issue #114).
    final cards = await validateOrEvict(
      _runner,
      url: url,
      validate:
          () => data.items.requireCardFields(
            source: source.name,
            url: url,
            logBox: _logBox,
          ),
    );
    final mangas = await Future.wait(
      cards.map(
        (e) => e.convert(logbox: _logBox, manager: _converterCacheManager),
      ),
    );

    return Pagination(
      data: mangas,
      page: parameter.page,
      limit: mangas.length,
      total: mangas.length,
      hasNextPage: data.hasNextPage,
      sourceUrl: url,
    );
  }

  Future<void> clear({required SourceSearchMangaParameter parameter}) async {
    final data = await _searchMangaCacheManager.keys;
    final source = _registry.fromName(parameter.source);

    final List<Future<void>> promises = [];

    for (final value in data) {
      final key = SourceSearchMangaParameter.fromJsonString(
        stripCacheVersion(value),
      );
      if (key == null) continue;
      if (key.source != parameter.source) continue;
      final paramIgnorePagination = parameter.parameter.copyWith(
        limit: key.parameter.limit,
        offset: key.parameter.offset,
        page: key.parameter.page,
      );
      if (paramIgnorePagination != key.parameter) continue;
      // The file removal must not depend on the registry lookup below: a
      // source deleted from the registry (custom source removed) still owns
      // cached files here, and they must not be orphaned (review on #194;
      // SearchChapterUseCase.clear is the sibling shape).
      promises.add(_searchMangaCacheManager.removeFile(value));
      // Built-in sources have no scraping hooks (they throw
      // UnimplementedError by design) and never cache script results, so
      // only scraped sources resolve a URL to evict from the runner cache.
      if (source != null && !source.builtIn) {
        // A failing searchUrl script must not break the refresh that
        // follows; the fetch reports that error itself.
        promises.add(_evictSearch(source: source, parameter: key.parameter));
      }
    }
    await Future.wait(promises);
  }

  Future<void> _evictSearch({
    required SourceExternal source,
    required SearchMangaParameter parameter,
  }) async {
    try {
      final url = await source.searchUrl(parameter: parameter);
      await _runner.evict(url: url);
    } catch (e) {
      _logBox.log(
        'Failed to evict search results',
        extra: {'source': source.name, 'error': e.toString()},
        name: runtimeType.toString(),
      );
    }
  }

  Future<Result<Pagination<Manga>>> execute({
    required SourceSearchMangaParameter parameter,
    bool useCache = true,
  }) async {
    // The script version is part of the key: after the user saves an edited
    // script the old entry is never read again (issue #115, Review Focus 5).
    final source = _registry.fromName(parameter.source);
    final key = '${parameter.toJsonString()}${source?.cacheVersion ?? ''}';

    // A corrupt or partially-written cache file must be treated as a miss
    // (issue #122): this read happens before the fetch try below and used
    // to escape execute() entirely, stalling the calling cubit's loading
    // state forever.
    Pagination<Manga>? cached;
    try {
      final cache = await _searchMangaCacheManager.getFileFromCache(key);
      final file = await cache?.file.readAsString(encoding: utf8);
      cached = file.let((e) {
        return Pagination.fromJsonString(
          e,
          (e) => Manga.fromJson(e.castOrNull()),
        );
      });
    } catch (e, st) {
      // The read must never break the fetch — a poisoned cache is always
      // treated as a miss — but leave a trace, or it is undebuggable in
      // the field (review on #160).
      _logBox.log(
        'Corrupt search cache treated as a miss',
        extra: {'key': key, 'error': e.toString(), 'stack': st.toString()},
        name: runtimeType.toString(),
      );
      cached = null;
    }

    if (cached != null && useCache) return Success(cached);

    try {
      if (source == null) {
        throw DataNotFoundException();
      }

      final data =
          source.builtIn
              ? await _mangadex(parameter: parameter.parameter)
              : await _scrapping(
                source: source,
                parameter: parameter.parameter,
                useCache: useCache,
              );

      final result = data.copyWith(
        data: await sync(
          dao: _mangaDao,
          values: [...?data.data?.map((e) => e.copyWith(source: source.name))],
          logBox: _logBox,
        ),
      );

      await _searchMangaCacheManager.putFile(
        key,
        key: key,
        utf8.encode(result.toJsonString((e) => e.toJson())),
        fileExtension: 'json',
        maxAge: const Duration(minutes: 30),
      );

      return Success(result);
    } catch (e) {
      return Error(mapNetworkError(e));
    }
  }
}
