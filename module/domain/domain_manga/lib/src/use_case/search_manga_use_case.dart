import 'package:data_manga/manga.dart';
import 'package:core_network/core_network.dart' as network;

import '../../domain_manga.dart';

class SearchMangaUseCase {
  final SearchRepository _searchRepository;

  const SearchMangaUseCase({
    required SearchRepository searchRepository,
  }) : _searchRepository = searchRepository;

  Future<network.Result<List<Manga>>> execute({
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
      final searchResult = await _searchRepository.search(
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
        includes: includes,
        group: group,
        orders: orders,
      );

      return network.Success(
        searchResult.data
                ?.map((e) => Manga(id: e.id, title: e.attributes?.title?.en))
                .toList() ??
            [],
      );
    } on Exception catch (e) {
      return network.Error(e);
    }
  }
}
