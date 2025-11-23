import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_detail_html_parser.dart';

class GetMangaFromUrlUseCase with SyncMangasMixin {
  final HeadlessWebviewUseCase _webview;
  final ConverterCacheManager _converterCacheManager;
  final MangaCacheManager _mangaCacheManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaFromUrlUseCase({
    required HeadlessWebviewUseCase webview,
    required ConverterCacheManager converterCacheManager,
    required MangaCacheManager mangaCacheManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _converterCacheManager = converterCacheManager,
       _mangaCacheManager = mangaCacheManager,
       _mangaDao = mangaDao,
       _logBox = logBox,
       _webview = webview;

  Future<Manga> _scrapping({
    required SourceEnum source,
    required String url,
    bool useCache = true,
  }) async {
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

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = MangaDetailHtmlParser.forSource(
      root: document,
      source: source,
      converterCacheManager: _converterCacheManager,
    );

    final manga = await parser.manga;

    return manga.copyWith(source: source.name, webUrl: url);
  }

  Future<Result<Manga>> execute({
    required SourceEnum source,
    required String url,
  }) async {
    final key = '${source.name}-$url';
    final file = await _mangaCacheManager.getFileFromCache(key);
    final data = await file?.file.readAsString(encoding: utf8);
    final cache = Manga.fromJsonString(data ?? '');
    if (cache != null) return Success(cache);

    try {
      final raw = await _mangaDao.search(webUrls: [url]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      if (manga != null && manga.propertiesFilled) return Success(manga);

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

      await _mangaCacheManager.putFile(
        key,
        utf8.encode(result.toJsonString()),
        key: key,
      );

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
