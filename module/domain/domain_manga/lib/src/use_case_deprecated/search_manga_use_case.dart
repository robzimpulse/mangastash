import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../domain_manga.dart';

class SearchMangaUseCaseDeprecated {
  final MangaRepository _mangaRepository;
  final AuthorRepository _authorRepository;
  final CoverRepository _coverRepository;

  const SearchMangaUseCaseDeprecated({
    required MangaRepository mangaRepository,
    required AuthorRepository authorRepository,
    required CoverRepository coverRepository,
  })  : _mangaRepository = mangaRepository,
        _authorRepository = authorRepository,
        _coverRepository = coverRepository;

  Future<Result<PaginationMangaDeprecated>> execute({
    required SearchMangaParameterDeprecated parameter,
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

      final promises = result.data?.map(_mapManga).toList() ?? [];
      final mangas = await Future.wait(promises);

      return Success(
        PaginationMangaDeprecated(
          offset: result.offset ?? 0,
          limit: result.limit ?? 0,
          total: result.total ?? 0,
          mangas: mangas,
        ),
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }

  Future<MangaDeprecated> _mapManga(MangaData data) async {
    final cover = await _coverArtUrl(data);
    final authors = await _authors(data);
    return MangaDeprecated.from(data, coverUrl: cover, author: authors);
  }

  Future<String> _coverArtUrl(MangaData data) async {
    final cover = data.relationships?.firstWhereOrNull(
      (e) => e.type == Include.coverArt.rawValue,
    );
    final mangaId = data.id;
    final coverId = cover?.id;
    if (coverId == null || mangaId == null) return '';
    final response = await _coverRepository.detail(coverId);
    final filename = response.data?.attributes?.fileName;
    if (filename == null) return '';
    return _coverRepository.coverUrl(mangaId, filename);
  }

  Future<List<String>> _authors(MangaData data) async {
    final authors = data.relationships?.where(
      (e) => e.type == Include.author.rawValue,
    );
    if (authors == null) return [];
    final promises = authors.map((e) => _authorRepository.detail(e.id ?? ''));
    final results = await Future.wait(promises);
    return results.map((e) => e.data?.attributes?.name).whereNotNull().toList();
  }
}
