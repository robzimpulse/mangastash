import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/filter_chapters_mixin.dart';
import '../../mixin/sort_chapters_mixin.dart';
import '../../mixin/sync_chapters_mixin.dart';
import '../../parser/base/chapter_list_html_parser.dart';

class SearchChapterUseCase
    with SyncChaptersMixin, SortChaptersMixin, FilterChaptersMixin {
  final ChapterRepository _chapterRepository;
  final HeadlessWebviewManager _webview;
  final StorageManager _storageManager;
  final ChapterDao _chapterDao;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchChapterUseCase({
    required ChapterRepository chapterRepository,
    required HeadlessWebviewManager webview,
    required StorageManager storageManager,
    required ChapterDao chapterDao,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _chapterRepository = chapterRepository,
       _storageManager = storageManager,
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
              storageManager: _storageManager,
            ),
            publishAt: await value.attributes?.publishAt?.asDateTime(
              storageManager: _storageManager,
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

    final document = await _webview.open(url, useCache: useCache);

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = ChapterListHtmlParser.forSource(
      root: document,
      source: parameter.source,
      storageManager: _storageManager,
    );

    final chapters = await parser.chapters;

    final data = filterChapters(
      chapters: sortChapters(
        chapters: [
          ...chapters.map((e) => e.copyWith(mangaId: parameter.mangaId)),
        ],
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
    final data = await _storageManager.searchChapter.keys;
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
      promises.add(_storageManager.searchChapter.removeFile(value));
    }
    if (url != null) promises.add(_storageManager.html.removeFile(url));
    await Future.wait(promises);
  }

  Future<Result<Pagination<Chapter>>> execute({
    required SourceSearchChapterParameter parameter,
    bool useCache = true,
  }) async {
    final key = parameter.toJsonString();
    final cache = await _storageManager.searchChapter.getFileFromCache(key);
    final file = await cache?.file.readAsString(encoding: utf8);
    final data = file.let((e) {
      return Pagination.fromJsonString(
        e,
        (e) => Chapter.fromJson(e.castOrNull()),
      );
    });

    if (data != null && useCache) {
      return Success(data);
    }

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

      await _storageManager.searchChapter.putFile(
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
