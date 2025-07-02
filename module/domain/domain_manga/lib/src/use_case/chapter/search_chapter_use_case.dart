import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/filter_chapters_mixin.dart';
import '../../mixin/sort_chapters_mixin.dart';
import '../../mixin/sync_chapters_mixin.dart';
import '../../parser/base/chapter_list_html_parser.dart';

class SearchChapterUseCase
    with SyncChaptersMixin, SortChaptersMixin, FilterChaptersMixin {
  final ChapterRepository _chapterRepository;
  final HeadlessWebviewManager _webview;
  final BaseCacheManager _cacheManager;
  final ChapterDao _chapterDao;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchChapterUseCase({
    required ChapterRepository chapterRepository,
    required HeadlessWebviewManager webview,
    required BaseCacheManager cacheManager,
    required ChapterDao chapterDao,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _chapterRepository = chapterRepository,
        _cacheManager = cacheManager,
        _chapterDao = chapterDao,
        _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Pagination<Chapter>> _mangadex({
    required String source,
    required String mangaId,
    required SearchChapterParameter parameter,
  }) async {
    final result = await _chapterRepository.feed(
      mangaId: mangaId,
      parameter: parameter.copyWith(
        includes: [Include.scanlationGroup, ...?parameter.includes],
      ),
    );

    final data = result.data ?? [];
    final offset = result.offset?.toInt() ?? 0;
    final limit = result.limit?.toInt() ?? 0;
    final total = result.total?.toInt() ?? 0;

    return Pagination(
      data: [
        ...data.map((e) => Chapter.from(data: e).copyWith(mangaId: mangaId)),
      ],
      offset: offset,
      limit: limit,
      total: total,
      hasNextPage: offset + data.length < total,
    );
  }

  Future<Pagination<Chapter>> _scrapping({
    required String source,
    required String mangaId,
    required SearchChapterParameter parameter,
  }) async {
    final raw = await _mangaDao.search(ids: [mangaId]);
    final result = Manga.fromDatabase(raw.firstOrNull);

    final url = result?.webUrl;

    if (result == null || url == null) {
      throw Exception('Data not found');
    }

    final document = await _webview.open(url);

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = ChapterListHtmlParser.forSource(
      root: document,
      source: source,
    );

    final data = filterChapters(
      chapters: sortChapters(
        chapters: [
          ...parser.chapters.map((e) => e.copyWith(mangaId: mangaId)),
        ],
        parameter: parameter,
      ),
      parameter: parameter,
    );

    return Pagination(
      data: data,
      page: parameter.page,
      limit: parameter.limit,
      total: parser.chapters.length,
      hasNextPage: parser.chapters.length > parameter.page * parameter.limit,
      sourceUrl: url,
    );
  }

  Future<Result<Pagination<Chapter>>> execute({
    required String source,
    required String mangaId,
    required SearchChapterParameter parameter,
    bool useCache = true,
  }) async {
    final key = '$source-$mangaId-${parameter.toJsonString()}';
    final cache = await _cacheManager.getFileFromCache(key);
    final file = await cache?.file.readAsString();
    final data = file.let(
      (e) => Pagination.fromJsonString(
        e,
        (e) => Chapter.fromJson(e.castOrNull()),
      ),
    );

    if (data != null && useCache) {
      return Success(data);
    }

    try {
      final promise = source == Source.mangadex().name
          ? _mangadex(source: source, mangaId: mangaId, parameter: parameter)
          : _scrapping(source: source, mangaId: mangaId, parameter: parameter);

      final data = await promise;

      final result = data.copyWith(
        data: await sync(
          dao: _chapterDao,
          values: [...?data.data],
          logBox: _logBox,
        ),
      );

      await _cacheManager.putFile(
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
