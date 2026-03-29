import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_chapters_mixin.dart';

class GetChapterUseCase with SyncChaptersMixin {
  final ChapterRepository _chapterRepository;
  final AtHomeRepository _atHomeRepository;
  final HeadlessWebviewUseCase _webview;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  GetChapterUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
    required HeadlessWebviewUseCase webview,
    required ChapterDao chapterDao,
    required LogBox logBox,
  }) : _chapterRepository = chapterRepository,
       _atHomeRepository = atHomeRepository,
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
    required SourceExternal source,
    bool useCache = true,
  }) async {
    if (url == null) {
      throw DataNotFoundException();
    }

    final document = await _webview.open(
      url,
      scripts: source.getChapterImageUseCase.scripts,
      useCache: useCache,
    );

    return source.getChapterImageUseCase.parse(root: document);
  }

  Future<Result<Chapter>> execute({
    required SourceExternal source,
    required String mangaId,
    required String chapterId,
    bool useCache = true,
  }) async {
    try {
      final raw = await _chapterDao.search(ids: [chapterId]);
      final chapter = raw.firstOrNull.let(
        (e) => e.chapter?.let((d) => Chapter.fromDrift(d, images: e.images)),
      );

      if (chapter != null && chapter.images.or([]).isNotEmpty && useCache) {
        return Success(chapter);
      }

      final data =
          source.builtIn
              ? _mangadex(mangaId: mangaId, chapterId: chapterId)
              : _scrapping(
                url: chapter?.webUrl,
                source: source,
                useCache: useCache,
              ).then((e) => chapter?.copyWith(images: e));

      final results = await sync(
        dao: _chapterDao,
        values: [
          ...[await data].nonNulls,
        ],
        logBox: _logBox,
      );

      final result = results.firstOrNull;

      if (result == null) {
        throw DataNotFoundException();
      }

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
