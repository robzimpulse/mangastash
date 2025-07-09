import 'dart:convert';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../exception/data_not_found_exception.dart';
import '../../exception/failed_parsing_html_exception.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_detail_html_parser.dart';

class GetMangaUseCase with SyncMangasMixin {
  final HeadlessWebviewManager _webview;
  final BaseCacheManager _cacheManager;
  final MangaService _mangaService;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaUseCase({
    required HeadlessWebviewManager webview,
    required BaseCacheManager cacheManager,
    required MangaService mangaService,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _mangaService = mangaService,
        _cacheManager = cacheManager,
        _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Manga> _mangadex({
    required SourceEnum source,
    required String mangaId,
  }) async {
    final result = await _mangaService.detail(
      id: mangaId,
      includes: [Include.author.rawValue, Include.coverArt.rawValue],
    );

    final manga = result.data;

    if (manga == null) {
      throw DataNotFoundException();
    }

    return Manga.from(data: manga).copyWith(source: source.name);
  }

  Future<Manga> _scrapping({
    required SourceEnum source,
    required String? url,
  }) async {
    if (url == null) {
      throw DataNotFoundException();
    }

    final document = await _webview.open(url);

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
    required String mangaId,
    bool useCache = true,
  }) async {

    final key = '$source-$mangaId';
    final cache = await _cacheManager.getFileFromCache(key);
    final file = await cache?.file.readAsString();
    final data = file.let((e) => Manga.fromJsonString(e));

    if (data != null && useCache) {
      return Success(data);
    }

    try {
      final raw = await _mangaDao.search(ids: [mangaId]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      final promise = source == SourceEnum.mangadex
          ? _mangadex(source: source, mangaId: mangaId)
          : _scrapping(url: manga?.webUrl, source: source);

      final results = await sync(
        dao: _mangaDao,
        values: [await promise],
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
