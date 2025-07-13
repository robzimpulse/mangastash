import 'dart:convert';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../exception/data_not_found_exception.dart';
import '../../exception/failed_parsing_html_exception.dart';
import '../../extension/search_url_extension.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_tags_mixin.dart';
import '../../parser/base/tag_list_html_parser.dart';

class GetTagsUseCase with SyncTagsMixin {
  final HeadlessWebviewManager _webview;
  final BaseCacheManager _cacheManager;
  final MangaService _mangaService;
  final TagDao _tagDao;
  final LogBox _logBox;

  const GetTagsUseCase({
    required HeadlessWebviewManager webview,
    required BaseCacheManager cacheManager,
    required MangaService mangaService,
    required TagDao tagDao,
    required LogBox logBox,
  })  : _mangaService = mangaService,
        _cacheManager = cacheManager,
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
      ...tags.map((e) => Tag.from(data: e).copyWith(source: source.name))
    ];
  }

  Future<List<Tag>> _scrapping({
    required SourceEnum source,
    bool useCache = true,
  }) async {
    const parameter = SearchMangaParameter(page: 1);
    String url = '';
    if (source == SourceEnum.asurascan) {
      url = parameter.asurascan;
    } else if (source == SourceEnum.mangaclash) {
      url = parameter.mangaclash;
    }

    final document = await _webview.open(
      url,
      scripts: [
        if (source == SourceEnum.asurascan)
          'window.document.querySelectorAll(\'${[
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
          ].join('.')}\')[0].click()',
      ],
    );

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = TagListHtmlParser.forSource(
      root: document,
      source: source,
    );

    return [...parser.tags.map((e) => e.copyWith(source: source.name))];
  }

  Future<Result<List<Tag>>> execute({
    required SourceEnum source,
    bool useCache = true,
  }) async {
    final cache = await _cacheManager.getFileFromCache(source.name);
    final file = await cache?.file.readAsString();
    final object = file.let((e) => json.decode(e))?.castOrNull<List<dynamic>>();
    final data = [...?object?.map((e) => Tag.fromJson(e))];

    if (data.isNotEmpty && useCache) {
      return Success(data);
    }

    try {
      final promise = source == SourceEnum.mangadex
          ? _mangadex(source: source)
          : _scrapping(source: source, useCache: useCache);

      final data = await sync(
        dao: _tagDao,
        values: await promise,
        logBox: _logBox,
      );

      await _cacheManager.putFile(
        source.name,
        key: source.name,
        utf8.encode(json.encode([...data.map((e) => e.toJson())])),
        fileExtension: 'json',
        maxAge: const Duration(minutes: 30),
      );

      return Success(data);
    } catch (e) {
      return Error(e);
    }
  }
}
