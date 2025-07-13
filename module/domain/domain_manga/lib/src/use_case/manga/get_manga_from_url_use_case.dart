import 'dart:convert';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../exception/data_not_found_exception.dart';
import '../../exception/failed_parsing_html_exception.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_detail_html_parser.dart';

class GetMangaFromUrlUseCase with SyncMangasMixin {
  final HeadlessWebviewManager _webview;
  final BaseCacheManager _cacheManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaFromUrlUseCase({
    required HeadlessWebviewManager webview,
    required BaseCacheManager cacheManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _cacheManager = cacheManager,
        _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Manga> _scrapping({
    required SourceEnum source,
    required String url,
    bool useCache = true,
  }) async {
    final document = await _webview.open(url, useCache: useCache);

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = MangaDetailHtmlParser.forSource(
      root: document,
      source: source,
    );

    return parser.manga.copyWith(source: source.name, webUrl: url);
  }

  Future<Result<Manga>> execute({
    required SourceEnum source,
    required String url,
    bool useCache = true,
  }) async {
    final key = '$source-$url';
    final cache = await _cacheManager.getFileFromCache(key);
    final file = await cache?.file.readAsString();
    final data = file.let((e) => Manga.fromJsonString(e));

    if (data != null && useCache) {
      return Success(data);
    }

    try {
      final raw = await _mangaDao.search(webUrls: [url]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      final results = await sync(
        dao: _mangaDao,
        values: [
          await _scrapping(
            source: source,
            url: (manga?.webUrl).or(url),
            useCache: useCache,
          ),
        ],
        logBox: _logBox,
      );

      final result = results.firstOrNull;

      if (result == null) {
        throw DataNotFoundException();
      }

      await _cacheManager.putFile(
        key,
        key: key,
        utf8.encode(result.toJsonString()),
        fileExtension: 'json',
        maxAge: const Duration(minutes: 30),
      );

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
