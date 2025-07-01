import 'dart:convert';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

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
    required String source,
    required Manga? manga,
  }) async {
    final url = manga?.webUrl;

    if (manga == null || url == null) {
      throw Exception('Data not found');
    }

    final isValid = [
      manga.title != null,
      manga.coverUrl != null,
      manga.author != null,
      manga.description != null,
      manga.tags?.isNotEmpty == true,
    ].every((e) => e);

    if (isValid) {
      return manga;
    }

    final document = await _webview.open(url);

    if (document == null) {
      throw Exception('Error parsing html');
    }

    final parser = MangaDetailHtmlParser.forSource(
      root: document,
      source: source,
    );

    return parser.manga.copyWith(source: source, webUrl: url);
  }

  Future<Result<Manga>> execute({
    required String source,
    required String url,
  }) async {
    final key = '$source-$url';
    final cache = await _cacheManager.getFileFromCache(key);
    final file = await cache?.file.readAsString();
    final data = file.let((e) => Manga.fromJsonString(e));

    if (data != null) {
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
            manga: manga.or(Manga(webUrl: url)),
          ),
        ],
        logBox: _logBox,
      );

      final result = results.firstOrNull;

      if (result == null) {
        throw Exception('Data not found');
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
