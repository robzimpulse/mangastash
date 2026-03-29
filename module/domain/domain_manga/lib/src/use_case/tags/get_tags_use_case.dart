import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../mixin/sync_tags_mixin.dart';

class GetTagsUseCase with SyncTagsMixin {
  final HeadlessWebviewUseCase _webview;
  final MangaService _mangaService;
  final TagDao _tagDao;
  final LogBox _logBox;

  const GetTagsUseCase({
    required HeadlessWebviewUseCase webview,
    required MangaService mangaService,
    required TagDao tagDao,
    required LogBox logBox,
  }) : _mangaService = mangaService,
       _tagDao = tagDao,
       _webview = webview,
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
    final url = source.searchMangaUseCase.url(
      parameter: const SearchMangaParameter(page: 1),
    );

    final document = await _webview.open(
      url,
      scripts: source.listTagUseCase.scripts,
      useCache: useCache,
    );

    final tags = await source.listTagUseCase.parse(root: HtmlDocument()..nodes.addAll(document.nodes));

    return [...tags.map((e) => e.convert())];
  }

  Future<Result<List<Tag>>> execute({
    required SourceExternal source,
    bool useCache = true,
  }) async {
    try {
      final cache = await _tagDao.search(sources: [source.name]);
      final tags = [...cache.map(Tag.fromDrift)];
      if (tags.isNotEmpty && useCache) return Success(tags);

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
      return Error(e);
    }
  }
}
