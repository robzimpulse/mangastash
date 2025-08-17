import 'dart:convert';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_chapters_mixin.dart';
import '../../parser/base/chapter_image_html_parser.dart';

class GetChapterUseCase with SyncChaptersMixin {
  final ChapterRepository _chapterRepository;
  final AtHomeRepository _atHomeRepository;
  final HeadlessWebviewManager _webview;
  final StorageManager _storageManager;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  GetChapterUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
    required HeadlessWebviewManager webview,
    required StorageManager storageManager,
    required ChapterDao chapterDao,
    required LogBox logBox,
  }) : _chapterRepository = chapterRepository,
       _atHomeRepository = atHomeRepository,
       _storageManager = storageManager,
       _chapterDao = chapterDao,
       _logBox = logBox,
       _webview = webview;

  Future<Chapter> _mangadex({
    required String mangaId,
    required String chapterId,
  }) async {
    final response = await Future.wait([
      _chapterRepository.detail(chapterId, includes: [Include.manga]),
      _atHomeRepository.url(chapterId),
    ]);

    final chapter = response[0] as ChapterResponse;
    final atHome = response[1] as AtHomeResponse;

    return Chapter(
      id: chapter.data?.id,
      title: chapter.data?.attributes?.title,
      chapter: chapter.data?.attributes?.chapter,
      volume: chapter.data?.attributes?.volume,
      images: atHome.images,
      translatedLanguage: chapter.data?.attributes?.translatedLanguage,
      mangaId: mangaId,
    );
  }

  Future<List<String>> _scrapping({
    required String? url,
    required SourceEnum source,
    bool useCache = true,
  }) async {
    if (url == null) {
      throw DataNotFoundException();
    }

    final document = await _webview.open(url, useCache: useCache);

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = ChapterImageHtmlParser.forSource(
      root: document,
      source: source,
      storageManager: _storageManager,
    );

    return parser.images;
  }

  Future<void> clearCache({
    required SourceEnum source,
    required String mangaId,
    required String chapterId,
  }) async {
    final key = '${source.name} - $mangaId - $chapterId';
    await _storageManager.chapter.removeFile(key);
  }

  Future<Result<Chapter>> execute({
    required SourceEnum source,
    required String mangaId,
    required String chapterId,
    bool useCache = true,
  }) async {
    final key = '${source.name} - $mangaId - $chapterId';
    final file = await _storageManager.chapter.getFileFromCache(key);
    final data = await file?.file.readAsString(encoding: utf8);
    final cache = Chapter.fromJsonString(data ?? '');
    if (cache != null && useCache) return Success(cache);

    final raw = await _chapterDao.search(ids: [chapterId]);
    final chapter = raw.firstOrNull.let(
      (e) => e.chapter?.let((d) => Chapter.fromDrift(d, images: e.images)),
    );

    try {
      final Chapter? data;
      if (source == SourceEnum.mangadex) {
        data = await _mangadex(mangaId: mangaId, chapterId: chapterId);
      } else {
        data = chapter?.copyWith(
          images: await _scrapping(
            url: chapter.webUrl,
            source: source,
            useCache: useCache,
          ),
        );
      }

      final results = await sync(
        dao: _chapterDao,
        values: [
          ...[data].nonNulls,
        ],
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
