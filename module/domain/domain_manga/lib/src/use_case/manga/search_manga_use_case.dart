import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../sources/sources.dart';

class SearchMangaUseCase with SyncMangasMixin {
  final MangaRepository _mangaRepository;
  final HeadlessWebviewUseCase _webview;
  final ConverterCacheManager _converterCacheManager;
  final HtmlCacheManager _htmlCacheManager;
  final SearchMangaCacheManager _searchMangaCacheManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchMangaUseCase({
    required MangaRepository mangaRepository,
    required HeadlessWebviewUseCase webview,
    required ConverterCacheManager converterCacheManager,
    required HtmlCacheManager htmlCacheManager,
    required SearchMangaCacheManager searchMangaCacheManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _mangaRepository = mangaRepository,
       _converterCacheManager = converterCacheManager,
       _htmlCacheManager = htmlCacheManager,
       _searchMangaCacheManager = searchMangaCacheManager,
       _mangaDao = mangaDao,
       _webview = webview,
       _logBox = logBox;

  Future<Pagination<Manga>> _mangadex({
    required SearchMangaParameter parameter,
  }) async {
    final result = await _mangaRepository.search(
      parameter: parameter.copyWith(
        includes: [...?parameter.includes, Include.author, Include.coverArt],
      ),
    );

    return Pagination(
      data: [...?result.data?.map((e) => Manga.from(data: e))],
      offset: result.offset?.toInt(),
      limit: result.limit?.toInt() ?? 0,
      total: result.total?.toInt() ?? 0,
    );
  }

  Future<Pagination<Manga>> _scrapping({
    required SourceExternal source,
    required SearchMangaParameter parameter,
    bool useCache = true,
  }) async {
    final url = source.searchMangaUseCase.url(parameter: parameter);

    final document = await _webview.open(
      url,
      scripts: source.searchMangaUseCase.scripts,
      useCache: useCache,
    );

    final data = await source.searchMangaUseCase.parse(root: HtmlDocument()..nodes.addAll(document.nodes));
    final mangas = await Future.wait(
      data.map(
        (e) => e.convert(logbox: _logBox, manager: _converterCacheManager),
      ),
    );

    return Pagination(
      data: mangas,
      page: parameter.page,
      limit: mangas.length,
      total: mangas.length,
      hasNextPage: await source.searchMangaUseCase.haveNextPage(root: document),
      sourceUrl: url,
    );
  }

  Future<void> clear({required SourceSearchMangaParameter parameter}) async {
    final data = await _searchMangaCacheManager.keys;
    final source = Sources.fromName(parameter.source);
    if (source == null) return;

    final List<Future<void>> promises = [
      _htmlCacheManager.removeFile(source.iconUrl),
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
      final source = Sources.fromName(parameter.source);
      final url = source?.searchMangaUseCase.url(parameter: key.parameter);
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
      final source = Sources.fromName(parameter.source);
      if (source == null) {
        throw DataNotFoundException();
      }

      final data =
          source.builtIn
              ? await _mangadex(parameter: parameter.parameter)
              : await _scrapping(
                source: source,
                parameter: parameter.parameter,
                useCache: useCache,
              );

      final result = data.copyWith(
        data: await sync(
          dao: _mangaDao,
          values: [...?data.data?.map((e) => e.copyWith(source: source.name))],
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
