import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_tags_mixin.dart';
import '../../parser/base/tag_list_html_parser.dart';

class GetTagsUseCase with SyncTagsMixin {
  final HeadlessWebviewUseCase _webview;
  final ConverterCacheManager _converterCacheManager;
  final MangaService _mangaService;
  final TagDao _tagDao;
  final LogBox _logBox;

  const GetTagsUseCase({
    required HeadlessWebviewUseCase webview,
    required ConverterCacheManager converterCacheManager,
    required MangaService mangaService,
    required TagDao tagDao,
    required LogBox logBox,
  }) : _mangaService = mangaService,
       _converterCacheManager = converterCacheManager,
       _tagDao = tagDao,
       _webview = webview,
       _logBox = logBox;

  Future<List<Tag>> _mangadex({required SourceEnum source}) async {
    final result = await _mangaService.tags();

    final tags = result.data;

    if (tags == null) {
      throw DataNotFoundException();
    }

    return [
      ...tags.map((e) => Tag.from(data: e).copyWith(source: source.name)),
    ];
  }

  Future<List<Tag>> _scrapping({
    required SourceEnum source,
    bool useCache = true,
  }) async {
    final param = SourceSearchMangaParameter(
      source: source,
      parameter: const SearchMangaParameter(page: 1),
    );
    final url = param.url;

    if (url == null) {
      throw DataNotFoundException();
    }

    final selector = [
      'button',
      'inline-flex',
      'items-center',
      'whitespace-nowrap',
      'px-4',
      'py-2',
      'w-full',
      'justify-center',
      'font-normal',
      'align-middle',
      'border-solid',
    ].join('.');

    final document = await _webview.open(
      url,
      scripts: [
        if (source == SourceEnum.asurascan)
          'window.document.querySelectorAll(\'$selector\')[0].click()',
      ],
      useCache: useCache,
    );

    final parser = TagListHtmlParser.forSource(
      root: document,
      source: source,
      converterCacheManager: _converterCacheManager,
    );

    final tags = await parser.tags;

    return [...tags.map((e) => e.copyWith(source: source.name))];
  }

  Future<Result<List<Tag>>> execute({
    required SourceEnum source,
    bool useCache = true,
  }) async {
    try {
      final cache = await _tagDao.search(sources: [source.name]);
      final tags = [...cache.map(Tag.fromDrift)];
      if (tags.isNotEmpty && useCache) return Success(tags);

      final data = await switch (source) {
        SourceEnum.mangadex => _mangadex(source: source),
        _ => _scrapping(source: source, useCache: useCache),
      };

      final result = await sync(dao: _tagDao, values: data, logBox: _logBox);

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
