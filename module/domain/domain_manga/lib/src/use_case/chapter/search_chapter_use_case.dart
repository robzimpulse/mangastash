import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'search_chapter_on_manga_dex_use_case.dart';

class SearchChapterUseCase {
  final SearchChapterOnMangaDexUseCase _searchChapterOnMangaDexUseCase;
  final ListenLocaleUseCase _listenLocaleUseCase;

  const SearchChapterUseCase({
    required SearchChapterOnMangaDexUseCase searchChapterOnMangaDexUseCase,
    required ListenLocaleUseCase listenLocaleUseCase,
  })  : _searchChapterOnMangaDexUseCase = searchChapterOnMangaDexUseCase,
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
      // TODO: Handle this case.
      MangaSourceEnum.asurascan => Future.value(
          Error(
            Exception('Unimplemented for ${source.name}'),
          ),
        ),
      // TODO: Handle this case.
      MangaSourceEnum.mangaclash => Future.value(
          Error(
            Exception('Unimplemented for ${source.name}'),
          ),
        ),
    };
  }
}
