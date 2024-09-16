import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

import 'get_chapter_on_manga_dex_use_case.dart';

class GetChapterUseCase {
  final GetChapterOnMangaDexUseCase _getChapterOnMangaDexUseCase;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;

  GetChapterUseCase({
    required GetChapterOnMangaDexUseCase getChapterOnMangaDexUseCase,
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
  })  : _getChapterOnMangaDexUseCase = getChapterOnMangaDexUseCase,
        _mangaChapterServiceFirebase = mangaChapterServiceFirebase;

  Future<Result<MangaChapter>> execute({
    required MangaSourceEnum? source,
    required String? mangaId,
    required String? chapterId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));
    if (mangaId == null) return Error(Exception('Empty Manga Id'));
    if (chapterId == null) return Error(Exception('Empty Chapter Id'));

    final Result<MangaChapter> result;

    switch (source) {
      case MangaSourceEnum.mangadex:
        result = await _getChapterOnMangaDexUseCase.execute(
          chapterId: chapterId,
          mangaId: mangaId,
        );
        break;
      case MangaSourceEnum.asurascan:
        result = Error(Exception('Unimplemented for ${source.name}'));
        break;
    }

    if (result is Success<MangaChapter>) {
      _sync(data: result.data);
    }

    return result;
  }

  Future<void> _sync({required MangaChapter data}) async {
    await _mangaChapterServiceFirebase.update(data);
  }
}
