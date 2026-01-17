import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../mixin/filter_chapters_mixin.dart';
import '../../mixin/sort_chapters_mixin.dart';
import '../../mixin/sync_chapters_mixin.dart';
import '../../parser/base/chapter_list_html_parser.dart';

class SearchChapterUseCase
    with SyncChaptersMixin, SortChaptersMixin, FilterChaptersMixin {
  final ChapterRepository _chapterRepository;
  final HeadlessWebviewUseCase _webview;
  final ConverterCacheManager _converterCacheManager;
  final SearchChapterCacheManager _searchChapterCacheManager;
  final HtmlCacheManager _htmlCacheManager;
  final ChapterDao _chapterDao;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchChapterUseCase({
    required ChapterRepository chapterRepository,
    required HeadlessWebviewUseCase webview,
    required ConverterCacheManager converterCacheManager,
    required HtmlCacheManager htmlCacheManager,
    required SearchChapterCacheManager searchChapterCacheManager,
    required ChapterDao chapterDao,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _chapterRepository = chapterRepository,
       _converterCacheManager = converterCacheManager,
       _htmlCacheManager = htmlCacheManager,
       _searchChapterCacheManager = searchChapterCacheManager,
       _chapterDao = chapterDao,
       _mangaDao = mangaDao,
       _logBox = logBox,
       _webview = webview;

  Future<Pagination<Chapter>> _mangadex({
    required SourceSearchChapterParameter parameter,
  }) async {
    final result = await _chapterRepository.feed(
      mangaId: parameter.mangaId,
      parameter: parameter.parameter.copyWith(
        includes: [Include.scanlationGroup, ...?parameter.parameter.includes],
      ),
    );

    final data = result.data ?? [];
    final offset = result.offset?.toInt() ?? 0;
    final limit = result.limit?.toInt() ?? 0;
    final total = result.total?.toInt() ?? 0;

    return Pagination(
      data: [
        for (final value in data)
          Chapter.from(data: value).copyWith(
            mangaId: parameter.mangaId,
            readableAt: await value.attributes?.readableAt?.asDateTime(
              manager: _converterCacheManager,
            ),
            publishAt: await value.attributes?.publishAt?.asDateTime(
              manager: _converterCacheManager,
            ),
          ),
      ],
      offset: offset,
      limit: limit,
      total: total,
      hasNextPage: offset + data.length < total,
    );
  }

  Future<Pagination<Chapter>> _scrapping({
    required SourceSearchChapterParameter parameter,
    bool useCache = true,
  }) async {
    final raw = await _mangaDao.search(ids: [parameter.mangaId]);
    final result = Manga.fromDatabase(raw.firstOrNull);

    final url = result?.webUrl;

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

    final parser = ChapterListHtmlParser.forSource(
      root: HtmlDocument()..nodes.addAll(document.nodes),
      source: parameter.source,
    );

    final chapters = await parser.chapters.then((e) {
      return Future.wait(
        e.map(
          (e) => e
              .convert(manager: _converterCacheManager)
              .then((e) => e.copyWith(mangaId: parameter.mangaId)),
        ),
      );
    });

    final data = filterChapters(
      chapters: sortChapters(
        chapters: chapters,
        parameter: parameter.parameter,
      ),
      parameter: parameter.parameter,
    );

    return Pagination(
      data: data,
      page: parameter.parameter.page,
      limit: parameter.parameter.limit,
      total: chapters.length,
      hasNextPage:
          chapters.length >
          parameter.parameter.page * parameter.parameter.limit,
      sourceUrl: url,
    );
  }

  Future<void> clear({required SourceSearchChapterParameter parameter}) async {
    final raw = await _mangaDao.search(ids: [parameter.mangaId]);
    final result = Manga.fromDatabase(raw.firstOrNull);
    final url = result?.webUrl;
    final data = await _searchChapterCacheManager.keys;
    final List<Future<void>> promises = [];
    for (final value in data) {
      final key = SourceSearchChapterParameter.fromJsonString(value);
      if (key == null) continue;
      if (key.source != parameter.source) continue;
      final paramIgnorePagination = parameter.parameter.copyWith(
        limit: key.parameter.limit,
        offset: key.parameter.offset,
        page: key.parameter.page,
      );
      if (paramIgnorePagination != key.parameter) continue;
      promises.add(_searchChapterCacheManager.removeFile(value));
    }
    if (url != null) promises.add(_htmlCacheManager.removeFile(url));
    await Future.wait(promises);
  }

  Future<Result<Pagination<Chapter>>> execute({
    required SourceSearchChapterParameter parameter,
    bool useCache = true,
  }) async {
    final key = parameter.toJsonString();
    final cache = await _searchChapterCacheManager.getFileFromCache(key);
    final file = await cache?.file.readAsString(encoding: utf8);
    final data = file.let((e) {
      return Pagination.fromJsonString(
        e,
        (e) => Chapter.fromJson(e.castOrNull()),
      );
    });

    if (data != null && useCache) return Success(data);

    try {
      final Pagination<Chapter> data;
      if (parameter.source == SourceEnum.mangadex) {
        data = await _mangadex(parameter: parameter);
      } else {
        data = await _scrapping(parameter: parameter, useCache: useCache);
      }

      final result = data.copyWith(
        data: await sync(
          dao: _chapterDao,
          values: [...?data.data],
          logBox: _logBox,
        ),
      );

      await _searchChapterCacheManager.putFile(
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
