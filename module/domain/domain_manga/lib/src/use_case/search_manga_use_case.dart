import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';

import '../../domain_manga.dart';

class SearchMangaUseCase {
  final MangaRepository _repository;

  const SearchMangaUseCase({
    required MangaRepository repository,
  }) : _repository = repository;

  Future<Response<SearchResponse>> execute({
    String? title,
    int? limit,
    int? offset,
    List<String>? authors,
    List<String>? artists,
    int? year,
    List<String>? includedTags,
    TagsMode? includedTagsMode,
    List<String>? excludedTags,
    TagsMode? excludedTagsMode,
    List<MangaStatus>? status,
    List<LanguageCodes>? originalLanguage,
    List<LanguageCodes>? excludedOriginalLanguages,
    List<LanguageCodes>? availableTranslatedLanguage,
    List<PublicDemographic>? publicationDemographic,
    List<String>? ids,
    List<ContentRating>? contentRating,
    String? createdAtSince,
    String? updatedAtSince,
    List<String>? includes,
    String? group,
    Map<SearchOrders, OrderDirections>? orders,
  }) async {
    try {
      final result = await _repository.search(
        title: title,
        limit: limit,
        offset: offset,
        authors: authors,
        artists: artists,
        year: year,
        includedTags: includedTags,
        includedTagsMode: includedTagsMode,
        excludedTags: excludedTags,
        excludedTagsMode: excludedTagsMode,
        status: status,
        originalLanguage: originalLanguage,
        excludedOriginalLanguages: excludedOriginalLanguages,
        availableTranslatedLanguage: availableTranslatedLanguage,
        publicationDemographic: publicationDemographic,
        ids: ids,
        contentRating: contentRating,
        createdAtSince: createdAtSince,
        updatedAtSince: updatedAtSince,
        includes: ['cover_art', ...includes ?? []],
        group: group,
        orders: orders,
      );

      return Success(result);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
