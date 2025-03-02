import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../helper/language_code_converter.dart';
import '../../mixin/sync_chapters_mixin.dart';

class SearchChapterOnMangaDexUseCase with SyncChaptersMixin {
  final ChapterRepository _chapterRepository;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;

  const SearchChapterOnMangaDexUseCase({
    required ChapterRepository chapterRepository,
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
  })  : _chapterRepository = chapterRepository,
        _mangaChapterServiceFirebase = mangaChapterServiceFirebase;

  Future<Result<List<MangaChapter>>> execute({
    required String? mangaId,
    Language? language,
  }) async {
    if (mangaId == null) return Error(Exception('Manga ID Empty'));

    try {
      var total = 0;
      List<MangaChapter> chapters = [];

      do {
        final result = await _chapterRepository.feed(
          mangaId: mangaId,
          limit: 50,
          translatedLanguage: language?.languageCodes,
          offset: chapters.length,
          includes: [Include.scanlationGroup],
        );

        final data = result.data ?? [];

        chapters.addAll(
          data.map(
            (e) {
              final scanlation = e.relationships?.firstWhereOrNull(
                (e) => e.type == Include.scanlationGroup.rawValue,
              );

              return MangaChapter(
                id: e.id,
                mangaId: mangaId,
                title: e.attributes?.title,
                chapter: e.attributes?.chapter,
                volume: e.attributes?.volume,
                readableAt: e.attributes?.readableAt,
                publishAt: e.attributes?.publishAt,
                scanlationGroup:
                    scanlation is Relationship<ScanlationGroupDataAttributes>
                        ? scanlation.attributes?.name
                        : null,
              );
            },
          ),
        );

        total = (result.total ?? 0).toInt();
      } while (chapters.length < total);

      return Success(
        await sync(
          mangaChapterServiceFirebase: _mangaChapterServiceFirebase,
          values: chapters,
        ),
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
