import '../../enums/content_rating.dart';
import '../../enums/includes.dart';
import '../../enums/language_codes.dart';
import '../../enums/order_enums.dart';
import '../common/search_parameter.dart';
import '../manga/search_manga_parameter.dart';

class SearchChapterParameter extends SearchParameter {
  final List<String>? groups;
  final String? uploader;
  final String? volume;
  final String? chapter;
  final List<LanguageCodes>? translatedLanguage;
  final String? publishedAtSince;
  final Map<ChapterOrders, OrderDirections>? orders;
  final List<String>? excludedGroups;
  final List<String>? excludedUploaders;

  const SearchChapterParameter({
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
    this.groups,
    this.uploader,
    this.volume,
    this.chapter,
    this.translatedLanguage,
    this.publishedAtSince,
    this.orders,
    this.excludedGroups,
    this.excludedUploaders,
  });

  @override
  List<Object?> get props {
    return [
      ...super.props,
      groups,
      uploader,
      volume,
      chapter,
      translatedLanguage,
      publishedAtSince,
      orders,
      excludedGroups,
      excludedUploaders,
    ];
  }

  @override
  SearchChapterParameter copyWith({
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
    List<String>? groups,
    String? uploader,
    String? volume,
    String? chapter,
    List<LanguageCodes>? translatedLanguage,
    String? publishedAtSince,
    Map<ChapterOrders, OrderDirections>? orders,
    List<String>? excludedGroups,
    List<String>? excludedUploaders,
  }) {
    return SearchChapterParameter(
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
      groups: groups ?? this.groups,
      uploader: uploader ?? this.uploader,
      volume: volume ?? this.volume,
      chapter: chapter ?? this.chapter,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
      publishedAtSince: publishedAtSince ?? this.publishedAtSince,
      orders: orders ?? this.orders,
      excludedGroups: excludedGroups ?? this.excludedGroups,
      excludedUploaders: excludedUploaders ?? this.excludedUploaders,
    );
  }

  factory SearchChapterParameter.from(SearchMangaParameter param) {
    return SearchChapterParameter(
      limit: param.limit,
      offset: param.offset,
      page: param.page,
      updatedAtSince: param.updatedAtSince,
      includes: param.includes,
      contentRating: param.contentRating,
      originalLanguage: param.originalLanguage,
      excludedOriginalLanguages: param.excludedOriginalLanguages,
      createdAtSince: param.createdAtSince,
      ids: param.ids,
      translatedLanguage: param.availableTranslatedLanguage,
    );
  }
}
