import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'get_chapter_on_asura_scan_use_case.dart';
import 'get_chapter_on_manga_clash_use_case.dart';
import 'get_chapter_on_manga_dex_use_case.dart';

class GetChapterUseCase {
  final GetChapterOnMangaDexUseCase _getChapterOnMangaDexUseCase;
  final GetChapterOnMangaClashUseCase _getChapterOnMangaClashUseCase;
  final GetChapterOnAsuraScanUseCase _getChapterOnAsuraScanUseCase;

  GetChapterUseCase({
    required GetChapterOnMangaDexUseCase getChapterOnMangaDexUseCase,
    required GetChapterOnMangaClashUseCase getChapterOnMangaClashUseCase,
    required GetChapterOnAsuraScanUseCase getChapterOnAsuraScanUseCase,
  })  : _getChapterOnMangaDexUseCase = getChapterOnMangaDexUseCase,
        _getChapterOnMangaClashUseCase = getChapterOnMangaClashUseCase,
        _getChapterOnAsuraScanUseCase = getChapterOnAsuraScanUseCase;

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
      MangaSourceEnum.asurascan => _getChapterOnAsuraScanUseCase.execute(
          chapterId: chapterId,
          mangaId: mangaId,
        ),
      MangaSourceEnum.mangaclash => _getChapterOnMangaClashUseCase.execute(
          chapterId: chapterId,
          mangaId: mangaId,
        ),
    };
  }
}
