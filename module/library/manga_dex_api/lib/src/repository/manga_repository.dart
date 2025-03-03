import '../enums/includes.dart';
import '../model/manga/manga_response.dart';
import '../model/manga/search_manga_parameter.dart';
import '../model/manga/search_manga_response.dart';
import '../model/tag/tag_response.dart';
import '../service/manga_service.dart';

class MangaRepository {
  final MangaService _service;

  const MangaRepository({
    required MangaService service,
  }) : _service = service;

  Future<SearchMangaResponse> search({
    SearchMangaParameter? parameter,
  }) {
    return _service.search(
      title: parameter?.title,
      limit: parameter?.limit,
      offset: parameter?.offset,
      authors: parameter?.authors,
      artists: parameter?.artists,
      year: parameter?.year,
      includedTags: parameter?.includedTags,
      includedTagsMode: parameter?.includedTagsMode?.rawValue,
      excludedTags: parameter?.excludedTags,
      excludedTagsMode: parameter?.excludedTagsMode?.rawValue,
      status: parameter?.status?.map((e) => e.rawValue).toList(),
      originalLanguage:
          parameter?.originalLanguage?.map((e) => e.rawValue).toList(),
      excludedOriginalLanguages:
          parameter?.excludedOriginalLanguages?.map((e) => e.rawValue).toList(),
      availableTranslatedLanguage: parameter?.availableTranslatedLanguage
          ?.map((e) => e.rawValue)
          .toList(),
      publicationDemographic:
          parameter?.publicationDemographic?.map((e) => e.rawValue).toList(),
      ids: parameter?.ids,
      contentRating: parameter?.contentRating?.map((e) => e.rawValue).toList(),
      createdAtSince: parameter?.createdAtSince,
      updatedAtSince: parameter?.updatedAtSince,
      includes: parameter?.includes?.map((e) => e.rawValue).toList(),
      group: parameter?.group,
      orders: parameter?.orders?.map(
        (key, value) => MapEntry(key.rawValue, value.rawValue),
      ),
    );
  }

  Future<TagResponse> tags() {
    return _service.tags();
  }

  Future<MangaResponse> detail({required String id, List<Include>? includes}) {
    return _service.detail(
      id: id,
      includes: includes?.map((e) => e.rawValue).toList(),
    );
  }
}
