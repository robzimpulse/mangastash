import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
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

    // readableAt: data.attributes?.readableAt?.asDateTime,
    // publishAt: data.attributes?.publishAt?.asDateTime,

    return Pagination(
      data: [
        for (final value in data)
          Chapter.from(data: value).copyWith(
            mangaId: mangaId,
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
    required SourceEnum source,
    required String mangaId,
    required SearchChapterParameter parameter,
  }) async {
    final raw = await _mangaDao.search(ids: [mangaId]);
    final result = Manga.fromDatabase(raw.firstOrNull);

    final url = result?.webUrl;

    if (url == null) {
      throw DataNotFoundException();
    }

    final document = await _webview.open(url);

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = ChapterListHtmlParser.forSource(
      root: document,
      source: source,
      storageManager: _storageManager,
    );

    final chapters = await parser.chapters;

    final data = filterChapters(
      chapters: sortChapters(
        chapters: [...chapters.map((e) => e.copyWith(mangaId: mangaId))],
        parameter: parameter,
      ),
      parameter: parameter,
    );

    return Pagination(
      data: data,
      page: parameter.page,
      limit: parameter.limit,
      total: chapters.length,
      hasNextPage: chapters.length > parameter.page * parameter.limit,
      sourceUrl: url,
    );
  }

  Future<Result<Pagination<Chapter>>> execute({
    required SourceEnum source,
    required String mangaId,
    required SearchChapterParameter parameter,
  }) async {
    try {
      final Pagination<Chapter> data;
      if (source == SourceEnum.mangadex) {
        data = await _mangadex(mangaId: mangaId, parameter: parameter);
      } else {
        data = await _scrapping(
          source: source,
          mangaId: mangaId,
          parameter: parameter,
        );
      }

      final result = data.copyWith(
        data: await sync(
          dao: _chapterDao,
          values: [...?data.data],
          logBox: _logBox,
        ),
      );

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
