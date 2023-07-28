import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class SearchMangaParameter extends Equatable with EquatableMixin {
  final String? title;
  final int? limit;
  final int? offset;
  final List<String>? authors;
  final List<String>? artists;
  final int? year;
  final List<String> includedTags;
  final TagsMode includedTagsMode;
  final List<String> excludedTags;
  final TagsMode excludedTagsMode;
  final List<MangaStatus>? status;
  final List<LanguageCodes>? originalLanguage;
  final List<LanguageCodes>? excludedOriginalLanguages;
  final List<LanguageCodes>? availableTranslatedLanguage;
  final List<PublicDemographic>? publicationDemographic;
  final List<String>? ids;
  final List<ContentRating>? contentRating;
  final String? createdAtSince;
  final String? updatedAtSince;
  final List<String>? includes;
  final String? group;
  final Map<SearchOrders, OrderDirections>? orders;

  const SearchMangaParameter({
    this.title,
    this.limit,
    this.offset,
    this.authors,
    this.artists,
    this.year,
    this.includedTags = const [],
    this.includedTagsMode = TagsMode.or,
    this.excludedTags = const [],
    this.excludedTagsMode = TagsMode.or,
    this.status,
    this.originalLanguage,
    this.excludedOriginalLanguages,
    this.availableTranslatedLanguage,
    this.publicationDemographic,
    this.ids,
    this.contentRating,
    this.createdAtSince,
    this.updatedAtSince,
    this.includes,
    this.group,
    this.orders,
  });

  @override
  List<Object?> get props {
    return [
      title,
      limit,
      offset,
      authors,
      artists,
      year,
      includedTags,
      includedTagsMode,
      excludedTags,
      excludedTagsMode,
      status,
      originalLanguage,
      excludedOriginalLanguages,
      availableTranslatedLanguage,
      publicationDemographic,
      ids,
      contentRating,
      createdAtSince,
      updatedAtSince,
      includes,
      group,
      orders,
    ];
  }

  SearchMangaParameter copyWith({
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
  }) {
    return SearchMangaParameter(
      title: title ?? this.title,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      authors: authors ?? this.authors,
      artists: artists ?? this.artists,
      year: year ?? this.year,
      includedTags: includedTags ?? this.includedTags,
      includedTagsMode: includedTagsMode ?? this.includedTagsMode,
      excludedTags: excludedTags ?? this.excludedTags,
      excludedTagsMode: excludedTagsMode ?? this.excludedTagsMode,
      status: status ?? this.status,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      excludedOriginalLanguages:
      excludedOriginalLanguages ?? this.excludedOriginalLanguages,
      availableTranslatedLanguage:
      availableTranslatedLanguage ?? this.availableTranslatedLanguage,
      publicationDemographic:
      publicationDemographic ?? this.publicationDemographic,
      ids: ids ?? this.ids,
      contentRating: contentRating ?? this.contentRating,
      createdAtSince: createdAtSince ?? this.createdAtSince,
      updatedAtSince: updatedAtSince ?? this.updatedAtSince,
      includes: includes ?? this.includes,
      group: group ?? this.group,
      orders: orders ?? this.orders,
    );
  }
}
