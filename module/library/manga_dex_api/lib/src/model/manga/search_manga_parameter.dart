import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../../enums/content_rating.dart';
import '../../enums/includes.dart';
import '../../enums/language_codes.dart';
import '../../enums/manga_status.dart';
import '../../enums/order_enums.dart';
import '../../enums/publication_demographic.dart';
import '../../enums/tag_modes.dart';
import '../common/search_parameter.dart';

part 'search_manga_parameter.g.dart';

@JsonSerializable()
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
    this.includedTagsMode = TagsMode.or,
    this.excludedTags,
    this.excludedTagsMode = TagsMode.or,
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
  final TagsMode includedTagsMode;
  final List<String>? excludedTags;
  final TagsMode excludedTagsMode;
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

  SearchMangaParameter merge(SearchMangaParameter? other) {
    return copyWith(
      updatedAtSince: other?.updatedAtSince ?? updatedAtSince,
      includes: other?.includes ?? includes,
      contentRating: other?.contentRating ?? contentRating,
      originalLanguage: other?.originalLanguage ?? originalLanguage,
      excludedOriginalLanguages:
          other?.excludedOriginalLanguages ?? excludedOriginalLanguages,
      createdAtSince: other?.createdAtSince ?? createdAtSince,
      ids: other?.ids ?? ids,
      title: other?.title ?? title,
      authors: other?.authors ?? authors,
      artists: other?.artists ?? artists,
      year: other?.year ?? year,
      includedTags: other?.includedTags ?? includedTags,
      includedTagsMode: other?.includedTagsMode ?? includedTagsMode,
      excludedTags: other?.excludedTags ?? excludedTags,
      excludedTagsMode: other?.excludedTagsMode ?? excludedTagsMode,
      status: other?.status ?? status,
      availableTranslatedLanguage:
          other?.availableTranslatedLanguage ?? availableTranslatedLanguage,
      publicationDemographic:
          other?.publicationDemographic ?? publicationDemographic,
      group: other?.group ?? group,
      orders: other?.orders ?? orders,
    );
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

  factory SearchMangaParameter.fromJson(Map<String, dynamic> json) {
    return _$SearchMangaParameterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchMangaParameterToJson(this);

  String toJsonString() => json.encode(toJson());

  static SearchMangaParameter? fromJsonString(String value) {
    try {
      return SearchMangaParameter.fromJson(
        json.decode(value) as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }
}
