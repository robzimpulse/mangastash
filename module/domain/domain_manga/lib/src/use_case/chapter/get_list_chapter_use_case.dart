import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'get_list_chapter_on_manga_dex_use_case.dart';

class GetListChapterUseCase {
  final GetListChapterOnMangaDexUseCase _getListChapterOnMangaDexUseCase;

  const GetListChapterUseCase({
    required GetListChapterOnMangaDexUseCase getListChapterOnMangaDexUseCase,
  }) : _getListChapterOnMangaDexUseCase = getListChapterOnMangaDexUseCase;

  Future<Result<List<MangaChapter>>> execute({
    required MangaSourceEnum? source,
    required String? mangaId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    final Result<List<MangaChapter>> result;

    switch (source) {
      case MangaSourceEnum.mangadex:
        result = await _getListChapterOnMangaDexUseCase.execute(
          mangaId: mangaId,
        );
        break;
      case MangaSourceEnum.asurascan:
        result = Error(Exception('Unimplemented for ${source.name}'));
        break;
    }

    if (result is Success<List<MangaChapter>>) {
      // TODO: sync to firebase
    }

    return result;
  }
}
