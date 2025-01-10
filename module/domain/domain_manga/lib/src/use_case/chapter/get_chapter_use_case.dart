import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'get_chapter_on_manga_clash_use_case.dart';
import 'get_chapter_on_manga_dex_use_case.dart';

class GetChapterUseCase {
  final GetChapterOnMangaDexUseCase _getChapterOnMangaDexUseCase;
  final GetChapterOnMangaClashUseCase _getChapterOnMangaClashUseCase;

  GetChapterUseCase({
    required GetChapterOnMangaDexUseCase getChapterOnMangaDexUseCase,
    required GetChapterOnMangaClashUseCase getChapterOnMangaClashUseCase,
  })  : _getChapterOnMangaDexUseCase = getChapterOnMangaDexUseCase,
        _getChapterOnMangaClashUseCase = getChapterOnMangaClashUseCase;

  Future<Result<MangaChapter>> execute({
    required MangaSourceEnum? source,
    required String? mangaId,
    required String? chapterId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));
    if (mangaId == null) return Error(Exception('Empty Manga Id'));
    if (chapterId == null) return Error(Exception('Empty Chapter Id'));

    return switch (source) {
      MangaSourceEnum.mangadex => _getChapterOnMangaDexUseCase.execute(
          chapterId: chapterId,
          mangaId: mangaId,
        ),
      // TODO: implement this
      MangaSourceEnum.asurascan => Future.value(
          Error(Exception('Unimplemented for ${source.name}')),
        ),
      MangaSourceEnum.mangaclash => _getChapterOnMangaClashUseCase.execute(
          chapterId: chapterId,
          mangaId: mangaId,
        ),
    };
  }
}
