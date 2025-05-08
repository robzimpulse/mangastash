import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../mixin/sync_chapters_mixin.dart';

class SearchChapterOnMangaDexUseCase with SyncChaptersMixin {
  final ChapterRepository _chapterRepository;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;

  const SearchChapterOnMangaDexUseCase({
    required ChapterRepository chapterRepository,
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
  })  : _chapterRepository = chapterRepository,
        _mangaChapterServiceFirebase = mangaChapterServiceFirebase;

  Future<Result<Pagination<MangaChapter>>> execute({
    required String? mangaId,
    required SearchChapterParameter parameter,
  }) async {
    if (mangaId == null) return Error(Exception('Manga ID Empty'));

    try {
      final result = await _chapterRepository.feed(
        mangaId: mangaId,
        parameter: parameter.copyWith(
          includes: [Include.scanlationGroup, ...?parameter.includes],
        ),
      );

      final data = result.data ?? [];

      return Success(
        Pagination(
          data: await sync(
            mangaChapterServiceFirebase: _mangaChapterServiceFirebase,
            values: data
                .map(
                  (e) => MangaChapter.from(data: e).copyWith(
                    mangaId: mangaId,
                  ),
                )
                .toList(),
          ),
          offset: result.offset?.toInt(),
          limit: result.limit?.toInt() ?? 0,
          total: result.total?.toInt() ?? 0,
        ),
      );
    } catch (e) {
      return Error(e);
    }
  }
}
