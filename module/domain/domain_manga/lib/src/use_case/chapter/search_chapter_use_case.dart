import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'search_chapter_on_manga_dex_use_case.dart';

class SearchChapterUseCase {
  final SearchChapterOnMangaDexUseCase _searchChapterOnMangaDexUseCase;

  const SearchChapterUseCase({
    required SearchChapterOnMangaDexUseCase searchChapterOnMangaDexUseCase,
  })  : _searchChapterOnMangaDexUseCase = searchChapterOnMangaDexUseCase;

  Future<Result<List<MangaChapter>>> execute({
    required MangaSourceEnum? source,
    required String? mangaId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    final Result<List<MangaChapter>> result;

    switch (source) {
      case MangaSourceEnum.mangadex:
        result = await _searchChapterOnMangaDexUseCase.execute(
          mangaId: mangaId,
        );
        break;
      case MangaSourceEnum.asurascan:
        result = Error(Exception('Unimplemented for ${source.name}'));
        break;
    }

    return result;
  }
}
