// GetChapterUseCase: a chapter with its image URLs, served from ChapterDao
// when images are stored, else fetched — MangaDex via the chapter/at-home
// repositories, scripted sources via `SourceExternal.images(url: webUrl)`
// (issue #115) validated by requireChapterImages (a failure evicts the
// runner's cached result).
//
// Usage: `await useCase.execute(source: s, mangaId: m, chapterId: c)`.
//
// `source` only carries the name: `execute` re-resolves it through the
// SourceRegistry, so a screen that captured the adapter before the user saved
// an edited script (Fix source) still runs the saved code.
import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../extension/map_network_error.dart';
import '../../extension/scrapped_validation_extension.dart';
import '../../manager/source_registry.dart';
import '../../mixin/sync_chapters_mixin.dart';

class GetChapterUseCase with SyncChaptersMixin {
  final ChapterRepository _chapterRepository;
  final AtHomeRepository _atHomeRepository;
  final RunSourceScriptUseCase _runner;
  final ChapterDao _chapterDao;
  final LogBox _logBox;
  final SourceRegistry _registry;

  GetChapterUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
    required RunSourceScriptUseCase runner,
    required ChapterDao chapterDao,
    required LogBox logBox,
    required SourceRegistry registry,
  }) : _chapterRepository = chapterRepository,
       _atHomeRepository = atHomeRepository,
       _chapterDao = chapterDao,
       _logBox = logBox,
       _registry = registry,
       _runner = runner;

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

    final images = await source.images(url: url, useCache: useCache);

    // Zero images is selector drift, not an empty reader — fail here with
    // context instead of syncing an image-less chapter that explodes as a
    // DataNotFoundException on the next open (issue #114).
    return validateOrEvict(
      _runner,
      url: url,
      validate: () {
        return requireChapterImages(images, source: source.name, url: url);
      },
    );
  }

  Future<Result<Chapter>> execute({
    required SourceExternal source,
    required String mangaId,
    required String chapterId,
    bool useCache = true,
  }) async {
    try {
      final resolved = _registry.fromName(source.name) ?? source;
      final raw = await _chapterDao.search(ids: [chapterId]);
      final chapter = raw.firstOrNull.let(
        (e) => e.chapter?.let((d) => Chapter.fromDrift(d, images: e.images)),
      );

      if (chapter != null && chapter.images.or([]).isNotEmpty && useCache) {
        return Success(chapter);
      }

      final data =
          resolved.builtIn
              ? _mangadex(mangaId: mangaId, chapterId: chapterId)
              : _scrapping(
                url: chapter?.webUrl,
                source: resolved,
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
      return Error(mapNetworkError(e));
    }
  }
}
