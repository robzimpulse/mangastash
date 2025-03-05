import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../../domain_manga.dart';
import 'search_chapter_on_asura_scan_use_case.dart';
import 'search_chapter_on_manga_clash_use_case.dart';
import 'search_chapter_on_manga_dex_use_case.dart';

class SearchChapterUseCase {
  final SearchChapterOnMangaDexUseCase _searchChapterOnMangaDexUseCase;
  final SearchChapterOnMangaClashUseCase _searchChapterOnMangaClashUseCase;
  final SearchChapterOnAsuraScanUseCase _searchChapterOnAsuraScanUseCase;

  const SearchChapterUseCase({
    required SearchChapterOnMangaDexUseCase searchChapterOnMangaDexUseCase,
    required SearchChapterOnMangaClashUseCase searchChapterOnMangaClashUseCase,
    required SearchChapterOnAsuraScanUseCase searchChapterOnAsuraScanUseCase,
  })  : _searchChapterOnMangaDexUseCase = searchChapterOnMangaDexUseCase,
        _searchChapterOnMangaClashUseCase = searchChapterOnMangaClashUseCase,
        _searchChapterOnAsuraScanUseCase = searchChapterOnAsuraScanUseCase;

  Future<Result<Pagination<MangaChapter>>> execute({
    required MangaSourceEnum? source,
    required String? mangaId,
    required SearchChapterParameter parameter,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    return switch (source) {
      MangaSourceEnum.mangadex => _searchChapterOnMangaDexUseCase.execute(
          mangaId: mangaId,
          parameter: parameter,
        ),
      MangaSourceEnum.asurascan => _searchChapterOnAsuraScanUseCase.execute(
          mangaId: mangaId,
          parameter: parameter,
        ),
      MangaSourceEnum.mangaclash => _searchChapterOnMangaClashUseCase.execute(
          mangaId: mangaId,
          parameter: parameter,
        ),
    };
  }
}
