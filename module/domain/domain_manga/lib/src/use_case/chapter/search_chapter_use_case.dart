import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../../domain_manga.dart';
import '../../helper/language_code_converter.dart';
import 'search_chapter_on_asura_scan_use_case.dart';
import 'search_chapter_on_manga_clash_use_case.dart';
import 'search_chapter_on_manga_dex_use_case.dart';

class SearchChapterUseCase {
  final SearchChapterOnMangaDexUseCase _searchChapterOnMangaDexUseCase;
  final SearchChapterOnMangaClashUseCase _searchChapterOnMangaClashUseCase;
  final SearchChapterOnAsuraScanUseCase _searchChapterOnAsuraScanUseCase;
  final ListenLocaleUseCase _listenLocaleUseCase;

  const SearchChapterUseCase({
    required SearchChapterOnMangaDexUseCase searchChapterOnMangaDexUseCase,
    required SearchChapterOnMangaClashUseCase searchChapterOnMangaClashUseCase,
    required SearchChapterOnAsuraScanUseCase searchChapterOnAsuraScanUseCase,
    required ListenLocaleUseCase listenLocaleUseCase,
  })  : _searchChapterOnMangaDexUseCase = searchChapterOnMangaDexUseCase,
        _searchChapterOnMangaClashUseCase = searchChapterOnMangaClashUseCase,
        _searchChapterOnAsuraScanUseCase = searchChapterOnAsuraScanUseCase,
        _listenLocaleUseCase = listenLocaleUseCase;

  Future<Result<Pagination<MangaChapter>>> execute({
    required MangaSourceEnum? source,
    required String? mangaId,
    required SearchChapterParameter parameter,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));
    final language = Language.fromCode(
      _listenLocaleUseCase.localeDataStream.valueOrNull?.languageCode,
    );

    return switch (source) {
      MangaSourceEnum.mangadex => _searchChapterOnMangaDexUseCase.execute(
          mangaId: mangaId,
          parameter: parameter.copyWith(
            translatedLanguage: language.languageCodes,
          ),
        ),
      MangaSourceEnum.asurascan => _searchChapterOnAsuraScanUseCase.execute(
          mangaId: mangaId,
          parameter: parameter.copyWith(
            translatedLanguage: language.languageCodes,
          ),
        ),
      MangaSourceEnum.mangaclash => _searchChapterOnMangaClashUseCase.execute(
          mangaId: mangaId,
          parameter: parameter.copyWith(
            translatedLanguage: language.languageCodes,
          ),
        ),
    };
  }
}
