import '../../enums/content_rating.dart';
import '../../enums/includes.dart';
import '../../enums/language_codes.dart';
import '../../enums/manga_status.dart';
import '../../enums/order_enums.dart';
import '../../enums/publication_demographic.dart';
import '../../enums/tag_modes.dart';
import '../common/search_parameter.dart';

class SearchMangaParameter extends SearchParameter {
  const SearchMangaParameter({
    super.limit,
    super.offset,
    super.page,
    super.updatedAtSince,
    super.includes,
    super.contentRating,
    super.originalLanguage,
    super.excludedOriginalLanguages,
    super.createdAtSince,
    super.ids,
    this.title,
    this.authors,
    this.artists,
    this.year,
    this.includedTags,
    this.includedTagsMode,
    this.excludedTags,
    this.excludedTagsMode,
    this.status,
    this.availableTranslatedLanguage,
    this.publicationDemographic,
    this.group,
    this.orders,
  });

  final String? title;
  final List<String>? authors;
  final List<String>? artists;
  final int? year;
  final List<String>? includedTags;
  final TagsMode? includedTagsMode;
  final List<String>? excludedTags;
  final TagsMode? excludedTagsMode;
  final List<MangaStatus>? status;
  final List<LanguageCodes>? availableTranslatedLanguage;
  final List<PublicDemographic>? publicationDemographic;
  final String? group;
  final Map<SearchOrders, OrderDirections>? orders;

  @override
  List<Object?> get props {
    return [
      ...super.props,
      title,
      authors,
      artists,
      year,
      includedTags,
      includedTagsMode,
      excludedTags,
      excludedTagsMode,
      status,
      availableTranslatedLanguage,
      publicationDemographic,
      group,
      orders,
    ];
  }

  @override
  SearchMangaParameter copyWith({
    int? limit,
    int? offset,
    int? page,
    String? updatedAtSince,
    List<Include>? includes,
    List<ContentRating>? contentRating,
    List<LanguageCodes>? originalLanguage,
    List<LanguageCodes>? excludedOriginalLanguages,
    String? createdAtSince,
    List<String>? ids,
    String? title,
    List<String>? authors,
    List<String>? artists,
    int? year,
    List<String>? includedTags,
    TagsMode? includedTagsMode,
    List<String>? excludedTags,
    TagsMode? excludedTagsMode,
    List<MangaStatus>? status,
    List<LanguageCodes>? availableTranslatedLanguage,
    List<PublicDemographic>? publicationDemographic,
    String? group,
    Map<SearchOrders, OrderDirections>? orders,
  }) {
    return SearchMangaParameter(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      page: page ?? this.page,
      updatedAtSince: updatedAtSince ?? this.updatedAtSince,
      includes: includes ?? this.includes,
      contentRating: contentRating ?? this.contentRating,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      excludedOriginalLanguages:
          excludedOriginalLanguages ?? this.excludedOriginalLanguages,
      createdAtSince: createdAtSince ?? this.createdAtSince,
      ids: ids ?? this.ids,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      artists: artists ?? this.artists,
      year: year ?? this.year,
      includedTags: includedTags ?? this.includedTags,
      includedTagsMode: includedTagsMode ?? this.includedTagsMode,
      excludedTags: excludedTags ?? this.excludedTags,
      excludedTagsMode: excludedTagsMode ?? this.excludedTagsMode,
      status: status ?? this.status,
      availableTranslatedLanguage:
          availableTranslatedLanguage ?? this.availableTranslatedLanguage,
      publicationDemographic:
          publicationDemographic ?? this.publicationDemographic,
      group: group ?? this.group,
      orders: orders ?? this.orders,
    );
  }
}
