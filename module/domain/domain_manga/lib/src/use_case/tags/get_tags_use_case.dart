// GetTagsUseCase: a source's genre list, served from TagDao when it holds a
// genre list (rows with tag ids), else fetched — MangaDex via MangaService,
// scripted sources via `SourceExternal.tagsUrl()` + `tags(url:)` (issue #115).
//
// Usage: `await useCase.execute(source: s, useCache: false)`.
import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../extension/map_network_error.dart';
import '../../mixin/sync_tags_mixin.dart';

class GetTagsUseCase with SyncTagsMixin {
  final MangaService _mangaService;
  final TagDao _tagDao;
  final LogBox _logBox;

  const GetTagsUseCase({
    required MangaService mangaService,
    required TagDao tagDao,
    required LogBox logBox,
  }) : _mangaService = mangaService,
       _tagDao = tagDao,
       _logBox = logBox;

  Future<List<Tag>> _mangadex() async {
    final result = await _mangaService.tags();

    final tags = result.data;

    if (tags == null) {
      throw DataNotFoundException();
    }

    return [...tags.map((e) => Tag.from(data: e))];
  }

  Future<List<Tag>> _scrapping({
    required SourceExternal source,
    bool useCache = true,
  }) async {
    // Most sources list their genres on the search page (tagsUrl falls back
    // to searchUrl(page: 1)); sources whose tag list lives elsewhere define
    // tagsUrl (WeebCentral: the checkboxes are only on /search, not the
    // /search/data fragment).
    final url = await source.tagsUrl();
    final tags = await source.tags(url: url, useCache: useCache);

    return [...tags.map((e) => e.convert())];
  }

  Future<Result<List<Tag>>> execute({
    required SourceExternal source,
    bool useCache = true,
  }) async {
    try {
      final cache = await _tagDao.search(sources: [source.name]);
      final tags = [...cache.map(Tag.fromDrift)];
      // Name-only rows (manga detail syncs, the schema v6 repair) are not
      // a genre list: without any tag id the cache is a miss.
      final isGenreList = tags.any((e) => e.id != null);
      if (isGenreList && useCache) return Success(tags);

      final data =
          source.builtIn
              ? await _mangadex()
              : await _scrapping(source: source, useCache: useCache);

      final result = await sync(
        dao: _tagDao,
        values: [...data.map((e) => e.copyWith(source: source.name))],
        logBox: _logBox,
      );

      return Success(result);
    } catch (e) {
      return Error(mapNetworkError(e));
    }
  }
}
