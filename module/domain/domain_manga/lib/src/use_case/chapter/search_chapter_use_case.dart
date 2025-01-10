import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/src/use_case/chapter/search_chapter_on_manga_clash_use_case.dart';
import 'package:entity_manga/entity_manga.dart';

import 'search_chapter_on_manga_dex_use_case.dart';

class SearchChapterUseCase {
  final SearchChapterOnMangaDexUseCase _searchChapterOnMangaDexUseCase;
  final SearchChapterOnMangaClashUseCase _searchChapterOnMangaClashUseCase;
  final ListenLocaleUseCase _listenLocaleUseCase;

  const SearchChapterUseCase({
    required SearchChapterOnMangaDexUseCase searchChapterOnMangaDexUseCase,
    required SearchChapterOnMangaClashUseCase searchChapterOnMangaClashUseCase,
    required ListenLocaleUseCase listenLocaleUseCase,
  })  : _searchChapterOnMangaDexUseCase = searchChapterOnMangaDexUseCase,
        _searchChapterOnMangaClashUseCase = searchChapterOnMangaClashUseCase,
        _listenLocaleUseCase = listenLocaleUseCase;

  Future<Result<List<MangaChapter>>> execute({
    required MangaSourceEnum? source,
    required String? mangaId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));
    final language = Language.fromCode(
      _listenLocaleUseCase.localeDataStream.valueOrNull?.languageCode,
    );

    return switch (source) {
      MangaSourceEnum.mangadex => _searchChapterOnMangaDexUseCase.execute(
          mangaId: mangaId,
          language: language,
        ),
      // TODO: implement this
      MangaSourceEnum.asurascan => Future.value(
          Error(Exception('Unimplemented for ${source.name}')),
        ),
      // TODO: implement this
      MangaSourceEnum.mangaclash => _searchChapterOnMangaClashUseCase.execute(
          mangaId: mangaId,
          language: language,
        ),
    };
  }
}
