import 'dart:convert';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_list_html_parser.dart';

class SearchMangaUseCase with SyncMangasMixin, SpanMixin {
  final MangaRepository _mangaRepository;
  final HeadlessWebviewManager _webview;
  final StorageManager _storageManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchMangaUseCase({
    required MangaRepository mangaRepository,
    required HeadlessWebviewManager webview,
    required StorageManager storageManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _mangaRepository = mangaRepository,
       _storageManager = storageManager,
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

    final document = await _webview.open(url, useCache: useCache);

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = MangaListHtmlParser.forSource(
      root: document,
      source: parameter.source,
      storageManager: _storageManager,
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
    final data = await _storageManager.searchManga.keys;
    final List<Future<void>> promises = [];
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
      promises.add(_storageManager.searchManga.removeFile(value));
      final url = key.url?.let((url) => Uri.tryParse(url).toString());
      if (url == null) continue;
      promises.add(_storageManager.html.removeFile(url));
    }
    await Future.wait(promises);
  }

  Future<Result<Pagination<Manga>>> execute({
    required SourceSearchMangaParameter parameter,
    bool useCache = true,
  }) async {
    return faro.startSpan(
      '$runtimeType',
      (span) async {
        final key = parameter.toJsonString();
        final cache = await _storageManager.searchManga.getFileFromCache(key);
        final file = await cache?.file.readAsString(encoding: utf8);
        final data = file.let((e) {
          return Pagination.fromJsonString(
            e,
            (e) => Manga.fromJson(e.castOrNull()),
          );
        });

        if (data != null && useCache) {
          span.setStatus(SpanStatusCode.ok);
          span.setAttribute('source', 'Cache');
          span.end();
          return Success(data);
        }

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

          await _storageManager.searchManga.putFile(
            key,
            key: key,
            utf8.encode(result.toJsonString((e) => e.toJson())),
            fileExtension: 'json',
            maxAge: const Duration(minutes: 30),
          );

          span.setStatus(SpanStatusCode.ok);
          return Success(result);
        } catch (e) {
          span.setStatus(SpanStatusCode.error, message: e.toString());
          return Error(e);
        } finally {
          span.setAttribute('source', 'Service');
          span.end();
        }
      },
      attributes: {
        'parameter': parameter.toString(),
        'useCache': useCache.toString(),
      },
    );
  }
}
