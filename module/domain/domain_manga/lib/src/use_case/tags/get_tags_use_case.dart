import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_tags_mixin.dart';
import '../../parser/base/tag_list_html_parser.dart';

class GetTagsUseCase with SyncTagsMixin {
  final HeadlessWebviewUseCase _webview;
  final TagCacheManager _tagCacheManager;
  final ConverterCacheManager _converterCacheManager;
  final MangaService _mangaService;
  final TagDao _tagDao;
  final LogBox _logBox;

  const GetTagsUseCase({
    required HeadlessWebviewUseCase webview,
    required TagCacheManager tagCacheManager,
    required ConverterCacheManager converterCacheManager,
    required MangaService mangaService,
    required TagDao tagDao,
    required LogBox logBox,
  }) : _mangaService = mangaService,
       _tagCacheManager = tagCacheManager,
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
    final key = source.name;
    final file = await _tagCacheManager.getFileFromCache(key);
    final str = await file?.file.readAsString(encoding: utf8);
    final object = str?.let((e) => json.decode(e))?.castOrNull<List<dynamic>>();
    final data = [...?object?.map((e) => Tag.fromJson(e))];
    if (data.isNotEmpty && useCache) return Success(data);

    try {
      final List<Tag> data;
      if (source == SourceEnum.mangadex) {
        data = await _mangadex(source: source);
      } else {
        data = await _scrapping(source: source, useCache: useCache);
      }

      final result = await sync(dao: _tagDao, values: data, logBox: _logBox);

      await _tagCacheManager.putFile(
        key,
        utf8.encode(json.encode([...data.map((e) => e.toJson())])),
        key: key,
      );

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
