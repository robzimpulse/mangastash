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
  final BaseCacheManager _cacheManager;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  GetChapterUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
    required HeadlessWebviewManager webview,
    required BaseCacheManager cacheManager,
    required ChapterDao chapterDao,
    required LogBox logBox,
  })  : _chapterRepository = chapterRepository,
        _atHomeRepository = atHomeRepository,
        _cacheManager = cacheManager,
        _chapterDao = chapterDao,
        _logBox = logBox,
        _webview = webview;

  Future<Chapter> _mangadex({
    required String source,
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

  Future<Chapter> _scrapping({
    required Chapter? chapter,
    required String source,
  }) async {
    final url = chapter?.webUrl;

    if (chapter == null || url == null) {
      throw Exception('Data not found');
    }

    if (chapter.images?.isNotEmpty == true) {
      return chapter;
    }

    final document = await _webview.open(url);

    if (document == null) {
      throw Exception('Error parsing html');
    }

    final parser = ChapterImageHtmlParser.forSource(
      root: document,
      source: source,
    );

    return chapter.copyWith(images: parser.images);
  }

  Future<Result<Chapter>> execute({
    required String source,
    required String mangaId,
    required String chapterId,
  }) async {
    final key = '$source-$mangaId-$chapterId';
    final cache = await _cacheManager.getFileFromCache(key);
    final file = await cache?.file.readAsString();
    final data = file.let((e) => Chapter.fromJsonString(e));

    if (data != null) {
      return Success(data);
    }

    final raw = await _chapterDao.search(ids: [chapterId]);
    final chapter = raw.firstOrNull.let(
      (e) => e.chapter?.let((d) => Chapter.fromDrift(d, images: e.images)),
    );

    if (chapter != null && chapter.images?.isNotEmpty == true) {
      return Success(chapter);
    }

    try {
      final promise = source == Source.mangadex().name
          ? _mangadex(source: source, mangaId: mangaId, chapterId: chapterId)
          : _scrapping(chapter: chapter, source: source);

      final results = await sync(
        dao: _chapterDao,
        values: [await promise],
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
