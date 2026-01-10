import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_list_html_parser.dart';

class SearchMangaUseCase with SyncMangasMixin {
  final MangaRepository _mangaRepository;
  final HeadlessWebviewUseCase _webview;

  final HtmlCacheManager _htmlCacheManager;
  final SearchMangaCacheManager _searchMangaCacheManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchMangaUseCase({
    required MangaRepository mangaRepository,
    required HeadlessWebviewUseCase webview,

    required HtmlCacheManager htmlCacheManager,
    required SearchMangaCacheManager searchMangaCacheManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _mangaRepository = mangaRepository,

       _htmlCacheManager = htmlCacheManager,
       _searchMangaCacheManager = searchMangaCacheManager,
       _mangaDao = mangaDao,
       _webview = webview,
       _logBox = logBox;

  Future<Pagination<Manga>> _mangadex({
    required SourceSearchMangaParameter parameter,
  }) async {
    final result = await _mangaRepository.search(
      parameter: parameter.parameter.copyWith(
        includes: [
          ...?parameter.parameter.includes,
          Include.author,
          Include.coverArt,
        ],
      ),
    );

    return Pagination(
      data: [
        ...?result.data?.map(
          (e) => Manga.from(data: e).copyWith(source: parameter.source.name),
        ),
      ],
      offset: result.offset?.toInt(),
      limit: result.limit?.toInt() ?? 0,
      total: result.total?.toInt() ?? 0,
    );
  }

  Future<Pagination<Manga>> _scrapping({
    required SourceSearchMangaParameter parameter,
    bool useCache = true,
  }) async {
    final url = parameter.url;

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
        if (parameter.source == SourceEnum.asurascan)
          'window.document.querySelectorAll(\'$selector\')[0].click()',
      ],
      useCache: useCache,
    );

    final parser = MangaListHtmlParser.forSource(
      root: document,
      source: parameter.source,
    );

    final mangas = await parser.mangas;

    return Pagination(
      data: [...mangas.map((e) => e.copyWith(source: parameter.source.name))],
      page: parameter.parameter.page,
      limit: mangas.length,
      total: mangas.length,
      hasNextPage: await parser.haveNextPage,
      sourceUrl: parameter.url,
    );
  }

  Future<void> clear({required SourceSearchMangaParameter parameter}) async {
    final data = await _searchMangaCacheManager.keys;
    final List<Future<void>> promises = [
      _htmlCacheManager.removeFile(parameter.source.icon),
    ];
    for (final value in data) {
      final key = SourceSearchMangaParameter.fromJsonString(value);
      if (key == null) continue;
      if (key.source != parameter.source) continue;
      final paramIgnorePagination = parameter.parameter.copyWith(
        limit: key.parameter.limit,
        offset: key.parameter.offset,
        page: key.parameter.page,
      );
      if (paramIgnorePagination != key.parameter) continue;
      promises.add(_searchMangaCacheManager.removeFile(value));
      final url = key.url?.let((url) => Uri.tryParse(url).toString());
      if (url == null) continue;
      promises.add(_htmlCacheManager.removeFile(url));
    }
    await Future.wait(promises);
  }

  Future<Result<Pagination<Manga>>> execute({
    required SourceSearchMangaParameter parameter,
    bool useCache = true,
  }) async {
    final key = parameter.toJsonString();
    final cache = await _searchMangaCacheManager.getFileFromCache(key);
    final file = await cache?.file.readAsString(encoding: utf8);
    final data = file.let((e) {
      return Pagination.fromJsonString(
        e,
        (e) => Manga.fromJson(e.castOrNull()),
      );
    });

    if (data != null && useCache) return Success(data);

    try {
      final Pagination<Manga> data;
      if (parameter.source == SourceEnum.mangadex) {
        data = await _mangadex(parameter: parameter);
      } else {
        data = await _scrapping(parameter: parameter, useCache: useCache);
      }

      final result = data.copyWith(
        data: await sync(
          dao: _mangaDao,
          values: [...?data.data],
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
      return Error(e);
    }
  }
}
