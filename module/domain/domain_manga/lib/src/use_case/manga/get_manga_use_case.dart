import 'dart:convert';

import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_detail_html_parser.dart';

class GetMangaUseCase with SyncMangasMixin {
  final HeadlessWebviewManager _webview;
  final StorageManager _storageManager;
  final MangaService _mangaService;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaUseCase({
    required HeadlessWebviewManager webview,
    required StorageManager storageManager,
    required MangaService mangaService,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _storageManager = storageManager,
       _mangaService = mangaService,
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
      storageManager: _storageManager,
    );

    final manga = await parser.manga;

    return manga.copyWith(source: source.name, webUrl: url);
  }

  Future<Result<Manga>> execute({
    required SourceEnum source,
    required String mangaId,
  }) async {
    final key = '$source-$mangaId';
    final file = await _storageManager.chapter.getFileFromCache(key);
    final data = await file?.file.readAsString(encoding: utf8);
    final cache = Manga.fromJsonString(data ?? '');
    if (cache != null) return Success(cache);

    try {
      final raw = await _mangaDao.search(ids: [mangaId]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      final Manga data;
      if (source == SourceEnum.mangadex) {
        data = await _mangadex(source: source, mangaId: mangaId);
      } else {
        data = await _scrapping(url: manga?.webUrl, source: source);
      }

      final results = await sync(
        dao: _mangaDao,
        values: [data],
        logBox: _logBox,
      );

      final result = results.firstOrNull;

      if (result == null) {
        throw DataNotFoundException();
      }

      await _storageManager.chapter.putFile(
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
