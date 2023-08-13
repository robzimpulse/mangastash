import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../domain_manga.dart';

class SearchMangaUseCase {
  final MangaRepository _mangaRepository;
  // TODO: use this repository
  final AuthorRepository _authorRepository;
  // TODO: use this repository
  final CoverRepository _coverRepository;

  const SearchMangaUseCase({
    required MangaRepository mangaRepository,
    required AuthorRepository authorRepository,
    required CoverRepository coverRepository,
  })  : _mangaRepository = mangaRepository,
        _authorRepository = authorRepository,
        _coverRepository = coverRepository;

  Future<Response<SearchMangaResponse>> execute({
    required SearchMangaParameter parameter,
  }) async {
    try {
      final result = await _mangaRepository.search(
        title: parameter.title,
        limit: parameter.limit,
        offset: parameter.offset,
        authors: parameter.authors,
        artists: parameter.artists,
        year: parameter.year,
        includedTags: parameter.includedTags,
        includedTagsMode: parameter.includedTagsMode,
        excludedTags: parameter.excludedTags,
        excludedTagsMode: parameter.excludedTagsMode,
        status: parameter.status,
        originalLanguage: parameter.originalLanguage,
        excludedOriginalLanguages: parameter.excludedOriginalLanguages,
        availableTranslatedLanguage: parameter.availableTranslatedLanguage,
        publicationDemographic: parameter.publicationDemographic,
        ids: parameter.ids,
        contentRating: parameter.contentRating,
        createdAtSince: parameter.createdAtSince,
        updatedAtSince: parameter.updatedAtSince,
        includes: parameter.includes,
        group: parameter.group,
        orders: parameter.orders,
      );

      return Success(result);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
