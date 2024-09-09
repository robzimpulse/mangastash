import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetListChapterOnMangaDexUseCase {
  final ChapterRepository _chapterRepository;

  const GetListChapterOnMangaDexUseCase({
    required ChapterRepository chapterRepository,
  }) : _chapterRepository = chapterRepository;

  Future<Result<List<MangaChapter>>> execute({
    required String? mangaId,
  }) async {
    try {
      var total = 0;
      List<MangaChapter> chapters = [];

      do {
        final result = await _chapterRepository.search(
          mangaId: mangaId ?? '',
          limit: 20,
        );

        final data = result.data ?? [];

        chapters.addAll(
          data.map(
            (e) => MangaChapter(
              id: e.id,
              title: e.attributes?.title,
              chapter: e.attributes?.chapter,
              volume: e.attributes?.volume,
            ),
          ),
        );

        total = (result.total ?? 0).toInt();

      } while (chapters.length < total);

      return Success(chapters);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
